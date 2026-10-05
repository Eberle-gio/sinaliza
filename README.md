# Sinaliza — Treino de Libras

Atividade individual em Flutter Web: cinco exercícios sorteados de um catálogo de 25 sinais,
feedback por resposta, resultado com sinais para revisar e histórico no Cloud Firestore.
Não usa Realtime Database nem Authentication.

## Treinos variados

A API sorteia cinco sinais distintos e embaralha suas alternativas em cada chamada.
O Flutter envia os IDs do último treino em `GET /questions?exclude=id1,id2,...`:
enquanto o app estiver aberto, o próximo treino não repete esses cinco sinais.
Sinais mais antigos podem reaparecer. Recarregar o navegador limpa essa memória.
O catálogo inclui alimentos, animais, objetos, lugares, transportes e professor.

**Ao atualizar uma instalação anterior:** reinicie a API e o Flutter e publique
novamente `firestore.rules` em **Firestore > Regras** no console. A regra antiga
permite apenas cinco nomes, então bloquearia resultados que tenham novos sinais
na lista de revisão. Os resultados anteriores continuam compatíveis.

## Rodar no navegador

Requisitos: Flutter e Node.js 18 ou superior. A API não tem dependências externas.
No primeiro terminal, na raiz do projeto:

```powershell
node api/server.mjs
```

No segundo terminal:

```powershell
flutter pub get
flutter run -d chrome --web-port=8080 --dart-define-from-file=firebase-config.json
```

O Flutter faz GET em `http://localhost:3000/questions`. A API aceita CORS de
localhost. Os vídeos são carregados do INES, portanto precisam de internet.
Sem Firebase, o treino funciona, mas mostra explicitamente que o resultado não é salvo.
Essa prévia sozinha ainda não cumpre a integração Firebase exigida na atividade.

## Configurar o único produto Firebase: Cloud Firestore

1. No [Firebase Console](https://console.firebase.google.com/), crie um projeto.
2. Registre um aplicativo Web pelo ícone `</>` e copie o objeto `firebaseConfig`.
3. Crie um banco **Cloud Firestore**, usando o banco padrão `(default)`.
4. Em **Firestore > Regras**, publique o conteúdo de `firestore.rules`.
5. Salve o objeto de configuração Web como JSON em `firebase-config.json`
   (sem `const firebaseConfig =`, sem ponto e vírgula e com chaves entre aspas).
   O app aceita os nomes originais: `apiKey`, `appId`, `messagingSenderId`,
   `projectId`, `authDomain` e `storageBucket`. Também aceita os nomes antigos:

| Chave do arquivo | Campo do firebaseConfig |
| --- | --- |
| FIREBASE_API_KEY | apiKey |
| FIREBASE_APP_ID | appId |
| FIREBASE_SENDER_ID | messagingSenderId |
| FIREBASE_PROJECT_ID | projectId |
| FIREBASE_AUTH_DOMAIN | authDomain |
| FIREBASE_STORAGE_BUCKET | storageBucket (opcional) |

Reinicie o Flutter com:

```powershell
flutter run -d chrome --web-port=8080 --dart-define-from-file=firebase-config.json
```

No VS Code, selecione **Sinaliza Web com Firebase** e pressione F5: essa
configuração já carrega o arquivo. Após mudar o JSON, encerre a execução e
inicie novamente; hot reload não altera esses valores de compilação.
Rodar sem `--dart-define-from-file` pelo terminal abre apenas a prévia sem Firebase.

Complete um treino, confirme a mensagem de salvamento, abra o histórico e recarregue
o navegador para verificar a persistência. Confira a coleção `training_results`
no console. Nenhuma chave de conta de serviço é necessária no aplicativo.

**Escopo de demonstração:** sem login, os últimos 20 resultados são compartilhados
por quem usa o projeto. Não há nomes, e-mails nem dados pessoais. As regras permitem
somente resultados com estrutura restrita, proíbem exclusões e expiram em 31/12/2026.
Elas não impedem terceiros de criar pontuações falsas: não use como avaliação oficial
nem publique como serviço privado. Para perfis individuais, adicione autenticação.

## Integrações e arquivos para explicar

- `api/catalog.mjs`: catálogo de 25 sinais e seus vídeos de referência.
- `api/server.mjs`: API própria Node que sorteia cinco perguntas em JSON.
- `lib/services.dart`, `QuestionService.fetch`: HTTP, JSON e modelos.
- `lib/services.dart`, `ResultService.save/list`: gravação e consulta no Firestore.
- `lib/main.dart`: telas inicial, exercício, resultado e histórico.
- `lib/signal_video_web.dart`: vídeo HTML integrado à tela Flutter Web.

O gabarito vem no JSON para simplificar o projeto didático; não é uma plataforma de provas.
Não há banco local simulando o Firestore. Erros de API, vídeo, leitura e gravação são visíveis.

## Fonte dos sinais

[Dicionário da Língua Brasileira de Sinais — INES / Acessibilidade Brasil](https://dicionario.ines.gov.br/).
Autores creditados na fonte: Guilherme de Azambuja Lira e Tanya Amara Felipe de Souza.
Os vídeos permanecem no servidor original; a API guarda apenas seus links.
Catálogo consultado: `public/site/js/palavras.js`; IDs e nomes constam em `api/catalog.mjs`.
O material serve para reconhecimento inicial e não substitui um curso de Libras.

## Roteiro para cinco minutos

1. **0:00–0:30:** objetivo: reconhecer cinco sinais e registrar o desempenho.
2. **0:30–2:00:** demonstrar um treino, incluindo um erro e a lista para revisar.
3. **2:00–3:00:** mostrar GET `/questions` e `QuestionService.fetch`.
4. **3:00–4:15:** mostrar `ResultService.save` e o documento no Firestore.
5. **4:15–5:00:** abrir o histórico após recarregar e explicar que usa Firestore, não Realtime.

## Verificações

```powershell
node --test api/server.test.mjs
flutter analyze
flutter test
flutter build web
```

Para conferir os links dos vídeos na fonte original: `node api/check-videos.mjs`
(requer internet; separado dos testes locais).

Para publicar futuramente, hospede a API em HTTPS, configure `APP_ORIGIN` com a origem
do site e compile com `--dart-define=API_BASE_URL=https://sua-api`. O servidor atual
escuta somente na máquina local, suficiente para a apresentação no navegador.
