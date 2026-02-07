import '../../shared/models/car.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  // No-op for web
  Future<dynamic> get database async => null;

  Future<void> cacheCars(List<Car> cars) async {}
  Future<void> insertCar(Car car) async {}
  Future<void> updateCar(Car car) async {}
  Future<void> deleteCar(int id) async {}
  Future<List<Car>> getCachedCars() async => [];
  Future<void> cacheAllocations(List<Car> cars) async {}
  Future<List<Car>> getCachedAllocations() async => [];
  Future<void> saveSetting(String key, String value) async {}
  Future<String?> getSetting(String key) async => null;
}
