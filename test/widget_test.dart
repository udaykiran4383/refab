// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refab_app/app/app.dart';
import 'test_helper.dart';

void main() {
  group('ReFab app smoke test', () {
    setUpAll(() async {
      await TestHelper.setupFirebaseForTesting();
    });

    testWidgets('ReFab app smoke test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        ProviderScope(
          child: ReFabApp(),
        ),
      );

      // Wait for the app to settle
      await tester.pumpAndSettle();

      // Verify that the app builds without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
