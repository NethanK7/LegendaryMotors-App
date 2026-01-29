import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color accentColor;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.accentColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final isWhiteAccent = accentColor == Colors.white;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isWhiteAccent ? Colors.transparent : accentColor,
          border: isWhiteAccent ? Border.all(color: Colors.white12) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: isWhiteAccent ? Colors.grey : Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
