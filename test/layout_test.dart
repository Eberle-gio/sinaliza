import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/design.dart';
import 'package:recipes/main.dart';
import 'package:recipes/services.dart';

class _Results extends ResultService {
  const _Results() : super(enabled: true);
  @override
  Future<void> save(TrainingResult result) async {}
  @override
  Future<List<TrainingResult>> list() async => [sample];
}

final sample = TrainingResult(
  id: 'layout-only',
  score: 3,
  total: 5,
  review: ['Abacaxi', 'Livro'],
  date: DateTime(2026, 10, 5),
);

void main() {
  for (final size in [const Size(390, 844), const Size(1440, 1000)]) {
    testWidgets('Telas e navegação sem overflow em ${size.width}px', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const LibrasApp(results: _Results()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Meu desempenho'));
      await tester.tap(find.text('Meu desempenho'));
      await tester.pumpAndSettle();
      expect(find.text('Treinos recentes'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        MaterialApp(
          theme: sinalizaTheme(),
          home: ResultPage(result: sample, service: const _Results()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Treino concluído!'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        MaterialApp(
          theme: sinalizaTheme(),
          home: AppShell(
            child: ExerciseStage(
              video: const ColoredBox(color: lavender),
              choices: Column(
                children: List.generate(
                  3,
                  (index) => AnswerTile(
                    index: index,
                    label: ['Abacaxi', 'Casa', 'Livro'][index],
                    selected: index == 0,
                    confirmed: true,
                    correct: index == 1,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Resposta correta'), findsOneWidget);
      expect(find.text('Sua escolha'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
