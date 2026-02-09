import 'package:go_router/go_router.dart';
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

class AppRouter {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,

      redirect: (context, state) {
        final authState = authProvider.state;
        final isLoggedIn = authState.user != null;
        final isLoginRoute = state.matchedLocation == '/login';
        final isRegisterRoute = state.matchedLocation == '/register';
        final isRootRoute = state.matchedLocation == '/';

        if (!isLoggedIn && !isLoginRoute && !isRegisterRoute) return '/login';

        if (isLoggedIn) {
          final isAdmin = authState.user!.isAdmin;
          if (isLoginRoute) {
            return isAdmin ? '/admin' : '/';
          }
          if (isAdmin && isRootRoute) {
            return '/admin';
          }
        }
        return null;
      },

      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
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

        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutScreen(),
        ),
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
  }
}
