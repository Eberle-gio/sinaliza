import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'services.dart';
import 'signal_video.dart';

const purple = Color(0xff6250b8);
const ink = Color(0xff292640);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var connected = false;
  if (FirebaseConfig.isConfigured) {
    try {
      await Firebase.initializeApp(options: FirebaseConfig.webOptions);
      connected = true;
    } on FirebaseException catch (error) {
      debugPrint('Falha ao iniciar Firebase: ${error.code}');
    } catch (error) {
      debugPrint('Falha ao iniciar Firebase: ${error.runtimeType}');
    }
  }
  runApp(LibrasApp(results: ResultService(enabled: connected)));
}

class LibrasApp extends StatelessWidget {
  final ResultService results;
  const LibrasApp({super.key, required this.results});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Sinaliza • Treino de Libras',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xfff6f5fb),
      colorScheme: ColorScheme.fromSeed(seedColor: purple),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: ink, fontWeight: FontWeight.w800),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(padding: const EdgeInsets.all(22)),
      ),
    ),
    home: HomePage(results: results),
  );
}

class PageFrame extends StatelessWidget {
  final Widget child;
  const PageFrame({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Sinaliza',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      backgroundColor: const Color(0xfff6f5fb),
      centerTitle: false,
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(padding: const EdgeInsets.all(24), children: [child]),
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  final ResultService results;
  const HomePage({super.key, required this.results});
  @override
  Widget build(BuildContext context) => PageFrame(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        const Chip(
          avatar: Icon(Icons.waving_hand_outlined),
          label: Text('SEU PRIMEIRO PASSO EM LIBRAS'),
        ),
        const SizedBox(height: 24),
        Text(
          'Um sinal de cada vez.',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontSize: 44),
        ),
        const SizedBox(height: 16),
        const Text(
          'Observe os movimentos, escolha o significado e descubra o que revisar.',
          style: TextStyle(fontSize: 20, height: 1.5),
        ),
        const SizedBox(height: 32),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seu treino de hoje',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  '5 sinais do cotidiano • 3 alternativas por pergunta\nAssista quantas vezes precisar. Sem cronômetro.',
                  style: TextStyle(fontSize: 17, height: 1.6),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => QuizPage(results: results),
                ),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar treino'),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => HistoryPage(results: results),
                ),
              ),
              icon: const Icon(Icons.bar_chart),
              label: const Text('Ver desempenho'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          'Vídeos: Dicionário de Libras do INES / Acessibilidade Brasil.\nUm exercício de reconhecimento não substitui um curso de Libras.',
          style: TextStyle(height: 1.6),
        ),
        if (!results.enabled) ...[
          const SizedBox(height: 20),
          const Notice(
            'Prévia: o Firebase ainda não está conectado. Você pode treinar, mas seus resultados não serão salvos.',
          ),
        ],
      ],
    ),
  );
}

class QuizPage extends StatefulWidget {
  final ResultService results;
  const QuizPage({super.key, required this.results});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Future<List<Question>> questions;
  final answers = <int>[];
  int? selected;
  bool confirmed = false;
  @override
  void initState() {
    super.initState();
    questions = QuestionService().fetch();
  }

  void next(List<Question> data) {
    answers.add(selected!);
    if (answers.length == data.length) {
      final result = TrainingResult.fromAnswers(data, answers);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ResultPage(result: result, service: widget.results),
        ),
      );
    } else {
      setState(() {
        selected = null;
        confirmed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    child: FutureBuilder<List<Question>>(
      future: questions,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Column(
            children: [
              const Notice(
                'Não foi possível carregar os exercícios. Confira se a API está ligada e tente novamente.',
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => setState(() {
                  questions = QuestionService().fetch();
                }),
                child: const Text('Tentar novamente'),
              ),
            ],
          );
        }
        final data = snapshot.data!;
        final q = data[answers.length];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'EXERCÍCIO ${answers.length + 1} DE ${data.length}',
              style: const TextStyle(
                color: purple,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: answers.length / data.length,
              minHeight: 6,
            ),
            const SizedBox(height: 24),
            Text(
              'Qual é o significado deste sinal?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            const Text('Dê play e observe as mãos, o movimento e a expressão.'),
            const SizedBox(height: 20),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: SignalVideo(key: ValueKey(q.id), url: q.videoUrl),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fonte dos vídeos: INES / Acessibilidade Brasil',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < q.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(20),
                    backgroundColor: confirmed && i == q.correctIndex
                        ? const Color(0xffd9f1e5)
                        : selected == i
                        ? const Color(0xffe7e0fa)
                        : Colors.white,
                    foregroundColor: ink,
                    disabledForegroundColor: ink,
                  ),
                  onPressed: confirmed
                      ? null
                      : () => setState(() => selected = i),
                  child: Text(
                    '${String.fromCharCode(65 + i)}. ${q.options[i]}${confirmed && i == q.correctIndex
                        ? '  ✓ Resposta correta'
                        : selected == i
                        ? '  • Sua escolha'
                        : ''}',
                  ),
                ),
              ),
            if (confirmed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  selected == q.correctIndex
                      ? 'Você acertou! Este sinal significa ${q.answer}.'
                      : 'Vamos revisar: este sinal significa ${q.answer}.',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            FilledButton(
              onPressed: selected == null
                  ? null
                  : () {
                      if (confirmed) {
                        next(data);
                      } else {
                        setState(() => confirmed = true);
                      }
                    },
              child: Text(
                confirmed
                    ? (answers.length == data.length - 1
                          ? 'Ver resultado'
                          : 'Próximo sinal')
                    : 'Confirmar resposta',
              ),
            ),
          ],
        );
      },
    ),
  );
}

