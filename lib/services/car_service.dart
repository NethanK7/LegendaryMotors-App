import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../shared/models/car.dart';
import 'auth_service.dart'; // Import for apiClientProvider
import 'database_service.dart';

final carServiceProvider = Provider<CarService>((ref) {
  return CarService(ref.read(apiClientProvider));
});

class CarService {
  final ApiClient _client;

  CarService(this._client);

  Future<List<Car>> getCars() async {
    try {
      final response = await _client.dio.get(ApiConstants.carsEndpoint);
      // Assuming response.data is a List
      return (response.data as List).map((json) => Car.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch cars: ${e.toString()}');
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
      await DatabaseService().insertCar(newCar);
      return newCar;
    } catch (e) {
      throw Exception('Failed to create car: ${e.toString()}');
    }
  }

  Future<Car> updateCar(int id, Map<String, dynamic> carData) async {
    try {
      final response = await _client.dio.put('/admin/cars/$id', data: carData);
      final updatedCar = Car.fromJson(response.data);
      await DatabaseService().updateCar(updatedCar);
      return updatedCar;
    } catch (e) {
      throw Exception('Failed to update car: ${e.toString()}');
    }
  }

  Future<void> deleteCar(int id) async {
    try {
      await _client.dio.delete('/admin/cars/$id');
      await DatabaseService().deleteCar(id);
    } catch (e) {
      throw Exception('Failed to delete car: ${e.toString()}');
    }
  }
}
