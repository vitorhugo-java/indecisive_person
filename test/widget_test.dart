// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:indecisive_person/main.dart';

void main() {
  testWidgets('shows release prep overview for the app', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('The Universe Decides'), findsOneWidget);
    expect(find.text('Core experiences'), findsOneWidget);
    expect(find.text('Animated Coin Flip'), findsOneWidget);
    expect(find.text('RPG Dice Roller'), findsOneWidget);
    expect(find.text('Custom List Picker'), findsOneWidget);
    expect(find.text('Release readiness'), findsOneWidget);
    expect(find.text('Polished icon and assets'), findsOneWidget);
    expect(find.text('Unique package name'), findsOneWidget);
    expect(find.text('Android release keystore'), findsOneWidget);
  });
}
