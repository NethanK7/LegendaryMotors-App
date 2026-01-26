import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../shared/models/car.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

// Service
class InventoryService {
  final ApiClient _client;

  InventoryService(this._client);

  Future<List<Car>> fetchCars() async {
    // 1. Try Cache First (SQLite)
    try {
      final cachedCars = await DatabaseService().getCachedCars();
      if (cachedCars.isNotEmpty) {
        // Return cached immediately if you want offline-first speed,
        // but here we might want to return it but also fetch fresh data?
        // The Service 'fetchCars' returns a Future<List>, so it can only return once.
        // For a more reactive approach, the Controller should handle the "load cache -> show -> load network -> update" flow.
        // But to keep this simple and compatible with existing structure:
        // We will TRY network. If network fails, return Cache.
        // OR better: The Controller calls this.

        // Let's refactor this to just do the logic here:
      }
    } catch (e) {
      // ignore
    }

    // Actually, let's keep the logic similar: Try Network -> Sync DB -> Return. Fail -> Read DB.
    try {
      final response = await _client.dio.get(ApiConstants.carsEndpoint);
      final List<dynamic> data = response.data;

      final cars = data.map((json) => Car.fromJson(json)).toList();

      // Update Cache
      await DatabaseService().cacheCars(cars);

      return cars;
    } catch (e) {
      // Fallback to SQLite Cache
      final cachedCars = await DatabaseService().getCachedCars();
      if (cachedCars.isNotEmpty) {
        return cachedCars;
      }
      rethrow;
    }
  }
}

// Provider for Service
final inventoryServiceProvider = Provider<InventoryService>((ref) {
  return InventoryService(ref.read(apiClientProvider));
});

// Notifier
class InventoryController extends StateNotifier<AsyncValue<List<Car>>> {
  final InventoryService _service;

  InventoryController(this._service) : super(const AsyncValue.loading()) {
    fetchInventory();
  }

  Future<void> fetchInventory() async {
    state = const AsyncValue.loading();
    try {
      final cars = await _service.fetchCars();
      state = AsyncValue.data(cars);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final inventoryProvider =
    StateNotifierProvider<InventoryController, AsyncValue<List<Car>>>((ref) {
      final service = ref.watch(inventoryServiceProvider);
      return InventoryController(service);
    });
