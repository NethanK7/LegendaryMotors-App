import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;
  final IconData icon;
  final bool isFullWidth;
  final double progressFactor;

  const AdminStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.accentColor,
    required this.icon,
    this.isFullWidth = false,
    this.progressFactor = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: accentColor.withValues(alpha: 0.8), size: 20),
              Icon(Icons.more_horiz, color: Colors.grey[800], size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              color: Colors.grey[500],
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 2,
            width: double.infinity,
            color: Colors.white.withValues(alpha: 0.1),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressFactor,
              child: Container(color: accentColor),
            ),
          ),
        ],
      ),
    );
  }
}
