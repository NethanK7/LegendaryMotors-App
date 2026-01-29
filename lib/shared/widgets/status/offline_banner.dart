import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final result = snapshot.data;
        if (result == ConnectivityResult.none) {
          return Container(
            color: const Color(0xFFE30613), // Red warning
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            width: double.infinity,
            child: const Text(
              'YOU ARE OFFLINE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 2.0,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
