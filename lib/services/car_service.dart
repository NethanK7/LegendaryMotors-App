import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:developer' as developer;
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../shared/models/car.dart';
import 'database_service.dart';
import 'mock_data_service.dart';

class CarService {
  final ApiClient _client;

  CarService(this._client);

  Future<List<Car>> getCars() async {
    try {
      final response = await _client.dio.get(ApiConstants.carsEndpoint);
      final cars = (response.data as List)
          .map((json) => Car.fromJson(json))
          .toList();

      // Update Cache (skip on web since SQLite doesn't work)
      if (!kIsWeb) {
        await DatabaseService().cacheCars(cars);
      }

      return cars;
    } catch (e) {
      developer.log('API fetch failed: $e', name: 'CarService');

      // Try SQLite cache (mobile only)
      if (!kIsWeb) {
        try {
          final cachedCars = await DatabaseService().getCachedCars();
          if (cachedCars.isNotEmpty) {
            developer.log('Using cached data', name: 'CarService');
            return cachedCars;
          }
        } catch (cacheError) {
          developer.log('Cache read failed: $cacheError', name: 'CarService');
        }
      }

      // Final fallback to mock data
      developer.log('Using mock data', name: 'CarService');
      return MockDataService.getMockCars();
    }
  }

  Future<Car> getCar(int id) async {
    try {
      final response = await _client.dio.get(
        '${ApiConstants.carsEndpoint}/$id',
      );
      return Car.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch car: ${e.toString()}');
    }
  }

  Future<Car> createCar(Map<String, dynamic> carData) async {
    try {
      final response = await _client.dio.post('/admin/cars', data: carData);
      final newCar = Car.fromJson(response.data);
      if (!kIsWeb) {
        await DatabaseService().insertCar(newCar);
      }
      return newCar;
    } catch (e) {
      throw Exception('Failed to create car: ${e.toString()}');
    }
  }

  Future<Car> updateCar(int id, Map<String, dynamic> carData) async {
    try {
      final response = await _client.dio.put('/admin/cars/$id', data: carData);
      final updatedCar = Car.fromJson(response.data);
      if (!kIsWeb) {
        await DatabaseService().updateCar(updatedCar);
      }
      return updatedCar;
    } catch (e) {
      throw Exception('Failed to update car: ${e.toString()}');
    }
  }

  Future<void> deleteCar(int id) async {
    try {
      await _client.dio.delete('/admin/cars/$id');
      if (!kIsWeb) {
        await DatabaseService().deleteCar(id);
      }
    } catch (e) {
      throw Exception('Failed to delete car: ${e.toString()}');
    }
  }
}
