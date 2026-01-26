import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/inventory_provider.dart';
import '../../shared/models/car.dart';
import '../../shared/widgets/hero_banner.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/car_card.dart';
import '../../shared/widgets/weather_display.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryState = ref.watch(inventoryProvider);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: inventoryState.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: primaryColor)),
        error: (e, s) => Center(
          child: Text(
            'Error loading fleet',
            style: GoogleFonts.inter(color: onSurface),
          ),
        ),
        data: (cars) {
          // Filter cars for sections (Basic filtering for demo)
          final supercars = cars
              .where((c) => c.category.toLowerCase().contains('supercar'))
              .toList();
          final suvs = cars
              .where((c) => c.category.toLowerCase().contains('suv'))
              .toList();
          final sedans = cars
              .where((c) => c.category.toLowerCase().contains('sedan'))
              .toList();
          final coupes = cars
              .where((c) => c.category.toLowerCase().contains('coupe'))
              .toList();
          final featured = cars.isNotEmpty ? cars.first : null;

          return OrientationBuilder(
            builder: (context, orientation) {
              final isLandscape = orientation == Orientation.landscape;

              // SECTION LIST (Shared Logic)
              final sectionList = [
                // Find Nearest Showroom Banner (Standard Widget version)
                GestureDetector(
                  onTap: () => context.push('/locations'),
                  child: Container(
                    height: 100,
                    margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF111111),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&q=80&w=800',
                        ),
                        fit: BoxFit.cover,
                        opacity: 0.3,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFFE30613),
                          size: 30,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VISIT A SHOWROOM',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              'Find the nearest Legendary Motors outlet',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white24,
                          size: 16,
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).moveY(begin: 20, end: 0),

                if (supercars.isNotEmpty)
                  _buildSection(context, 'Supercars', supercars),
                if (suvs.isNotEmpty) _buildSection(context, 'SUVs', suvs),
                if (sedans.isNotEmpty)
                  _buildSection(context, 'Luxury Sedans', sedans),
                if (coupes.isNotEmpty)
                  _buildSection(context, 'Sport Coupes', coupes),
                if (cars.isNotEmpty)
                  _buildSection(
                    context,
                    'Recently Added',
                    cars.reversed.toList(),
                  ),
                const SizedBox(height: 48),
              ];

              if (isLandscape) {
                // LANDSCAPE LAYOUT
                return Row(
                  children: [
                    // Left Panel: Hero Banner
                    if (featured != null)
                      Expanded(
                        flex: 5,
                        child: HeroBannerContent(
                          featured: featured,
                          weatherDisplay: const WeatherDisplay(),
                        ),
                      ),
                    // Right Panel: Scrollable Content
                    Expanded(
                      flex: 4,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: sectionList,
                      ),
                    ),
                  ],
                );
              } else {
                // PORTRAIT LAYOUT
                return CustomScrollView(
                  slivers: [
                    // 1. Reusable Hero Banner (Sliver)
                    HeroBanner(
                      featured: featured,
                      weatherDisplay: const WeatherDisplay(),
                    ),

                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: sectionList,
                      ),
                    ),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Car> cars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          onMoreTap: () {
            // Navigate to inventory with filter logic
            String cat = '';
            if (title.contains('Supercar')) cat = 'supercar';
            if (title.contains('SUV')) cat = 'suv';
            if (title.contains('Sedan')) cat = 'sedan';
            if (title.contains('Coupe')) cat = 'coupe';
            context.push('/inventory?category=$cat');
          },
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: cars.length,
            separatorBuilder: (ctx, i) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) {
              final car = cars[i];
              return CarCard(
                car: car,
                onTap: () =>
                    context.push('/inventory/car/${car.id}', extra: car),
              );
            },
          ),
        ),
      ],
    );
  }
}
