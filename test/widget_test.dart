import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:theuniversedecides/main.dart';

void main() {
  testWidgets('coin screen uses the random service', (WidgetTester tester) async {
    final service = _FakeRandomOrgService([
      [1],
    ]);

    await tester.pumpWidget(
      MyApp(
        overrides: [
          randomOrgServiceProvider.overrideWith((ref) => service),
        ],
      ),
    );
    await tester.tap(find.text('Lançar a moeda'));
    await tester.pumpAndSettle();

    expect(find.text('COROA'), findsOneWidget);
    expect(service.requests, [(1, 0, 1)]);
  });

  testWidgets('dice screen requests the selected dice configuration', (
    WidgetTester tester,
  ) async {
    final service = _FakeRandomOrgService([
      [2, 3],
    ]);

    await tester.pumpWidget(
      MyApp(
        overrides: [
          randomOrgServiceProvider.overrideWith((ref) => service),
        ],
      ),
    );
    await tester.tap(find.text('Dados'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rolar os dados'));
    await tester.pumpAndSettle();

    expect(find.text('Total: 5'), findsOneWidget);
    expect(service.requests, [(2, 1, 20)]);
  });

  testWidgets('list screen picks one item through the random service', (
    WidgetTester tester,
  ) async {
    final service = _FakeRandomOrgService([
      [1],
    ]);

    await tester.pumpWidget(
      MyApp(
        overrides: [
          randomOrgServiceProvider.overrideWith((ref) => service),
        ],
      ),
    );
    await tester.tap(find.text('Listas'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Chá');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Café');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher por mim'));
    await tester.pumpAndSettle();

    expect(find.text('Café'), findsWidgets);
    expect(service.requests, [(1, 0, 1)]);
  });
}

class _FakeRandomOrgService extends RandomOrgService {
  _FakeRandomOrgService(List<List<int>> responses)
    : _responses = Queue.of(responses);

  final Queue<List<int>> _responses;
  final List<(int, int, int)> requests = [];

  @override
  Future<List<int>> fetchIntegers({
    required int count,
    required int min,
    required int max,
  }) async {
    requests.add((count, min, max));
    return _responses.isEmpty ? const [] : _responses.removeFirst();
  }

  @override
  void dispose() {}
}
