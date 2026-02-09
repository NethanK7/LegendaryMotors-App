import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../models/car.dart';
import 'premium_button.dart';

class HeroBanner extends StatelessWidget {
  final Car? featured;
  final Widget? weatherDisplay;

  const HeroBanner({super.key, required this.featured, this.weatherDisplay});

  @override
  Widget build(BuildContext context) {
    if (featured == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 500,
      backgroundColor: theme.scaffoldBackgroundColor,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: HeroBannerContent(
          featured: featured!,
          weatherDisplay: weatherDisplay,
        ),
      ),
    );
  }
}

class HeroBannerContent extends StatelessWidget {
  final Car featured;
  final Widget? weatherDisplay;

  const HeroBannerContent({
    super.key,
    required this.featured,
    this.weatherDisplay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          featured.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Image.network(
            'https://images.unsplash.com/photo-1617788138017-80ad40651399?q=80&w=2070&auto=format&fit=crop',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.transparent,
                theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                theme.scaffoldBackgroundColor,
              ],
              stops: const [0.0, 0.4, 0.8, 1.0],
            ),
          ),
        ),

        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white30),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  'FEATURED VEHICLE',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              Text(
                featured.model.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: onSurface,
                  height: 0.9,
                  letterSpacing: -1.0,
                  shadows: [
                    Shadow(
                      color: isDark ? Colors.black : Colors.white,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 800.ms).moveY(begin: 30, end: 0),

              const SizedBox(height: 8),
              Text(
                featured.brand.toUpperCase(),
                style: GoogleFonts.inter(
                  color: onSurface.withValues(alpha: 0.7),
                  fontSize: 14,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PremiumButton(
                    text: 'DETAILS',
                    onPressed: () => context.push(
                      '/inventory/car/${featured.id}',
                      extra: featured,
                    ),
                    icon: Icons.info_outline,
                    isPrimary: isDark, // If dark theme, primary is white
                    width: 140,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  const SizedBox(width: 16),
                  PremiumButton(
                    text: 'MY LIST',
                    onPressed: () => context.push('/favorites'),
                    icon: Icons.add,
                    isPrimary: false,
                    width: 140,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms).moveY(begin: 20, end: 0),
            ],
          ),
        ),

        if (weatherDisplay != null)
          Positioned(top: 48, left: 24, child: weatherDisplay!),
      ],
    );
  }
}
