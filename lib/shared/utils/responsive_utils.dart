import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 1200;

  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < phoneMaxWidth;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= phoneMaxWidth && width < tabletMaxWidth;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletMaxWidth;
  }

  static bool shouldShowMobileLayout(BuildContext context) {
    return isPhone(context);
  }

  static bool shouldShowSideNav(BuildContext context) {
    return !isPhone(context);
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(32);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    }
    return const EdgeInsets.all(16);
  }

  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }
}
