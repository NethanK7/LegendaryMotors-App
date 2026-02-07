import 'package:flutter/material.dart';
import '../shared/models/user.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/database_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isBiometricSupported;
  final bool isBiometricEnabled;
  final String? savedEmail;
  final String? localProfileImagePath;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isBiometricSupported = false,
    this.isBiometricEnabled = false,
    this.savedEmail,
    this.localProfileImagePath,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isBiometricSupported,
    bool? isBiometricEnabled,
    String? savedEmail,
    String? localProfileImagePath,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isBiometricSupported: isBiometricSupported ?? this.isBiometricSupported,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      savedEmail: savedEmail ?? this.savedEmail,
      localProfileImagePath:
          localProfileImagePath ?? this.localProfileImagePath,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  AuthState _state = AuthState();

  AuthProvider(this._authService) {
    checkAuthStatus();
    _initBiometrics();
    _loadLocalProfile();
  }

  Future<void> _loadLocalProfile() async {
    final path = await DatabaseService().getSetting('profile_image_path');
    _updateState(_state.copyWith(localProfileImagePath: path));
  }

  Future<void> updateLocalProfileImage(String path) async {
    await DatabaseService().saveSetting('profile_image_path', path);
    _updateState(_state.copyWith(localProfileImagePath: path));

    // If PWA/Web (Base64), try to sync with backend
    if (path.startsWith('data:image')) {
      await _authService.updateProfilePhoto(path);
    }
  }

  final BiometricService _biometricService = BiometricService();

  Future<void> _initBiometrics() async {
    final isSupported = await _biometricService.isBiometricAvailable();
    final isEnabled = await _authService.isBiometricsEnabled();
    final savedEmail = await _authService.getSavedEmail();
    _updateState(
      _state.copyWith(
        isBiometricSupported: isSupported,
        isBiometricEnabled: isEnabled,
        savedEmail: savedEmail,
      ),
    );
  }

  Future<void> toggleBiometrics(bool enabled) async {
    await _authService.setBiometricsEnabled(enabled);
    _updateState(_state.copyWith(isBiometricEnabled: enabled));
  }

  AuthState get state => _state;

  void _updateState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  // Handles User Login
  Future<void> login(String email, String password) async {
    _updateState(_state.copyWith(isLoading: true, error: null));
    try {
      final user = await _authService.login(email, password);
      await _authService.saveEmail(email);
      _updateState(
        _state.copyWith(user: user, isLoading: false, savedEmail: email),
      );
    } catch (e) {
      _updateState(_state.copyWith(isLoading: false, error: e.toString()));
      rethrow;
    }
  }

  // Handles User Registration
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

  // Restores user session from storage (Shared Preferences/Token)
  Future<void> checkAuthStatus() async {
    _updateState(_state.copyWith(isLoading: true));
    try {
      final user = await _authService.restoreUser();
      _updateState(_state.copyWith(user: user, isLoading: false));
    } catch (e) {
      _updateState(_state.copyWith(isLoading: false, error: null));
    }
  }

  // Integration with Google Sign-In
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

  // Login with Biometrics
  Future<void> loginWithBiometrics() async {
    if (!_state.isBiometricSupported || !_state.isBiometricEnabled) return;

    _updateState(_state.copyWith(isLoading: true, error: null));
    try {
      final authenticated = await _biometricService.authenticate();
      if (authenticated) {
        final user = await _authService.restoreUser();
        if (user != null) {
          _updateState(_state.copyWith(user: user, isLoading: false));
        } else {
          throw Exception('Session expired. Please login with password.');
        }
      } else {
        _updateState(_state.copyWith(isLoading: false));
      }
    } catch (e) {
      _updateState(_state.copyWith(isLoading: false, error: e.toString()));
      rethrow;
    }
  }

  // Logs the user out and wipes the state
  Future<void> logout() async {
    await _authService.logout();
    _updateState(AuthState()); // Resets state to default (logged out)
  }
}
