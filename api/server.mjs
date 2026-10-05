import { createServer } from 'node:http';
import { pathToFileURL } from 'node:url';
import { randomInt } from 'node:crypto';
import { catalog } from './catalog.mjs';

function shuffle(items, randomIndex) {
  const result = [...items];
  for (let i = result.length - 1; i > 0; i--) {
    const j = randomIndex(i + 1);
    [result[i], result[j]] = [result[j], result[i]];
  }
  return result;
}

// Sorteia sem repetição no treino e sem os cinco IDs do treino anterior.
export function selectQuestions(excludedIds = [], randomIndex = randomInt) {
  const available = catalog.filter(item => !excludedIds.includes(item.id));
  if (available.length < 5) throw new RangeError('Poucos sinais disponíveis');
  return shuffle(available, randomIndex).slice(0, 5).map(item => {
    const options = shuffle([item.answer, ...item.distractors], randomIndex);
    return {
      id: item.id, videoUrl: item.videoUrl, source: item.source,
      options, correctIndex: options.indexOf(item.answer),
    };
  });
}

export function makeServer() {
  return createServer((request, response) => {
    const origin = request.headers.origin;
    const allowed = !origin || /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin) || origin === process.env.APP_ORIGIN;
    response.setHeader('Vary', 'Origin');
    if (origin && allowed) response.setHeader('Access-Control-Allow-Origin', origin);
    response.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    response.setHeader('Content-Type', 'application/json; charset=utf-8');
    response.setHeader('Cache-Control', 'no-store');
    const send = (code, body) => { response.writeHead(code); response.end(JSON.stringify(body)); };
    if (!allowed) return send(403, { error: 'Origem não autorizada' });
    if (request.method === 'OPTIONS') { response.writeHead(204); return response.end(); }
    if (request.method !== 'GET') { response.setHeader('Allow', 'GET, OPTIONS'); return send(405, { error: 'Método não permitido' }); }
    const url = new URL(request.url, 'http://localhost');
    const path = url.pathname;
    if (path === '/questions') {
      const excluded = [...new Set((url.searchParams.get('exclude') || '').split(',').filter(Boolean))];
      if (excluded.length > 5 || excluded.some(id => !catalog.some(item => item.id === id))) {
        return send(400, { error: 'Informe até cinco IDs válidos em exclude' });
      }
      return send(200, selectQuestions(excluded));
    }
    if (path === '/health') return send(200, { status: 'ok' });
    return send(404, { error: 'Rota não encontrada' });
  });
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const port = Number(process.env.PORT || 3000);
  makeServer().listen(port, '127.0.0.1', () => console.log(`API Sinaliza: http://localhost:${port}/questions`));
}
