import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../shared/models/car.dart';

class FavoritesProvider extends ChangeNotifier {
  final ApiClient _client;
  List<Car> _favorites = [];
  bool _isLoading = false;
  String? _error;

  FavoritesProvider(this._client) {
    fetchFavorites();
  }

  List<Car> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _client.dio.get(ApiConstants.favoritesEndpoint);
      final List<dynamic> data = response.data;
      _favorites = data.map((e) => Car.fromJson(e)).toList();
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
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
