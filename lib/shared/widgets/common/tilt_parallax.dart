import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class TiltParallax extends StatefulWidget {
  final Widget child;
  final double intensity;

  const TiltParallax({super.key, required this.child, this.intensity = 20.0});

  @override
  State<TiltParallax> createState() => _TiltParallaxState();
}

class _TiltParallaxState extends State<TiltParallax> {
  double _x = 0;
  double _y = 0;
  StreamSubscription<AccelerometerEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) {
      if (mounted) {
        setState(() {
          _x = (event.x / 10).clamp(-1.0, 1.0);
          _y = (event.y / 10).clamp(-1.0, 1.0);
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translateByVector3(
            Vector3(_x * widget.intensity, _y * widget.intensity, 0.0),
          )
          ..rotateX(_y * 0.05)
          ..rotateY(_x * 0.05),
        child: widget.child,
      ),
    );
  }
}
