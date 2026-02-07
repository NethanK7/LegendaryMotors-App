import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/widgets/status/offline_banner.dart';
import '../shared/widgets/layout/premium_navigation_bar.dart';
import '../shared/widgets/layout/side_navigation.dart';
import '../shared/utils/responsive_utils.dart';

class MainScreen extends StatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/inventory');
        break;
      case 2:
        context.go('/favorites');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/inventory')) return 1;
    if (location.startsWith('/favorites')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _calculateSelectedIndex(context);
    final theme = Theme.of(context);
    final showMobileLayout = ResponsiveUtils.shouldShowMobileLayout(context);

    if (showMobileLayout) {
      // Mobile portrait: Floating bottom nav
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 80,
                ), // Space for floating nav
                child: widget.child,
              ),
            ),
          ],
        ),
        bottomNavigationBar: PremiumNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => _onItemTapped(index, context),
        ),
        extendBody: true, // Allow content to go behind the floating nav
      );
    } else {
      // Landscape/Tablet/Desktop: Side navigation
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Row(
          children: [
            SideNavigation(
              currentIndex: selectedIndex,
              onTap: (index) => _onItemTapped(index, context),
            ),
            Expanded(
              child: Column(
                children: [
                  const OfflineBanner(),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
