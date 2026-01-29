import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../api/api_constants.dart';

class WeatherData {
  final double temp;
  final String condition;
  final String city;

  WeatherData({
    required this.temp,
    required this.condition,
    required this.city,
  });
}

class WeatherProvider extends ChangeNotifier {
  WeatherData? _weather;
  bool _isLoading = false;
  String? _error;

  WeatherProvider() {
    fetchWeather();
  }

  WeatherData? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeather() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // 1. Get Location
      Position? position;
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
            );
          }
        }
      } catch (e) {
        // Location failed, use default
      }

      // Default to Bottrop, Germany (Brabus HQ) if no location
      double lat = position?.latitude ?? 51.5207;
      double lon = position?.longitude ?? 6.9214;

      // 2. Fetch Weather
      if (ApiConstants.openWeatherApiKey.isEmpty) {
        throw Exception('API Key missing');
      }

      final dio = Dio();
      final response = await dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': ApiConstants.openWeatherApiKey,
          'units': 'metric',
        },
      );

      final data = response.data;
      final temp = (data['main']['temp'] as num).toDouble();
      final condition = data['weather'][0]['main'] as String;
      final city = data['name'] as String;

      _weather = WeatherData(temp: temp, condition: condition, city: city);
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }
}
