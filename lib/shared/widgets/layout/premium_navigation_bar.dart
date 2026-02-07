import 'dart:ui';
import 'package:flutter/material.dart';

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
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), // 15% radius ≈ 24px
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'HOME',
                  index: 0,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.directions_car_outlined,
                  activeIcon: Icons.directions_car,
                  label: 'FLEET',
                  index: 1,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.favorite_border,
                  activeIcon: Icons.favorite,
                  label: 'GARAGE',
                  index: 2,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'PROFILE',
                  index: 3,
                ),
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

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Center(
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive
                    ? const Color(0xFFE30613)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
