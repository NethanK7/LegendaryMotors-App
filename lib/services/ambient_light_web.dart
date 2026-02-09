import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'ambient_light_helper.dart';

// --- JS Interop Definitions --- //
// Ambient Light Sensor API is part of the Generic Sensor API.

@JS('AmbientLightSensor')
@staticInterop
class AmbientLightSensor {
  external factory AmbientLightSensor();
}

extension AmbientLightSensorExtension on AmbientLightSensor {
  external void start();
  external void stop();
  @JS('onreading')
  external set onreading(JSFunction? callback);
  @JS('onerror')
  external set onerror(JSFunction? callback);
  external double get illuminance;
}

// Add AmbientLightSensor property to Window
@JS('window')
external JSObject get window;

extension WindowExtension on JSObject {
  @JS('AmbientLightSensor')
  external JSAny? get AmbientLightSensor;
}

// --- Implementation --- //

class AmbientLightHelperWeb implements AmbientLightHelper {
  @override
  bool isSupported() {
    // Check if `window.AmbientLightSensor` exists
    // We access it via extension on web.window
    final sensorProp = (web.window as JSObject).AmbientLightSensor;
    return sensorProp != null;
  }

  @override
  void start(void Function(double lux) onReading) {
    if (!isSupported()) {
      print('AmbientLightSensor is not supported in this browser.');
      return;
    }

    try {
      final sensor = AmbientLightSensor();

      // Set onreading callback
      sensor.onreading = ((JSObject event) {
        // Access illuminance property
        final lux = sensor.illuminance;
        onReading(lux);
      }).toJS;

      // Set onerror callback
      sensor.onerror = ((JSObject event) {
        print('AmbientLightSensor error: $event');
      }).toJS;

      sensor.start();
    } catch (e) {
      print('Failed to start AmbientLightSensor: $e');
    }
  }
}

AmbientLightHelper getHelper() => AmbientLightHelperWeb();
