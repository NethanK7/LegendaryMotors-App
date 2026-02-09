import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../api/api_constants.dart';

class StripeService {
  static Future<void> init() async {
    try {
      Stripe.publishableKey = ApiConstants.stripePublishableKey;
      await Stripe.instance.applySettings();
    } catch (e) {
      debugPrint('Stripe initialization failed: $e');
    }
  }
}
