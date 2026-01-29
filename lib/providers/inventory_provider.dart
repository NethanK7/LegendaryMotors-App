import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../shared/models/car.dart';
import '../services/database_service.dart';

// Service
class InventoryService {
  final ApiClient _client;

  InventoryService(this._client);

  Future<List<Car>> fetchCars() async {
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

// ChangeNotifier for Inventory
class InventoryProvider extends ChangeNotifier {
  final InventoryService _service;
  List<Car> _cars = [];
  bool _isLoading = false;
  String? _error;

  InventoryProvider(this._service) {
    fetchInventory();
  }

  List<Car> get cars => _cars;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchInventory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _cars = await _service.fetchCars();
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }
}
