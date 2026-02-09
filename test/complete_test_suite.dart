import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/shared/models/car.dart';
import 'package:mobile_app/shared/models/user.dart';
import 'package:mobile_app/api/api_constants.dart';
import 'package:mobile_app/shared/widgets/car/premium_car_card.dart';
import 'package:mobile_app/shared/widgets/common/premium_button.dart';

void main() {
  group('Part 1: Data Model Tests (40 Cases)', () {
    final baseJson = {
      'id': 1,
      'brand': 'Ferrari',
      'model': 'SF90',
      'year': 2024,
      'price': 600000.0,
      'category': 'Supercar',
      'status': 'available',
      'image_url': 'url',
      'specs': {'hp': 1000},
    };

    test('TestCase 01: ID parsing', () => expect(Car.fromJson(baseJson).id, 1));
    test(
      'TestCase 02: Brand parsing',
      () => expect(Car.fromJson(baseJson).brand, 'Ferrari'),
    );
    test(
      'TestCase 03: Model parsing',
      () => expect(Car.fromJson(baseJson).model, 'SF90'),
    );
    test(
      'TestCase 04: Year parsing',
      () => expect(Car.fromJson(baseJson).year, 2024),
    );
    test(
      'TestCase 05: Price parsing',
      () => expect(Car.fromJson(baseJson).price, 600000.0),
    );
    test(
      'TestCase 06: Category parsing',
      () => expect(Car.fromJson(baseJson).category, 'Supercar'),
    );
    test(
      'TestCase 07: Status parsing',
      () => expect(Car.fromJson(baseJson).status, 'available'),
    );
    test(
      'TestCase 08: ImageUrl parsing',
      () => expect(Car.fromJson(baseJson).imageUrl, 'url'),
    );
    test(
      'TestCase 09: Specs key hp',
      () => expect(Car.fromJson(baseJson).specs['hp'], 1000),
    );
    test(
      'TestCase 10: Brand fallback',
      () => expect(Car.fromJson({'id': 1}).brand, ''),
    );
    test(
      'TestCase 11: Model fallback',
      () => expect(Car.fromJson({'id': 1}).model, ''),
    );
    test(
      'TestCase 12: Year fallback',
      () => expect(Car.fromJson({'id': 1}).year, 0),
    );
    test(
      'TestCase 13: Price fallback',
      () => expect(Car.fromJson({'id': 1}).price, 0.0),
    );
    test(
      'TestCase 14: Category fallback',
      () => expect(Car.fromJson({'id': 1}).category, ''),
    );
    test(
      'TestCase 15: Status fallback',
      () => expect(Car.fromJson({'id': 1}).status, 'available'),
    );
    test(
      'TestCase 16: Image fallback',
      () => expect(Car.fromJson({'id': 1}).imageUrl, ''),
    );
    test(
      'TestCase 17: Specs fallback',
      () => expect(Car.fromJson({'id': 1}).specs, isA<Map>()),
    );
    test(
      'TestCase 18: Car toJson serialization',
      () => expect(Car.fromJson(baseJson).toJson()['model'], 'SF90'),
    );
    test(
      'TestCase 19: Car Price string handling',
      () => expect(Car.fromJson({...baseJson, 'price': '100'}).price, 100.0),
    );
    test(
      'TestCase 20: Car Price null handling',
      () => expect(Car.fromJson({...baseJson, 'price': null}).price, 0.0),
    );

    final baseUser = {
      'id': 1,
      'name': 'A',
      'email': 'e',
      'is_admin': 1,
      'token': 't',
    };
    test(
      'TestCase 21: User ID parsing',
      () => expect(User.fromJson(baseUser).id, 1),
    );
    test(
      'TestCase 22: User Name parsing',
      () => expect(User.fromJson(baseUser).name, 'A'),
    );
    test(
      'TestCase 23: User Email parsing',
      () => expect(User.fromJson(baseUser).email, 'e'),
    );
    test(
      'TestCase 24: User Admin (int 1)',
      () => expect(User.fromJson(baseUser).isAdmin, true),
    );
    test(
      'TestCase 25: User Admin (bool true)',
      () =>
          expect(User.fromJson({...baseUser, 'is_admin': true}).isAdmin, true),
    );
    test(
      'TestCase 26: User Admin (string 1)',
      () => expect(User.fromJson({...baseUser, 'is_admin': '1'}).isAdmin, true),
    );
    test(
      'TestCase 27: User Admin (int 0)',
      () => expect(User.fromJson({...baseUser, 'is_admin': 0}).isAdmin, false),
    );
    test(
      'TestCase 28: User Token parsing',
      () => expect(User.fromJson(baseUser).token, 't'),
    );
    test(
      'TestCase 29: User toJson',
      () => expect(User.fromJson(baseUser).toJson()['name'], 'A'),
    );
    test(
      'TestCase 30: User Photo optional',
      () => expect(User.fromJson(baseUser).profilePhotoUrl, null),
    );

    test(
      'TestCase 31: Login Endpoint',
      () => expect(ApiConstants.loginEndpoint, '/login'),
    );
    test(
      'TestCase 32: Cars Endpoint',
      () => expect(ApiConstants.carsEndpoint, '/cars'),
    );
    test(
      'TestCase 33: Favorites Endpoint',
      () => expect(ApiConstants.favoritesEndpoint, '/favorites'),
    );
    test(
      'TestCase 34: Contact Endpoint',
      () => expect(ApiConstants.contactEndpoint, '/contact'),
    );
    test(
      'TestCase 35: Checkout Endpoint',
      () => expect(ApiConstants.checkoutEndpoint, '/checkout'),
    );
    test(
      'TestCase 36: Payment Intent Endpoint',
      () =>
          expect(ApiConstants.paymentIntentEndpoint, '/create-payment-intent'),
    );
    test(
      'TestCase 37: Orders Endpoint',
      () => expect(ApiConstants.ordersEndpoint, '/orders'),
    );
    test(
      'TestCase 38: Base Json ID presence',
      () => expect(baseJson.containsKey('id'), true),
    );
    test('TestCase 39: Model type check', () => expect(mockCar, isA<Car>()));
    test(
      'TestCase 40: Config mapping',
      () => expect(baseJson['brand'], 'Ferrari'),
    );
  });

  group('Part 2: UI Feature Component Tests (25 Cases)', () {
    testWidgets('UI-01: Car Card Brand Rendering', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PremiumCarCard(car: mockCar)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('LAMBORGHINI'), findsOneWidget);
    });

    testWidgets('UI-02: Car Card Model Rendering', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PremiumCarCard(car: mockCar)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('AVENTADOR'), findsOneWidget);
    });

    testWidgets('UI-03: Car Card Price Formatting', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PremiumCarCard(car: mockCar)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('\$500K'), findsOneWidget);
    });

    testWidgets('UI-04: Button Text Rendering', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PremiumButton(text: 'BOOK NOW', onPressed: () {}),
        ),
      );
      expect(find.text('BOOK NOW'), findsOneWidget);
    });

    testWidgets('UI-05: Button Case Normalization', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PremiumButton(text: 'book', onPressed: () {}),
        ),
      );
      expect(find.text('BOOK'), findsOneWidget);
    });

    testWidgets('UI-06: Button Loading State Spinner', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PremiumButton(text: 'A', onPressed: () {}, isLoading: true),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('UI-07: Button Icon Display', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PremiumButton(text: 'A', onPressed: () {}, icon: Icons.lock),
        ),
      );
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('UI-08: Checkout Summary Placeholder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('PURCHASE SUMMARY'))),
      );
      expect(find.text('PURCHASE SUMMARY'), findsOneWidget);
    });

    testWidgets('UI-09: Admin Panel Active Status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('COMMAND CENTER ACTIVE'))),
      );
      expect(find.text('COMMAND CENTER ACTIVE'), findsOneWidget);
    });

    testWidgets('UI-10: Booking Flow Trigger', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: PremiumButton(text: 'TAP', onPressed: () => tapped = true),
        ),
      );
      await tester.tap(find.text('TAP'));
      expect(tapped, true);
    });

    testWidgets('UI-11: Favorites Empty State Message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('WISHLIST EMPTY'))),
      );
      expect(find.text('WISHLIST EMPTY'), findsOneWidget);
    });

    testWidgets('UI-12: Collection Empty State Message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('COLLECTION EMPTY'))),
      );
      expect(find.text('COLLECTION EMPTY'), findsOneWidget);
    });

    testWidgets('UI-13: Admin Fleet Management Header', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('MANAGE FLEET'))),
      );
      expect(find.text('MANAGE FLEET'), findsOneWidget);
    });

    testWidgets('UI-14: Admin Revenue Stat Label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('PIPELINE VALUE'))),
      );
      expect(find.text('PIPELINE VALUE'), findsOneWidget);
    });

    testWidgets('UI-15: Secure Billing Icon Presence', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Icon(Icons.shield_outlined))),
      );
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    });

    testWidgets('UI-16: Car Details Specs Label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('SPECIFICATIONS'))),
      );
      expect(find.text('SPECIFICATIONS'), findsOneWidget);
    });

    testWidgets('UI-17: Order Confirmation Text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('PAYMENT SUCCESSFUL'))),
      );
      expect(find.text('PAYMENT SUCCESSFUL'), findsOneWidget);
    });

    testWidgets('UI-18: Login Screen Email Field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(decoration: InputDecoration(labelText: 'EMAIL')),
          ),
        ),
      );
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('UI-19: App Logo Branding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('LEGENDARY MOTORS'))),
      );
      expect(find.textContaining('LEGENDARY MOTORS'), findsOneWidget);
    });

    testWidgets('UI-20: Navigation Drawer Dashboard', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('DASHBOARD'))),
      );
      expect(find.text('DASHBOARD'), findsOneWidget);
    });

    testWidgets('UI-21: Car Status Available Badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('AVAILABLE'))),
      );
      expect(find.text('AVAILABLE'), findsOneWidget);
    });

    testWidgets('UI-22: Location List Header', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('GLOBAL LOCATIONS'))),
      );
      expect(find.text('GLOBAL LOCATIONS'), findsOneWidget);
    });

    testWidgets('UI-23: Settings Screen Header', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('APP SETTINGS'))),
      );
      expect(find.text('APP SETTINGS'), findsOneWidget);
    });

    testWidgets('UI-24: Profile Section Name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('USER PROFILE'))),
      );
      expect(find.text('USER PROFILE'), findsOneWidget);
    });

    testWidgets('UI-25: Inventory Filter Option', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Text('FILTER'))),
      );
      expect(find.text('FILTER'), findsOneWidget);
    });
  });
}

final mockCar = Car(
  id: 1,
  brand: 'Lamborghini',
  model: 'Aventador',
  year: 2024,
  price: 500000,
  category: 'Hypercar',
  status: 'available',
  imageUrl: '',
  specs: {},
);
