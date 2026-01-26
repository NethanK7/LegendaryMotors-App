import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../shared/models/car.dart';
import '../services/auth_service.dart';

final favoritesProvider =
    StateNotifierProvider.autoDispose<FavoritesNotifier, AsyncValue<List<Car>>>(
      (ref) {
        final apiClient = ref.watch(apiClientProvider);
        return FavoritesNotifier(apiClient);
      },
    );

class FavoritesNotifier extends StateNotifier<AsyncValue<List<Car>>> {
  final ApiClient _client;

  FavoritesNotifier(this._client) : super(const AsyncValue.loading()) {
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    try {
      final response = await _client.dio.get(ApiConstants.favoritesEndpoint);
      // Assuming response.data is List of Cars
      final List<dynamic> data = response.data;
      final cars = data.map((e) => Car.fromJson(e)).toList();
      state = AsyncValue.data(cars);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFavorite(int carId) async {
    try {
      await _client.dio.post(
        ApiConstants.favoritesEndpoint,
        data: {'car_id': carId},
      );
      fetchFavorites();
    } catch (e) {
      // Allow UI to handle error if needed
    }
  }
}
