import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const PremiumAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: leading,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
