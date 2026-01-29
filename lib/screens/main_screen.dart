import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/widgets/status/offline_banner.dart';
import '../shared/widgets/layout/premium_navigation_bar.dart';

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: PremiumNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}
