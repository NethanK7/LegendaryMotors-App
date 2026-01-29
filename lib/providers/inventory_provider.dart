import 'package:flutter/material.dart';
import '../shared/models/car.dart';
import '../services/car_service.dart';

// ChangeNotifier for Inventory
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

  Future<void> fetchInventory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _cars = await _service.getCars();
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }
}
