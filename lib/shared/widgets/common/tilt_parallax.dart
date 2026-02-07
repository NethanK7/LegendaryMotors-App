import 'package:flutter/material.dart';

class TiltParallax extends StatelessWidget {
  final Widget child;
  final double intensity;

  const TiltParallax({super.key, required this.child, this.intensity = 20.0});

  @override
  Widget build(BuildContext context) {
    // Parallax disabled due to sensor instability on some platforms
    return child;
  }
}
