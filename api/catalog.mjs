// Entradas conferidas em https://dicionario.ines.gov.br/public/site/js/palavras.js.
// Os vídeos continuam hospedados no INES / Acessibilidade Brasil.
const entries = [
  [5, 'Abacaxi', 'abacaxi', ['Banana', 'Maçã']],
  [218, 'Água', 'agua', ['Café', 'Leite']],
  [730, 'Banana', 'banana', ['Laranja', 'Abacaxi']],
  [846, 'Bicicleta', 'bicicleta', ['Carro', 'Trem']],
  [1016, 'Cachorro', 'cachorro', ['Gato', 'Coelho']],
  [1027, 'Cadeira', 'cadeira', ['Caderno', 'Livro']],
  [1030, 'Caderno', 'caderno', ['Caneta', 'Lápis']],
  [1031, 'Café', 'cafe', ['Água', 'Leite']],
  [1112, 'Caneta', 'caneta', ['Lápis', 'Livro']],
  [1171, 'Carro', 'carro', ['Bicicleta', 'Trem']],
  [1186, 'Casa', 'casa', ['Escola', 'Hospital']],
  [1209, 'Cavalo', 'cavalo', ['Cachorro', 'Coelho']],
  [1382, 'Coelho', 'coelho', ['Gato', 'Cavalo']],
  [2213, 'Escola', 'escola', ['Hospital', 'Mercado']],
  [2706, 'Gato', 'gato', ['Coelho', 'Cachorro']],
  [2885, 'Hospital', 'hospital', ['Casa', 'Escola']],
  [3203, 'Lápis', 'lapis', ['Caneta', 'Caderno']],
  [3210, 'Laranja', 'laranja', ['Maçã', 'Banana']],
  [3255, 'Leite', 'leite', ['Café', 'Água']],
  [3347, 'Livro', 'livro', ['Caderno', 'Caneta']],
  [19, 'Abelha', 'abelha', ['Borboleta', 'Formiga']],
  [3583, 'Mercado', 'mercado', ['Hospital', 'Casa']],
  [4025, 'Pão', 'pao', ['Banana', 'Leite']],
  [4518, 'Professor', 'professor', ['Aluno', 'Médico']],
  [5452, 'Trem', 'trem', ['Carro', 'Bicicleta']],
];

export const catalog = entries.map(([id, answer, video, distractors]) => ({
  id: `ines-${id}`,
  answer,
  distractors,
  videoUrl: `https://dicionario.ines.gov.br/public/media/palavras/videos/${video}Sm_Prog001.mp4`,
  source: 'https://dicionario.ines.gov.br/',
}));
