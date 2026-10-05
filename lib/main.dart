import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'design.dart';
import 'firebase_options.dart';
import 'services.dart';
import 'signal_video.dart';

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
    theme: sinalizaTheme(),
    home: HomePage(results: results),
  );
}

class HomePage extends StatelessWidget {
  final ResultService results;
  const HomePage({super.key, required this.results});
  @override
  Widget build(BuildContext context) => AppShell(
    child: Column(
      children: [
        WelcomePanel(
          onStart: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => QuizPage(results: results)),
          ),
          onHistory: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => HistoryPage(results: results),
            ),
          ),
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
    questions = QuestionService.shared.fetch();
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
  Widget build(BuildContext context) => AppShell(
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
                    questions = QuestionService.shared.fetch();
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
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              runSpacing: 12,
              children: [
                Pill(
                  label: 'SINAL ${answers.length + 1} DE ${data.length}',
                  icon: Icons.sign_language_rounded,
                ),
                const Pill(
                  label: 'No seu ritmo',
                  color: mint,
                  icon: Icons.spa_outlined,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Semantics(
              label: 'Pergunta ${answers.length + 1} de ${data.length}',
              child: Row(
                children: List.generate(
                  data.length,
                  (index) => Expanded(
                    child: Container(
                      height: 7,
                      margin: EdgeInsets.only(
                        right: index == data.length - 1 ? 0 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: index <= answers.length
                            ? brand
                            : const Color(0xffe5dded),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'O que este sinal quer dizer?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Observe as mãos, o movimento e a expressão. Depois, escolha uma opção.',
              style: TextStyle(color: Color(0xff786e86)),
            ),
            const SizedBox(height: 26),
            ExerciseStage(
              video: SignalVideo(key: ValueKey(q.id), url: q.videoUrl),
              choices: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'QUAL É A SUA ESCOLHA?',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: Color(0xff786e86),
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < q.options.length; i++)
                    AnswerTile(
                      index: i,
                      label: q.options[i],
                      selected: selected == i,
                      confirmed: confirmed,
                      correct: i == q.correctIndex,
                      onTap: () => setState(() => selected = i),
                    ),
                  if (confirmed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Notice(
                        selected == q.correctIndex
                            ? 'Muito bem! Este sinal significa ${q.answer}.'
                            : 'Faz parte de aprender! Este sinal significa ${q.answer}.',
                        success: selected == q.correctIndex,
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: selected == null
                        ? null
                        : () {
                            if (confirmed) {
                              next(data);
                            } else {
                              setState(() => confirmed = true);
                            }
                          },
                    icon: Icon(
                      confirmed
                          ? Icons.arrow_forward_rounded
                          : Icons.check_rounded,
                      size: 20,
                    ),
                    label: Text(
                      confirmed
                          ? (answers.length == data.length - 1
                                ? 'Ver meu resultado'
                                : 'Próximo sinal')
                          : 'Confirmar resposta',
                    ),
                  ),
                  if (!confirmed)
                    const Padding(
                      padding: EdgeInsets.only(top: 14),
                      child: Text(
                        'Pode tentar. Cada descoberta conta!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff786e86),
                        ),
                      ),
                    ),
                ],
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
  Widget build(BuildContext context) => AppShell(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ResultCelebration(
              score: widget.result.score,
              total: widget.result.total,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.result.review.isEmpty
                              ? Icons.verified_rounded
                              : Icons.bookmark_outline_rounded,
                          color: brand,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.result.review.isEmpty
                                ? 'Tudo reconhecido por aqui!'
                                : 'Vamos dar mais uma olhada?',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.result.review.isEmpty
                          ? 'Continue praticando para fortalecer suas novas conexões.'
                          : 'Estes são os sinais para revisar no próximo treino.',
                      style: const TextStyle(color: Color(0xff786e86)),
                    ),
                    if (widget.result.review.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.result.review
                            .map(
                              (word) => Pill(
                                label: word,
                                color: peach,
                                icon: Icons.replay_rounded,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (saving) const LinearProgressIndicator(),
            if (saved)
              const Notice(
                'Seu treino foi salvo! Ele já faz parte do seu histórico.',
                success: true,
              ),
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
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => QuizPage(results: widget.service),
                ),
              ),
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Treinar novamente'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => HistoryPage(results: widget.service),
                ),
              ),
              icon: const Icon(Icons.insights_rounded),
              label: const Text('Ver histórico'),
            ),
          ],
        ),
      ),
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
  Widget build(BuildContext context) => AppShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Pill(
            label: 'APRENDIZADO EM MOVIMENTO',
            color: mint,
            icon: Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Cada treino conta.',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontSize: 36),
        ),
        const SizedBox(height: 10),
        const Text(
          'Olhe para o que você já descobriu e encontre seu próximo passo.',
          style: TextStyle(color: Color(0xff786e86)),
        ),
        const SizedBox(height: 8),
        const Text(
          'Histórico compartilhado da demonstração • últimos 20 treinos',
          style: TextStyle(fontSize: 12, color: Color(0xff786e86)),
        ),
        const SizedBox(height: 28),
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
                  'Sua jornada começa com um sinal. Complete seu primeiro treino para ver os resultados aqui!',
                );
              }
              final records = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HistorySummary(
                    count: records.length,
                    hits: records.fold(0, (sum, item) => sum + item.score),
                    total: records.fold(0, (sum, item) => sum + item.total),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Treinos recentes',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  ...records.map((result) {
                    final date = result.date.toLocal();
                    final stamp =
                        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: result.review.isEmpty ? mint : lavender,
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: Text(
                                '${result.score}/${result.total}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: darkInk,
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result.review.isEmpty
                                        ? 'Todos os sinais reconhecidos!'
                                        : 'Mais um passo na sua jornada',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    stamp,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xff786e86),
                                    ),
                                  ),
                                  if (result.review.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      'Revisar: ${result.review.join(', ')}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (MediaQuery.sizeOf(context).width > 500)
                              Icon(
                                result.review.isEmpty
                                    ? Icons.workspace_premium_rounded
                                    : Icons.eco_outlined,
                                color: result.review.isEmpty
                                    ? const Color(0xff397e64)
                                    : brand,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
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
  final bool success;
  const Notice(this.message, {super.key, this.success = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: success ? mint : lavender,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          success
              ? Icons.check_circle_outline_rounded
              : Icons.info_outline_rounded,
          color: success ? const Color(0xff397e64) : brand,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: darkInk, height: 1.5),
          ),
        ),
      ],
    ),
  );
}
