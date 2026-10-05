import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class Question {
  final String id, videoUrl;
  final List<String> options;
  final int correctIndex;
  const Question({
    required this.id,
    required this.videoUrl,
    required this.options,
    required this.correctIndex,
  });
  String get answer => options[correctIndex];
  factory Question.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List).cast<String>();
    final correct = json['correctIndex'] as int;
    final url = Uri.parse(json['videoUrl'] as String);
    if (options.length != 3 ||
        correct < 0 ||
        correct >= options.length ||
        url.scheme != 'https') {
      throw const FormatException('Pergunta inválida');
    }
    return Question(
      id: json['id'] as String,
      videoUrl: url.toString(),
      options: options,
      correctIndex: correct,
    );
  }
}

class QuestionService {
  static final shared = QuestionService();
  final http.Client? client;
  List<String> _previousIds = [];
  QuestionService({this.client});
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  // Integração 1: perguntas chegam por HTTP da API Node, fora do Flutter.
  Future<List<Question>> fetch() async {
    final uri = Uri.parse('$baseUrl/questions').replace(
      queryParameters: _previousIds.isEmpty
          ? null
          : {'exclude': _previousIds.join(',')},
    );
    final response = await (client?.get(uri) ?? http.get(uri)).timeout(
      const Duration(seconds: 12),
    );
    if (response.statusCode != 200) throw Exception('API indisponível');
    final data = (jsonDecode(response.body) as List)
        .map((item) => Question.fromJson(item as Map<String, dynamic>))
        .toList();
    if (data.length != 5 || data.map((q) => q.id).toSet().length != 5) {
      throw const FormatException(
        'O treino precisa de cinco perguntas distintas',
      );
    }
    _previousIds = data.map((q) => q.id).toList();
    return data;
  }
}

class TrainingResult {
  final String id;
  final int score, total;
  final List<String> review;
  final DateTime date;
  const TrainingResult({
    required this.id,
    required this.score,
    required this.total,
    required this.review,
    required this.date,
  });
  factory TrainingResult.fromAnswers(
    List<Question> questions,
    List<int> answers,
  ) {
    if (questions.isEmpty || questions.length != answers.length) {
      throw ArgumentError('Treino incompleto');
    }
    final review = <String>[];
    for (var i = 0; i < questions.length; i++) {
      if (answers[i] < 0 || answers[i] >= questions[i].options.length) {
        throw ArgumentError('Alternativa inválida');
      }
      if (answers[i] != questions[i].correctIndex) {
        review.add(questions[i].answer);
      }
    }
    final random = Random.secure();
    final id = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    return TrainingResult(
      id: id,
      score: questions.length - review.length,
      total: questions.length,
      review: review,
      date: DateTime.now(),
    );
  }
  factory TrainingResult.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return TrainingResult(
      id: doc.id,
      score: data['score'] as int,
      total: data['total'] as int,
      review: (data['review'] as List).cast<String>(),
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}

class ResultService {
  final bool enabled;
  const ResultService({required this.enabled});
  // Integração 2: grava e consulta resultados no Cloud Firestore.
  Future<void> save(TrainingResult result) async {
    if (!enabled) throw StateError('Firebase não conectado');
    await FirebaseFirestore.instance
        .collection('training_results')
        .doc(result.id)
        .set({
          'score': result.score,
          'total': result.total,
          'review': result.review,
          'date': Timestamp.fromDate(result.date),
        })
        .timeout(const Duration(seconds: 15));
  }

  Future<List<TrainingResult>> list() async {
    if (!enabled) return [];
    final snapshot = await FirebaseFirestore.instance
        .collection('training_results')
        .orderBy('date', descending: true)
        .limit(20)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 15));
    return snapshot.docs.map(TrainingResult.fromDoc).toList();
  }
}
