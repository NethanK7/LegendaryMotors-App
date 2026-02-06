import 'package:flutter/foundation.dart' show kIsWeb;
import '../shared/models/car.dart';

/// Mock data service for web/offline mode
class MockDataService {
  static List<Car> getMockCars() {
    return [
      Car(
        id: 1,
        model: 'Aventador SVJ',
        brand: 'Lamborghini',
        price: 517770,
        year: 2023,
        imageUrl:
            'https://images.unsplash.com/photo-1621939514649-280e2ee25f60?auto=format&fit=crop&q=80&w=800',
        category: 'Supercar',
        status: 'available',
        specs: {
          'power': '770 HP',
          'acceleration': '0-100 in 2.8s',
          'topSpeed': '350 km/h',
        },
      ),
      Car(
        id: 2,
        model: 'Urus',
        brand: 'Lamborghini',
        price: 218009,
        year: 2024,
        imageUrl:
            'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&q=80&w=800',
        category: 'SUV',
        status: 'available',
        specs: {
          'power': '650 HP',
          'acceleration': '0-100 in 3.6s',
          'topSpeed': '305 km/h',
        },
      ),
      Car(
        id: 3,
        model: '911 Turbo S',
        brand: 'Porsche',
        price: 207000,
        year: 2024,
        imageUrl:
            'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&q=80&w=800',
        category: 'Coupe',
        status: 'available',
        specs: {
          'power': '640 HP',
          'acceleration': '0-100 in 2.7s',
          'topSpeed': '330 km/h',
        },
      ),
      Car(
        id: 4,
        model: 'Huracán EVO',
        brand: 'Lamborghini',
        price: 261274,
        year: 2023,
        imageUrl:
            'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?auto=format&fit=crop&q=80&w=800',
        category: 'Supercar',
        status: 'available',
        specs: {
          'power': '640 HP',
          'acceleration': '0-100 in 2.9s',
          'topSpeed': '325 km/h',
        },
      ),
      Car(
        id: 5,
        model: 'Cayenne Turbo GT',
        brand: 'Porsche',
        price: 181500,
        year: 2024,
        imageUrl:
            'https://images.unsplash.com/photo-1617654112368-307921291f42?auto=format&fit=crop&q=80&w=800',
        category: 'SUV',
        status: 'available',
        specs: {
          'power': '640 HP',
          'acceleration': '0-100 in 3.3s',
          'topSpeed': '300 km/h',
        },
      ),
      Car(
        id: 6,
        model: 'Panamera Turbo S',
        brand: 'Porsche',
        price: 198500,
        year: 2024,
        imageUrl:
            'https://images.unsplash.com/photo-1614200187524-dc4b892acf16?auto=format&fit=crop&q=80&w=800',
        category: 'Sedan',
        status: 'available',
        specs: {
          'power': '620 HP',
          'acceleration': '0-100 in 3.1s',
          'topSpeed': '315 km/h',
        },
      ),
    ];
  }

  static bool get shouldUseMockData => kIsWeb;
}
