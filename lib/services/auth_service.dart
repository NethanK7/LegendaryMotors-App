import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../shared/models/user.dart';

import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final ApiClient _client;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: dotenv.env['GOOGLE_CLIENT_ID_WEB'], // Web Client ID
    clientId: dotenv.env['GOOGLE_CLIENT_ID_IOS'], // iOS Client ID
  );

  AuthService(this._client);

  Future<User> register(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    try {
      final response = await _client.dio.post(
        '/register', // Endpoint
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password, // Laravel expects this
          'phone': phone,
        },
      );

      if (response.data['access_token'] != null) {
        final userData = response.data['user'];
        final token = response.data['access_token'];

        final userMap = Map<String, dynamic>.from(userData);
        userMap['token'] = token;

        final user = User.fromJson(userMap);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        return user;
      } else {
        // Fallback: Login manually
        return await login(email, password);
      }
    } catch (e) {
      throw Exception('Registration Failed: ${e.toString()}');
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      final userData = response.data['user'];
      final token = response.data['access_token'];

      // Combine user info and token
      final userMap = Map<String, dynamic>.from(userData);
      userMap['token'] = token;

      final user = User.fromJson(userMap);

      // Save token locally for persistence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      return user;
    } catch (e) {
      throw Exception('Login Failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Restore user session if token exists
  Future<User?> restoreUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return null;

    try {
      final response = await _client.dio.get('/user');
      final userData =
          response.data; // Assuming /user returns the user object directly

      final userMap = Map<String, dynamic>.from(userData);
      userMap['token'] = token; // Attach the existing token

      return User.fromJson(userMap);
    } catch (e) {
      // Token likely expired or invalid
      await logout();
      return null;
    }
  }

  Future<User> loginWithGoogle() async {
    try {
      developer.log('Starting Google Sign In...', name: 'AuthService');
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        developer.log('Google Sign In aborted by user', name: 'AuthService');
        throw Exception('Google Sign In aborted');
      }

      developer.log(
        'Google User retrieved: ${googleUser.email}',
        name: 'AuthService',
      );
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      developer.log(
        'Google ID Token: ${idToken != null && idToken.length > 10 ? idToken.substring(0, 10) : idToken}...',
        name: 'AuthService',
      );
      developer.log(
        'Google Access Token: ${accessToken != null && accessToken.length > 10 ? accessToken.substring(0, 10) : accessToken}...',
        name: 'AuthService',
      );

      if (idToken == null) {
        // NOTE: On Android, idToken should be populated if serverClientId is correct.
        // On iOS, it might require extra config.
        // Try falling back to accessToken if your backend supports it, or check config.
        developer.log(
          'ID Token is null! Checking if we can proceed...',
          name: 'AuthService',
        );
        if (accessToken == null) {
          throw Exception('Failed to retrieve authentication tokens');
        }
      }

      // Send ID Token to Backend
      final endpoint = '/auth/google';
      developer.log(
        'Sending token to backend at ${_client.dio.options.baseUrl}$endpoint...',
        name: 'AuthService',
      );
      final response = await _client.dio.post(
        '/auth/google',
        data: {
          'token': idToken ?? accessToken, // Send available token
          'provider': 'google',
        },
      );
      developer.log(
        'Backend response received: ${response.statusCode}',
        name: 'AuthService',
      );

      final userData = response.data['user'];
      final token = response.data['access_token'];

      final userMap = Map<String, dynamic>.from(userData);
      userMap['token'] = token;

      final user = User.fromJson(userMap);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      developer.log(
        'User parsed and token saved. Returning user.',
        name: 'AuthService',
      );
      return user;
    } catch (e) {
      if (e is DioException && e.response != null) {
        developer.log(
          'Backend Error Response: ${e.response?.data}',
          name: 'AuthService',
        );
      }
      developer.log('Google Login Error: $e', name: 'AuthService', error: e);
      throw Exception('Google Login Failed: ${e.toString()}');
    }
  }
}
