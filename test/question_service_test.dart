import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipes/services.dart';

List<Map<String, Object>> batch(int start) => List.generate(
  5,
  (i) => {
    'id': 'ines-${start + i}',
    'videoUrl': 'https://example.com/${start + i}.mp4',
    'options': ['Casa', 'Gato', 'Livro'],
    'correctIndex': i % 3,
  },
);

void main() {
  test(
    'envia os últimos cinco IDs e mantém a seleção após falha de rede',
    () async {
      final requests = <Uri>[];
      var fail = false;
      final client = MockClient((request) async {
        requests.add(request.url);
        if (fail) return http.Response('indisponível', 503);
        return http.Response(
          jsonEncode(batch(requests.length == 1 ? 1 : 6)),
          200,
        );
      });
      final service = QuestionService(client: client);
      final first = await service.fetch();
      expect(requests.first.queryParameters, isEmpty);
      fail = true;
      await expectLater(service.fetch(), throwsException);
      expect(
        requests.last.queryParameters['exclude'],
        first.map((q) => q.id).join(','),
      );
      fail = false;
      await service.fetch();
      expect(
        requests.last.queryParameters['exclude'],
        first.map((q) => q.id).join(','),
      );
      await service.fetch();
      expect(
        requests.last.queryParameters['exclude'],
        'ines-6,ines-7,ines-8,ines-9,ines-10',
      );
      client.close();
    },
  );
}
