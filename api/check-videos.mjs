import { catalog } from './catalog.mjs';

// Verificação manual de disponibilidade; não roda nos testes locais da API.
const pending = [...catalog];
let failed = 0;
await Promise.all(Array.from({ length: 4 }, async () => {
  while (pending.length) {
    const item = pending.shift();
    try {
      const response = await fetch(item.videoUrl, {
        method: 'HEAD', signal: AbortSignal.timeout(15000),
      });
      if (!response.ok || !response.headers.get('content-type')?.includes('video/')) {
        throw new Error(`HTTP ${response.status}, ${response.headers.get('content-type')}`);
      }
      console.log(`OK: ${item.answer}`);
    } catch (error) {
      failed++;
      console.error(`Falha: ${item.answer}: ${error.message}`);
    }
  }
}));
console.log(`${catalog.length - failed}/${catalog.length} vídeos acessíveis.`);
process.exitCode = failed ? 1 : 0;
