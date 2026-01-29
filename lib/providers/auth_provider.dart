import 'package:flutter/material.dart';
import '../shared/models/user.dart';
import '../services/auth_service.dart';

// State class for Authentication
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// ChangeNotifier for Auth
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  AuthState _state = AuthState();

  AuthProvider(this._authService) {
    checkAuthStatus();
  }

  AuthState get state => _state;

  void _updateState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _updateState(_state.copyWith(isLoading: true, error: null));
    try {
      final user = await _authService.login(email, password);
      _updateState(_state.copyWith(user: user, isLoading: false));
    } catch (e) {
      _updateState(_state.copyWith(isLoading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    _updateState(_state.copyWith(isLoading: true, error: null));
    try {
      final user = await _authService.register(name, email, password, phone);
      _updateState(_state.copyWith(user: user, isLoading: false));
    } catch (e) {
      _updateState(_state.copyWith(isLoading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> checkAuthStatus() async {
    _updateState(_state.copyWith(isLoading: true));
    try {
      final user = await _authService.restoreUser();
      _updateState(_state.copyWith(user: user, isLoading: false));
    } catch (e) {
      _updateState(_state.copyWith(isLoading: false, error: null));
    }
  }

  Future<void> loginWithGoogle() async {
    _updateState(_state.copyWith(isLoading: true, error: null));
    try {
      final user = await _authService.loginWithGoogle();
      _updateState(_state.copyWith(user: user, isLoading: false));
    } catch (e) {
      _updateState(_state.copyWith(isLoading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _updateState(AuthState()); // Reset state
  }
}
