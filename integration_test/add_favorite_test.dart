import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movie_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Login → HomePage → DetailPage → Add Favorite", (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsWidgets);
    await tester.enterText(find.byType(TextFormField).at(0), "david@gmail.com");
    await tester.enterText(find.byType(TextFormField).at(1), "david123");
    await tester.tap(find.text("Login"));

    for (int i = 0; i < 8; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pumpAndSettle();

    expect(find.text('Welcome back,'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);

    final movieRow = find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 240,
      description: 'movie row SizedBox',
    );
    expect(movieRow, findsWidgets);
    await tester.ensureVisible(movieRow.first);
    await tester.pumpAndSettle();
    await tester.tap(movieRow.first, warnIfMissed: false);

    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));

    await tester.pump();

    bool snackbarFound = false;
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(seconds: 1));

      final snackbar = find.text("Successfully added to Watchlist! ❤️");
      if (snackbar.evaluate().isNotEmpty) {
        snackbarFound = true;
        debugPrint('✅ SnackBar ditemukan di detik ke-$i');
        break;
      }
    }

    expect(snackbarFound, isTrue,
        reason: 'SnackBar "Successfully added to Watchlist!" tidak muncul. '
            'Kemungkinan: API gagal, userId kosong, atau movieId salah.');
  });
}