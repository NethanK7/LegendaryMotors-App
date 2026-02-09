import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../common/glass_container.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final String backgroundUrl;
  final List<Widget>? footerActions;
  final Widget? logo;

  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.backgroundUrl,
    this.footerActions,
    this.logo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                backgroundUrl,
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: 0.7),
                colorBlendMode: BlendMode.darken,
              ).animate().fadeIn(duration: 1000.ms),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 48,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isLandscape ? 500 : 400,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            if (logo != null) ...[
                              logo!,
                              const SizedBox(height: 16),
                            ],
                            Text(
                                  title.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 0.9,
                                    letterSpacing: -1.0,
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .moveY(begin: 20, end: 0),
                            const SizedBox(height: 12),
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: Colors.grey,
                                fontSize: 12,
                                letterSpacing: 1.0,
                              ),
                            ).animate().fadeIn(delay: 600.ms),
                          ],
                        ),

                        const SizedBox(height: 48),

                        GlassContainer(
                              borderRadius: BorderRadius.circular(0),
                              child: child,
                            )
                            .animate()
                            .fadeIn(delay: 800.ms)
                            .moveY(begin: 30, end: 0),

                        if (footerActions != null) ...[
                          const SizedBox(height: 24),
                          ...footerActions!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
