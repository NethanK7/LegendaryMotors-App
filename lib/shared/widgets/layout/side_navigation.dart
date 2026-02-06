import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SideNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SideNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 80,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        Colors.grey[900]!.withValues(alpha: 0.8),
                        Colors.grey[850]!.withValues(alpha: 0.7),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.8),
                        Colors.white.withValues(alpha: 0.6),
                      ],
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                _buildNavItem(
                  context,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  index: 0,
                ),
                const SizedBox(height: 16),
                _buildNavItem(
                  context,
                  icon: Icons.directions_car_outlined,
                  activeIcon: Icons.directions_car,
                  label: 'Fleet',
                  index: 1,
                ),
                const SizedBox(height: 16),
                _buildNavItem(
                  context,
                  icon: Icons.favorite_border,
                  activeIcon: Icons.favorite,
                  label: 'Garage',
                  index: 2,
                ),
                const SizedBox(height: 16),
                _buildNavItem(
                  context,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Profile',
                  index: 3,
                ),
                const Spacer(),
                // Brand logo at bottom
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.directions_car,
                    color: const Color(0xFFE30613),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;
    final theme = Theme.of(context);

    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: 56,
            height: 56,
            decoration: isActive
                ? BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE30613), Color(0xFFB00510)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE30613).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  )
                : null,
            child: Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? Colors.white
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
