import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/car.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<dynamic> get database async => null;

  Future<void> cacheCars(List<Car> cars) async {}
  Future<void> insertCar(Car car) async {}
  Future<void> updateCar(Car car) async {}
  Future<void> deleteCar(int id) async {}
  Future<List<Car>> getCachedCars() async => [];
  Future<void> cacheAllocations(List<Car> cars) async {}
  Future<List<Car>> getCachedAllocations() async => [];

  Future<void> saveSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getSetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}
