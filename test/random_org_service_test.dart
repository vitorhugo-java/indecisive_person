import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:theuniversedecides/main.dart';

void main() {
  test('fetchIntegers parses Random.org responses', () async {
    final service = RandomOrgService(
      client: MockClient(
        (_) async => http.Response('1\n3\n5\n', 200),
      ),
      random: math.Random(7),
    );

    addTearDown(service.dispose);

    final values = await service.fetchIntegers(count: 3, min: 1, max: 6);

    expect(values, [1, 3, 5]);
  });

  test('fetchIntegers falls back to local randomness on failure', () async {
    final service = RandomOrgService(
      client: MockClient((_) async => http.Response('oops', 500)),
      random: math.Random(7),
    );

    addTearDown(service.dispose);

    final values = await service.fetchIntegers(count: 4, min: 2, max: 4);

    expect(values, hasLength(4));
    expect(values.every((value) => value >= 2 && value <= 4), isTrue);
  });
}
