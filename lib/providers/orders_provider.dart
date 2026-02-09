import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../shared/models/car.dart';
import '../services/database_service.dart';

class OrdersProvider extends ChangeNotifier {
  final ApiClient _client;
  List<Car> _orders = [];
  bool _isLoading = false;
  String? _error;

  OrdersProvider(this._client) {
    fetchOrders();
  }

  List<Car> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOrders() async {
    try {
      final cachedCars = await DatabaseService().getCachedAllocations();
      if (cachedCars.isNotEmpty) {
        _orders = cachedCars;
        notifyListeners();
      }
    } catch (e) {
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

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

      _orders = listData.map((e) => Car.fromJson(e)).toList();
      _isLoading = false;

      await DatabaseService().cacheAllocations(_orders);
    } catch (e) {
      if (_orders.isEmpty) {
        _error = e.toString();
      }
      _isLoading = false;
    }
    notifyListeners();
  }
}
