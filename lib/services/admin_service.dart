import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../services/auth_service.dart';

final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService(ref.read(apiClientProvider));
});

class AdminService {
  final ApiClient _client;

  AdminService(this._client);

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _client.dio.get('/admin/stats');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch stats: ${e.toString()}');
    }
  }
}
