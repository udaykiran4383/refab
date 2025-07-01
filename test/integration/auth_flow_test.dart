import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:refab_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Tests', () {
    testWidgets('should complete login flow successfully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify login page is displayed
      expect(find.text('ReFab'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);

      // Enter email
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );

      // Enter password
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Note: This test would need mock authentication for full testing
      // In a real scenario, you'd mock the Firebase auth response
    });

    testWidgets('should show validation errors for invalid input', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap login without entering data
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Verify validation errors are shown
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should switch between login and register forms', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Initially on login form
      expect(find.text('Login'), findsOneWidget);

      // Switch to register
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Verify register form is shown
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Role'), findsOneWidget);

      // Switch back to login
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Verify login form is shown again
      expect(find.text('Full Name'), findsNothing);
    });
  });
}