class ResultPage extends StatefulWidget {
  final TrainingResult result;
  final ResultService service;
  const ResultPage({super.key, required this.result, required this.service});
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool saving = false;
  bool saved = false;
  String? error;
  @override
  void initState() {
    super.initState();
    if (widget.service.enabled) save();
  }

  Future<void> save() async {
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.service.save(widget.result);
      if (mounted) setState(() => saved = true);
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Não foi possível confirmar o salvamento. Confira sua conexão e tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.emoji_events_outlined, size: 76, color: purple),
        const SizedBox(height: 20),
        Text(
          'Treino concluído!',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '${widget.result.score} de ${widget.result.total} acertos',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          widget.result.review.isEmpty
              ? 'Você reconheceu todos os sinais deste treino!'
              : 'Sinais para revisar: ${widget.result.review.join(', ')}.',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 24),
        if (saving) const LinearProgressIndicator(),
        if (saved) const Notice('Resultado salvo no Cloud Firestore.'),
        if (!widget.service.enabled)
          const Notice(
            'Resultado apenas nesta tela. Conecte o Firebase para salvar seu desempenho.',
          ),
        if (error != null) ...[
          Notice(error!),
          TextButton(
            onPressed: saving ? null : save,
            child: const Text('Tentar salvar novamente'),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => QuizPage(results: widget.service),
            ),
          ),
          child: const Text('Treinar novamente'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => HistoryPage(results: widget.service),
            ),
          ),
          child: const Text('Ver histórico'),
        ),
      ],
    ),
  );
}

class HistoryPage extends StatefulWidget {
  final ResultService results;
  const HistoryPage({super.key, required this.results});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<TrainingResult>> history;
  @override
  void initState() {
    super.initState();
    history = widget.results.list();
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Cada treino conta.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        const Text(
          'Histórico compartilhado da demonstração • últimos 20 treinos',
        ),
        const SizedBox(height: 24),
        if (!widget.results.enabled)
          const Notice(
            'O histórico estará disponível depois de conectar o Firebase.',
          )
        else
          FutureBuilder<List<TrainingResult>>(
            future: history,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Notice(
                  'Não foi possível consultar o histórico. Confira a conexão e as regras do Firestore.',
                );
              }
              if (snapshot.data!.isEmpty) {
                return const Notice(
                  'Nenhum treino salvo ainda. Complete seu primeiro treino!',
                );
              }
              return Column(
                children: snapshot.data!.map((result) {
                  final date = result.date.toLocal();
                  final stamp =
                      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(18),
                      leading: const Icon(
                        Icons.check_circle_outline,
                        color: purple,
                      ),
                      title: Text(
                        '${result.score}/${result.total} acertos • $stamp',
                      ),
                      subtitle: Text(
                        result.review.isEmpty
                            ? 'Todos os sinais reconhecidos.'
                            : 'Revisar: ${result.review.join(', ')}',
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        const SizedBox(height: 20),
        if (widget.results.enabled)
          OutlinedButton.icon(
            onPressed: () => setState(() => history = widget.results.list()),
            icon: const Icon(Icons.refresh),
            label: const Text('Atualizar histórico'),
          ),
      ],
    ),
  );
}

class Notice extends StatelessWidget {
  final String message;
  const Notice(this.message, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xffebe7f7),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(message, style: const TextStyle(color: ink, height: 1.5)),
  );
}
