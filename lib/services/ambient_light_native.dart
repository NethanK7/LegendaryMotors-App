import 'ambient_light_helper.dart';

class AmbientLightHelperNative implements AmbientLightHelper {
  @override
  bool isSupported() => false;

  @override
  void start(void Function(double lux) onReading) {
    // Mobile implementation would go here (e.g. using 'light' package)
  }
}

AmbientLightHelper getHelper() => AmbientLightHelperNative();
