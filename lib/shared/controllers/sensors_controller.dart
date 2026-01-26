import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ParallaxOffset {
  final double x;
  final double y;
  ParallaxOffset(this.x, this.y);
}

// Provider that listens to the accelerometer and emits parallax offsets
final parallaxProvider = StreamProvider<ParallaxOffset>((ref) {
  return accelerometerEventStream().map((event) {
    // We normalize the values for a subtle movement effect
    // Standard gravity is ~9.8. We want a range of roughly -1 to 1 for the offset.
    double x = event.x.clamp(-5.0, 5.0) / 10.0;
    double y = event.y.clamp(-5.0, 5.0) / 10.0;
    return ParallaxOffset(x, y);
  });
});
