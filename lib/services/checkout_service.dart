import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import 'auth_service.dart';

final checkoutServiceProvider = Provider<CheckoutService>((ref) {
  return CheckoutService(ref.read(apiClientProvider));
});

class CheckoutService {
  final ApiClient _client;

  CheckoutService(this._client);

  Future<void> checkout({
    required int carId,
    required Map<String, dynamic> configuration,
    String deliveryMethod = 'pickup',
    String notes = '',
  }) async {
    try {
      await _client.dio.post(
        ApiConstants.checkoutEndpoint,
        data: {
          'car_id': carId,
          'configuration': configuration,
          'delivery_method': deliveryMethod,
          'notes': notes,
        },
      );
    } catch (e) {
      throw Exception('Checkout failed: ${e.toString()}');
    }
  }
}
