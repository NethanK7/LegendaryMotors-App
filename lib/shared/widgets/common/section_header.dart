import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMoreTap;

  const SectionHeader({super.key, required this.title, this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 4, height: 16, color: const Color(0xFFE30613)),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.inter(
                  color: onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          if (onMoreTap != null)
            GestureDetector(
              onTap: onMoreTap,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: onSurface.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: onSurface.withValues(alpha: 0.5),
                  size: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
