import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SliverPageHeader extends StatelessWidget {
  final String title;
  final Color? backgroundColor;

  const SliverPageHeader({
    super.key,
    required this.title,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: 120,
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 24,
            color: onSurface,
          ),
        ),
      ),
    );
  }
}
