import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CarSpecItem extends StatelessWidget {
  final String value;
  final String label;

  const CarSpecItem({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            color: onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            color: onSurface.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
