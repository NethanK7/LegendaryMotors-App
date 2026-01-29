import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'router/app_router.dart';
import 'api/api_client.dart';
import 'shared/app_theme.dart';

import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/weather_provider.dart';

import 'services/auth_service.dart';
import 'services/car_service.dart';
import 'services/admin_service.dart';
import 'services/checkout_service.dart';
import 'services/stripe_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Services
  await StripeService.init();

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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
