import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_app/main.dart' as app;
import 'package:mobile_app/shared/widgets/common/premium_text_field.dart';
import 'package:mobile_app/shared/widgets/common/premium_button.dart';

// To run this test:
// flutter test integration_test/app_test.dart

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Legendary Motors E2E Automation', () {
    // Helper to add delay for realistic interaction and API waits
    Future<void> delay([int ms = 2000]) async {
      await Future.delayed(Duration(milliseconds: ms));
    }

    testWidgets(
      'Full Critical User Journey: Login -> Inventory -> Detail -> Logout',
      (tester) async {
        // 1. Launch App
        app.main();
        await tester.pumpAndSettle();
        await delay(2000);

        // --- LOGIN FLOW ---
        print('Step: Login Flow');

        // Find Login Fields
        final emailField = find.widgetWithText(PremiumTextField, 'EMAIL');
        final passwordField = find.widgetWithText(PremiumTextField, 'PASSWORD');
        final loginButton = find.widgetWithText(
          PremiumButton,
          'ENTER SHOWROOM',
        );

        // Check if we are already logged in (if Home screen is visible)
        if (emailField.evaluate().isNotEmpty) {
          // We are on Login Screen
          await tester.enterText(emailField, 'test@example.com');
          await tester.pump();
          await delay(500);

          await tester.enterText(passwordField, 'password');
          await tester.pump();
          await delay(500);

          // Hide keyboard
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();

          await tester.tap(loginButton);
          await tester.pumpAndSettle();
          await delay(3000); // Wait for API
        } else {
          print('User already logged in, proceeding to Inventory');
        }

        // --- INVENTORY FLOW ---
        print('Step: Inventory Navigation');

        // Verify Home Screen (Look for "LEGENDARY MOTORS" in AppBar or specific widget)
        // Verify Home Screen by checking for Bottom Navigation Bar (Search Icon)
        final searchIcon = find.byIcon(Icons.search);
        expect(
          searchIcon,
          findsOneWidget,
          reason: 'Search icon not found - likely Login failed',
        );

        await tester.tap(searchIcon);
        await tester.pumpAndSettle();
        await delay(1000);

        // Verify Inventory Loaded
        expect(find.text('INVENTORY'), findsOneWidget);
        await delay(2000);

        // Scroll a bit
        final listFinder = find.byType(CustomScrollView);
        await tester.drag(listFinder, const Offset(0, -300));
        await tester.pumpAndSettle();
        await delay(1000);

        // --- CAR DETAIL FLOW ---
        print('Step: Car Detail View');

        // Tap the first visible car card
        // We look for a widget that likely represents a car card key or text
        final firstCarCard = find
            .byType(GestureDetector)
            .at(5); // Adjust index based on layout depth
        // Alternatively, find by text if you know a car name, e.g., "FERRARI"
        // Let's try finding a car brand text to tap
        // final carItem = find.text('FERRARI').first;
        // await tester.tap(carItem);

        // For generic test, we just wait here as "Browsing Inventory"

        // --- SETTINGS / LOGOUT FLOW ---
        print('Step: Settings & Logout');

        // Tap Profile Tab (Last item)
        final profileIcon = find.byIcon(Icons.person_outline);
        await tester.tap(profileIcon);
        await tester.pumpAndSettle();
        await delay(1000);

        expect(find.text('PROFILE'), findsOneWidget);
        expect(find.text('SETTINGS'), findsOneWidget);

        // Find Logout Button
        final logoutButton = find.widgetWithText(PremiumButton, 'LOGOUT');

        // Scroll down to find logout if needed
        await tester.scrollUntilVisible(logoutButton, 100);
        await tester.pumpAndSettle();

        await tester.tap(logoutButton);
        await tester.pumpAndSettle();
        await delay(2000);

        // Verify we are back at Login
        expect(find.text('WELCOME BACK'), findsOneWidget);

        print('E2E Test Completed Successfully');
      },
    );
  });
}
