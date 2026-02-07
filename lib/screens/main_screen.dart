import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/widgets/status/offline_banner.dart';
import '../shared/widgets/layout/premium_navigation_bar.dart';
import '../shared/widgets/layout/side_navigation.dart';
import '../shared/utils/responsive_utils.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:developer' as developer;

class MainScreen extends StatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  StreamSubscription? _accelerometerSubscription;
  DateTime? _lastShake;

  @override
  void initState() {
    super.initState();
    _initShake();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _initShake() {
    // Basic shake detection: If combined acceleration exceeds a threshold
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final double total = event.x.abs() + event.y.abs() + event.z.abs();
      if (total > 15) {
        // High threshold for shake
        final now = DateTime.now();
        if (_lastShake == null ||
            now.difference(_lastShake!) > const Duration(seconds: 2)) {
          _lastShake = now;
          _onShakeDetected();
        }
      }
    });

    // Handle PWA sensor permissions if needed
    if (kIsWeb) {
      _requestSensorPermission();
    }
  }

  void _requestSensorPermission() {
    // This is handled by user interaction in most modern browsers
    // We can trigger a snackbar or subtle hint
    developer.log('PWA: Sensors initialized', name: 'MainScreen');
  }

  void _onShakeDetected() {
    if (mounted) {
      final location = GoRouterState.of(context).uri.toString();
      if (location == '/contact') return;

      context.push('/contact');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shake detected! Connecting you to Concierge...'),
          backgroundColor: Color(0xFFE30613),
        ),
      );
    }
  }

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
