import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/services.dart';

void main() {
  const questions = [
    Question(
      id: '1',
      videoUrl: 'https://example.com/a.mp4',
      options: ['Casa', 'Livro', 'Gato'],
      correctIndex: 0,
    ),
    Question(
      id: '2',
      videoUrl: 'https://example.com/b.mp4',
      options: ['Casa', 'Livro', 'Gato'],
      correctIndex: 2,
    ),
  ];
  test('pontuação e revisão refletem as respostas do treino', () {
    final result = TrainingResult.fromAnswers(questions, [0, 1]);
    expect(result.score, 1);
    expect(result.total, 2);
    expect(result.review, ['Gato']);
    expect(TrainingResult.fromAnswers(questions, [0, 2]).review, isEmpty);
  });
  test('rejeita treino incompleto e resposta fora das alternativas', () {
    expect(
      () => TrainingResult.fromAnswers(questions, [0]),
      throwsArgumentError,
    );
    expect(
      () => TrainingResult.fromAnswers(questions, [0, 8]),
      throwsArgumentError,
    );
  });
}
