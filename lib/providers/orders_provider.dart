import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../shared/models/car.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

final ordersProvider =
    StateNotifierProvider.autoDispose<OrdersNotifier, AsyncValue<List<Car>>>((
      ref,
    ) {
      final apiClient = ref.watch(apiClientProvider);
      return OrdersNotifier(apiClient);
    });

class OrdersNotifier extends StateNotifier<AsyncValue<List<Car>>> {
  final ApiClient _client;

  OrdersNotifier(this._client) : super(const AsyncValue.loading()) {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    // 1. Load from Cache Immediatey
    try {
      final cachedCars = await DatabaseService().getCachedAllocations();
      if (cachedCars.isNotEmpty) {
        state = AsyncValue.data(cachedCars);
      }
    } catch (e) {
      // Ignore cache errors, proceed to network
    }

    // 2. Fetch from Network
    try {
      final response = await _client.dio.get(ApiConstants.ordersEndpoint);

      final dynamic responseData = response.data;
      List<dynamic> listData;

      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('data')) {
        listData = responseData['data'];
      } else if (responseData is List) {
        listData = responseData;
      } else {
        listData = [];
      }

      final cars = listData.map((e) => Car.fromJson(e)).toList();
      state = AsyncValue.data(cars);

      // 3. Update Cache
      await DatabaseService().cacheAllocations(cars);
    } catch (e, st) {
      // If network fails and we have no cache (state is still loading or empty), show error
      // If we already showed cache, we might want to show a toast or keep showing cache
      if (state.value == null || state.value!.isEmpty) {
        state = AsyncValue.error(e, st);
      }
      // Else: silently fail and keep showing cached data
    }
  }
}
