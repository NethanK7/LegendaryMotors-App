import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Automatically detect platform for correct localhost address
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      print('Using API URL from .env: $envUrl');
      return envUrl;
    }

    // Default fallback (shouldn't hit this if .env is loaded)
    print('Warning: API_BASE_URL not found in .env, using localhost');
    return 'http://127.0.0.1:8000/api';
  }

  static const String loginEndpoint = '/login';
  static const String carsEndpoint = '/cars';
  static const String favoritesEndpoint = '/favorites';
  static const String contactEndpoint = '/contact';
  static const String checkoutEndpoint = '/checkout';
  static const String paymentIntentEndpoint = '/create-payment-intent';
  static const String ordersEndpoint = '/orders';

  static String get stripePublishableKey =>
      (dotenv.env['STRIPE_KEY'] ?? '').trim();

  static String get openWeatherApiKey =>
      (dotenv.env['OPENWEATHER_API_KEY'] ?? '').trim();
}
