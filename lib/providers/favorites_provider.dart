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

  // get the list by calling our backend api
  Future<void> fetchFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _client.dio.get(ApiConstants.favoritesEndpoint);

      // check if we got HTML (login page) instead of JSON
      // this happens if the auth token expired and laravel redirects us
      if (response.data is String &&
          response.data.toString().contains('<html')) {
        debugPrint('Got HTML instead of JSON. Auth token might be expired.');
        throw Exception('Auth Error: Received HTML login page');
      }

      final List<dynamic> data = response.data;
      _favorites = data.map((e) => Car.fromJson(e)).toList();
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('failed to load favorites: $e');
    }
    notifyListeners();
  }

  // simple toggle: add if not there, remove if it is
  Future<void> toggleFavorite(int carId) async {
    try {
      await _client.dio.post(
        ApiConstants.favoritesEndpoint,
        data: {'car_id': carId},
      );
      // reload the list to stay in sync with server
      fetchFavorites();
    } catch (e) {
      debugPrint('error toggling favorite: $e');
    }
  }
}
