import 'dart:convert';

class Car {
  final int id;
  final String brand;
  final String model;
  final int year;
  final double price;
  final String category;
  final String status;
  final String imageUrl;
  final Map<String, dynamic> specs;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    required this.category,
    required this.status,
    required this.imageUrl,
    required this.specs,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      category: json['category'] ?? '',
      status: json['status'] ?? 'available',
      imageUrl: json['image_url'] ?? '',
      specs: (json['specs'] is Map<String, dynamic>)
          ? json['specs']
          : <String, dynamic>{},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'price': price,
      'category': category,
      'status': status,
      'image_url': imageUrl,
      'specs': specs,
    };
  }

  Map<String, dynamic> toJsonForDb() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'price': price, // SQLite handles int/real
      'category': category,
      'status': status,
      'imageUrl': imageUrl,
      'specs': jsonEncode(specs), // Convert map to JSON string
    };
  }

  factory Car.fromJsonFromDb(Map<String, dynamic> map) {
    return Car(
      id: map['id'],
      brand: map['brand'],
      model: map['model'],
      year: map['year'] ?? 0,
      price: (map['price'] as num).toDouble(),
      category: map['category'],
      status: map['status'],
      imageUrl: map['imageUrl'],
      specs: jsonDecode(map['specs'] ?? '{}'), // Decode string back to map
    );
  }
}
