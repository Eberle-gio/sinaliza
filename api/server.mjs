import { createServer } from 'node:http';
import { pathToFileURL } from 'node:url';

const source = 'https://dicionario.ines.gov.br/';
const videoBase = `${source}public/media/palavras/videos/`;
// Nomes conferidos no catálogo público do INES. Vídeos hospedados na fonte original.
export const questions = [
  { id: 'ines-5', video: 'abacaxiSm_Prog001.mp4', options: ['Banana', 'Abacaxi', 'Maçã'], correctIndex: 1 },
  { id: 'ines-1186', video: 'casaSm_Prog001.mp4', options: ['Casa', 'Escola', 'Hospital'], correctIndex: 0 },
  { id: 'ines-2706', video: 'gatoSm_Prog001.mp4', options: ['Cachorro', 'Pássaro', 'Gato'], correctIndex: 2 },
  { id: 'ines-2213', video: 'escolaSm_Prog001.mp4', options: ['Escola', 'Mercado', 'Praça'], correctIndex: 0 },
  { id: 'ines-3347', video: 'livroSm_Prog001.mp4', options: ['Caneta', 'Livro', 'Caderno'], correctIndex: 1 },
].map(({ video, ...question }) => ({ ...question, videoUrl: videoBase + video, source }));

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
    const path = new URL(request.url, 'http://localhost').pathname;
    if (path === '/questions') return send(200, questions);
    if (path === '/health') return send(200, { status: 'ok' });
    return send(404, { error: 'Rota não encontrada' });
  });
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const port = Number(process.env.PORT || 3000);
  makeServer().listen(port, '127.0.0.1', () => console.log(`API Sinaliza: http://localhost:${port}/questions`));
}
