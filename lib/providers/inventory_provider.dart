import 'package:flutter/material.dart';
import '../shared/models/car.dart';
import '../services/car_service.dart';

class InventoryProvider extends ChangeNotifier {
  final CarService _service;
  List<Car> _cars = [];
  bool _isLoading = false;
  String? _error;

  InventoryProvider(this._service) {
    fetchInventory();
  }

  List<Car> get cars => _cars;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // fetch the full inventory list on startup
  Future<void> fetchInventory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // get cars from the central service (handles caching etc)
      _cars = await _service.getCars();
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      // log reliable error for dev debugging
      debugPrint('inventory fetch failed: $e');
    }
    notifyListeners();
  }
}
