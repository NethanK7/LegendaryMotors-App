import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'ambient_light_helper.dart';

class AmbientLightHelperWeb implements AmbientLightHelper {
  @override
  bool isSupported() {
    return js_util.hasProperty(html.window, 'AmbientLightSensor');
  }

  @override
  void start(void Function(double lux) onReading) {
    try {
      final sensor = js_util.callConstructor(
        js_util.getProperty(html.window, 'AmbientLightSensor'),
        [],
      );

      js_util.setProperty(
        sensor,
        'onreading',
        js_util.allowInterop(() {
          final double illuminance = js_util.getProperty(sensor, 'illuminance');
          onReading(illuminance);
        }),
      );

      js_util.callMethod(sensor, 'start', []);
    } catch (e) {
      print('Failed to start AmbientLightSensor: $e');
    }
  }
}

AmbientLightHelper getHelper() => AmbientLightHelperWeb();
