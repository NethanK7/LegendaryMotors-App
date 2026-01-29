import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PremiumNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        color: theme.scaffoldBackgroundColor,
      ),
      child: Theme(
        data: theme.copyWith(
          canvasColor: theme.scaffoldBackgroundColor,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: theme.scaffoldBackgroundColor,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFE30613), // Brabus Red
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 1.0,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 10,
            letterSpacing: 1.0,
          ),
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car_outlined),
              activeIcon: Icon(Icons.directions_car),
              label: 'FLEET',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'GARAGE',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }
}
