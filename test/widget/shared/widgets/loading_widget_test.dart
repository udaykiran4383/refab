import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:refab_app/shared/widgets/loading_widget.dart';

void main() {
  group('LoadingWidget', () {
    testWidgets('should display loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display message when provided', (WidgetTester tester) async {
      const message = 'Loading data...';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(message: message),
          ),
        ),
      );

      expect(find.text(message), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should not display message when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      expect(find.byType(Text), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('LoadingOverlay', () {
    testWidgets('should show child when not loading', (WidgetTester tester) async {
      const childText = 'Child Widget';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: false,
              child: Text(childText),
            ),
          ),
        ),
      );

      expect(find.text(childText), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show loading overlay when loading', (WidgetTester tester) async {
      const childText = 'Child Widget';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: true,
              child: Text(childText),
            ),
          ),
        ),
      );

      expect(find.text(childText), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
