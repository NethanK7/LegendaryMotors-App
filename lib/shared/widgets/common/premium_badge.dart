import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool isOutline;

  const PremiumBadge({
    super.key,
    required this.text,
    this.color = const Color(0xFFE30613),
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutline) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: color,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          color: color == Colors.white ? Colors.black : Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
