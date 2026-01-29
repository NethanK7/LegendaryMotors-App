import '../api/api_client.dart';

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
