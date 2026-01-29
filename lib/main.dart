import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'router/app_router.dart';

import 'api/api_constants.dart';
import 'api/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/weather_provider.dart';
import 'services/auth_service.dart';
import 'services/car_service.dart';
import 'services/admin_service.dart';
import 'services/checkout_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Stripe (only works on iOS/Android)
  try {
    Stripe.publishableKey = ApiConstants.stripePublishableKey;
    await Stripe.instance.applySettings();
  } catch (e) {
    // Stripe not supported on this platform (e.g., macOS, Web)
    debugPrint('Stripe initialization failed: $e');
  }

  final apiClient = ApiClient();
  final authService = AuthService(apiClient);
  final carService = CarService(apiClient);
  final adminService = AdminService(apiClient);
  final checkoutService = CheckoutService(apiClient);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        Provider.value(value: authService),
        Provider.value(value: carService),
        Provider.value(value: adminService),
        Provider.value(value: checkoutService),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(
          create: (_) => InventoryProvider(InventoryService(apiClient)),
        ),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => OrdersProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ProxyProvider<AuthProvider, GoRouter>(
          update: (context, auth, previous) => AppRouter.router(auth),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = Provider.of<GoRouter>(context, listen: false);

    return MaterialApp.router(
      title: 'Legendary Motors',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE30613),
          brightness: Brightness.light,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE30613),
          brightness: Brightness.dark,
          surface: Colors.black,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      routerConfig: router,
    );
  }
}
