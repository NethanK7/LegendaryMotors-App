import 'package:flutter/material.dart';

/// Responsive breakpoint utilities
class ResponsiveUtils {
  // Breakpoints
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 1200;

  /// Check if current screen is phone size (portrait mobile)
  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < phoneMaxWidth;
  }

  /// Check if current screen is tablet size (landscape phone or small tablet)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= phoneMaxWidth && width < tabletMaxWidth;
  }

  /// Check if current screen is desktop size
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletMaxWidth;
  }

  /// Check if should show mobile layout (portrait phone)
  static bool shouldShowMobileLayout(BuildContext context) {
    return isPhone(context);
  }

  /// Check if should show sidebar navigation (landscape/tablet/desktop)
  static bool shouldShowSideNav(BuildContext context) {
    return !isPhone(context);
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(32);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    }
    return const EdgeInsets.all(16);
  }

  /// Get grid column count based on screen size
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }
}
