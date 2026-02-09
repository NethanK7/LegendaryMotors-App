import 'ambient_light_helper_stub.dart'
    if (dart.library.html) 'ambient_light_web.dart'
    if (dart.library.io) 'ambient_light_native.dart';

abstract class AmbientLightHelper {
  factory AmbientLightHelper() => getHelper();

  void start(void Function(double lux) onReading);
  bool isSupported();
}
