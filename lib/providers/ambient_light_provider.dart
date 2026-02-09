import 'package:flutter/material.dart';
import '../services/ambient_light_helper.dart';

class AmbientLightProvider extends ChangeNotifier {
  double _lux = 0;
  bool _isAutoBrightnessEnabled = true;
  bool _isSensorSupported = false;
  late final AmbientLightHelper _helper;

  AmbientLightProvider() {
    _helper = AmbientLightHelper();
    _isSensorSupported = _helper.isSupported();
    if (_isSensorSupported) {
      _helper.start(_updateLux);
    }
  }

  double get lux => _lux;
  bool get isAutoBrightnessEnabled => _isAutoBrightnessEnabled;
  bool get isSensorSupported => _isSensorSupported;

  // Determine theme mode based on lux
  ThemeMode get suggestedThemeMode {
    if (!_isAutoBrightnessEnabled) return ThemeMode.system;

    // Thresholds:
    // Bright light (> 500 lux) -> Light Mode (for readability)
    // Dim light (< 50 lux) -> Dark Mode (to protect eyes)
    if (_lux > 500) {
      return ThemeMode.light;
    } else if (_lux < 50) {
      return ThemeMode.dark;
    }
    return ThemeMode.system;
  }

  void _updateLux(double value) {
    if ((_lux - value).abs() > 5) {
      // Only notify if significant change
      _lux = value;
      notifyListeners();
    }
  }

  void toggleAutoBrightness(bool value) {
    _isAutoBrightnessEnabled = value;
    notifyListeners();
  }
}
