import 'package:flutter_test/flutter_test.dart';

import 'package:theuniversedecides/main.dart';

void main() {
  testWidgets('shows the three main decision screens', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('The Universe Decides'), findsOneWidget);
    expect(find.text('Moeda'), findsOneWidget);
    expect(find.text('Dados'), findsOneWidget);
    expect(find.text('Listas'), findsOneWidget);
    expect(find.text('Lançar a moeda'), findsOneWidget);
  });
}
