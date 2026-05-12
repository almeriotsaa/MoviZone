import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movie_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Login → HomePage loaded", (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 800)); // fadeController
    await tester.pump(const Duration(milliseconds: 700)); // slideController
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), "david@gmail.com");
    await tester.enterText(find.byType(TextFormField).at(1), "david123");

    await tester.tap(find.text("Login"));

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back,'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
  });
}