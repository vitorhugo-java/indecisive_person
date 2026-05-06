import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const _randomOrgBaseUrl = 'https://www.random.org/integers/';
const _randomOrgTimeout = Duration(seconds: 6);

final randomOrgServiceProvider = Provider<RandomOrgService>((ref) {
  final service = RandomOrgService();
  ref.onDispose(service.dispose);
  return service;
});

class RandomOrgService {
  RandomOrgService({http.Client? client, math.Random? random})
    : _client = client ?? http.Client(),
      _random = random ?? math.Random();

  final http.Client _client;
  final math.Random _random;

  Future<List<int>> fetchIntegers({
    required int count,
    required int min,
    required int max,
  }) async {
    if (count <= 0 || max < min) {
      return const [];
    }

    final fallback = List<int>.generate(
      count,
      (_) => min + _random.nextInt(max - min + 1),
    );

    final uri = Uri.parse(_randomOrgBaseUrl).replace(
      queryParameters: {
        'num': '$count',
        'min': '$min',
        'max': '$max',
        'col': '1',
        'base': '10',
        'format': 'plain',
        'rnd': 'new',
      },
    );

    try {
      // Keep the wait short so the UI can fall back quickly on slow networks.
      final response = await _client.get(uri).timeout(_randomOrgTimeout);
      if (response.statusCode != 200) {
        return fallback;
      }

      final values = response.body
          .trim()
          .split(RegExp(r'\s+'))
          .where((value) => value.isNotEmpty)
          .map(int.tryParse)
          .whereType<int>()
          .toList();

      // Unexpected payloads should feel the same as offline mode to callers.
      if (values.length != count) {
        return fallback;
      }

      return values;
    } on TimeoutException {
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  void dispose() {
    _client.close();
  }
}
