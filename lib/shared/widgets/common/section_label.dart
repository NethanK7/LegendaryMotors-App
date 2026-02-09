import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

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
          color: color ?? AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
