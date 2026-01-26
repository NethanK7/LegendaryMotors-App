import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionLabel extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const SectionLabel({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: color ?? const Color(0xFFE30613),
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
