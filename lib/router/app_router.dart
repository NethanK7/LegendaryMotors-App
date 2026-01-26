import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/inventory/inventory_screen.dart';
import '../screens/inventory/car_detail_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/about/about_screen.dart';
import '../screens/contact/contact_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/locations/locations_screen.dart';
import '../screens/admin/admin_screen.dart';
import '../screens/admin/admin_fleet_screen.dart';
import '../screens/admin/add_edit_car_screen.dart';
import '../providers/auth_provider.dart';
import '../shared/models/car.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authProvider.notifier);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authNotifier.stream),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.user != null;
      final isLoginRoute = state.matchedLocation == '/login';
      final isRegisterRoute = state.matchedLocation == '/register';
      final isRootRoute = state.matchedLocation == '/';

      if (!isLoggedIn && !isLoginRoute && !isRegisterRoute) return '/login';

      if (isLoggedIn) {
        final isAdmin = authState.user!.isAdmin;
        // If on login page, redirect to appropriate home
        if (isLoginRoute) {
          return isAdmin ? '/admin' : '/';
        }
        // If admin tries to go to root (home), redirect to admin dashboard
        if (isAdmin && isRootRoute) {
          return '/admin';
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/inventory',
            builder: (context, state) {
              final category = state.uri.queryParameters['category'];
              return InventoryScreen(category: category);
            },
            routes: [
              GoRoute(
                path: 'car/:id',
                builder: (context, state) {
                  final carIdStr = state.pathParameters['id']!;
                  final carId = int.tryParse(carIdStr) ?? 0;
                  // Pass extra object if available to avoid refetching
                  final carObj = state.extra as Car?;
                  return CarDetailScreen(carId: carId, car: carObj);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/locations',
            builder: (context, state) => const LocationsScreen(),
          ),
        ],
      ),
      // Independent Routes (Modals or Fullscreen)
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
      GoRoute(
        path: '/contact',
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return CheckoutScreen(extra: extra);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
        routes: [
          GoRoute(
            path: 'fleet',
            builder: (context, state) => const AdminFleetScreen(),
          ),
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddEditCarScreen(),
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (context, state) {
              final carId = int.tryParse(state.pathParameters['id']!) ?? 0;
              final carObj = state.extra as Car?;
              return AddEditCarScreen(carId: carId, car: carObj);
            },
          ),
        ],
      ),
    ],
  );
});

// Helper for GoRouter to listen to Streams (like Riverpod Providers)
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
