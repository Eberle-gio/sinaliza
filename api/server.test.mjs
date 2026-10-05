import { test } from 'node:test';
import assert from 'node:assert/strict';
import { makeServer } from './server.mjs';

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
    }
    assert.equal((await fetch(`${base}/missing`)).status, 404);
    assert.equal((await fetch(`${base}/questions`, { method: 'POST' })).status, 405);
    assert.equal((await fetch(`${base}/questions`, { method: 'OPTIONS', headers: { Origin: 'http://localhost:8080' } })).status, 204);
    assert.equal((await fetch(`${base}/questions`, { headers: { Origin: 'https://example.com' } })).status, 403);
  } finally { await new Promise(resolve => server.close(resolve)); }
});
