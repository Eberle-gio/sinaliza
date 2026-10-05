import { test } from 'node:test';
import assert from 'node:assert/strict';
import { makeServer, selectQuestions } from './server.mjs';
import { catalog } from './catalog.mjs';
import { readFileSync } from 'node:fs';

test('sorteio varia sinais e alternativas sem alterar o gabarito nem o catálogo', () => {
  const original = JSON.stringify(catalog);
  const first = selectQuestions([], () => 0);
  const another = selectQuestions([], max => max - 1);
  assert.notDeepEqual(first.map(q => q.id), another.map(q => q.id));
  const next = selectQuestions(first.map(q => q.id), () => 0);
  assert.ok(next.every(q => !first.some(previous => previous.id === q.id)));
  for (const batch of [first, another, next]) {
    assert.equal(new Set(batch.map(q => q.id)).size, 5);
    for (const q of batch) {
      assert.equal(new Set(q.options).size, 3);
      assert.equal(q.options[q.correctIndex], catalog.find(item => item.id === q.id).answer);
    }
  }
  assert.notDeepEqual(selectQuestions([], () => 0)[0].options, selectQuestions([], max => max - 1).find(q => q.id === first[0].id).options);
  assert.equal(JSON.stringify(catalog), original);
});

test('as regras locais do Firestore aceitam todos os nomes do catálogo', () => {
  const rules = readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8');
  const allowed = rules.match(/d\.review\.toSet\(\)\.hasOnly\(\[([\s\S]*?)\]\)/)[1];
  for (const item of catalog) assert.ok(allowed.includes(`'${item.answer}'`), item.answer);
  assert.equal(new Set(catalog.map(item => item.id)).size, 25);
  assert.equal(new Set(catalog.map(item => item.answer)).size, 25);
});

test('API entrega treino e trata rotas, métodos e CORS', async () => {
  const server = makeServer();
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  const base = `http://127.0.0.1:${server.address().port}`;
  try {
    const response = await fetch(`${base}/questions`, { headers: { Origin: 'http://localhost:8080' } });
    assert.equal(response.status, 200);
    assert.equal(response.headers.get('access-control-allow-origin'), 'http://localhost:8080');
    const questions = await response.json();
    assert.equal(questions.length, 5);
    assert.equal(new Set(questions.map(q => q.id)).size, 5);
    for (const q of questions) {
      assert.equal(q.options.length, 3);
      assert.ok(q.options[q.correctIndex]);
      assert.ok(q.videoUrl.startsWith('https://dicionario.ines.gov.br/'));
      assert.equal(q.options[q.correctIndex], catalog.find(item => item.id === q.id).answer);
    }
    const second = await fetch(`${base}/questions?exclude=${questions.map(q => q.id).join(',')}`);
    assert.equal(second.status, 200);
    assert.ok((await second.json()).every(q => !questions.some(first => first.id === q.id)));
    assert.equal((await fetch(`${base}/questions?exclude=unknown`)).status, 400);
    assert.equal((await fetch(`${base}/questions?exclude=${catalog.slice(0, 6).map(q => q.id).join(',')}`)).status, 400);
    assert.equal((await fetch(`${base}/missing`)).status, 404);
    assert.equal((await fetch(`${base}/questions`, { method: 'POST' })).status, 405);
    assert.equal((await fetch(`${base}/questions`, { method: 'OPTIONS', headers: { Origin: 'http://localhost:8080' } })).status, 204);
    assert.equal((await fetch(`${base}/questions`, { headers: { Origin: 'https://example.com' } })).status, 403);
  } finally { await new Promise(resolve => server.close(resolve)); }
});
