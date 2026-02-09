import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/inventory_provider.dart';
import '../../shared/models/car.dart';
import '../../shared/widgets/common/hero_banner.dart';
import '../../shared/widgets/common/section_header.dart';
import '../../shared/widgets/car/premium_car_card.dart';
import '../../shared/widgets/status/weather_display.dart';
import '../../shared/widgets/common/tilt_parallax.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _heroController = PageController();
  int _currentHeroIndex = 0;

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = context.watch<InventoryProvider>();
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _buildBody(context, inventoryState, primaryColor, onSurface),
    );
  }

  Widget _buildBody(
    BuildContext context,
    InventoryProvider state,
    Color primaryColor,
    Color onSurface,
  ) {
    if (state.isLoading && state.cars.isEmpty) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (state.error != null && state.cars.isEmpty) {
      return Center(
        child: Text(
          'Error loading fleet',
          style: GoogleFonts.inter(color: onSurface),
        ),
      );
    }

    final cars = state.cars;

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

    final featuredCars = supercars.isNotEmpty
        ? supercars.take(3).toList()
        : cars.take(3).toList();

    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        if (isLandscape) {
          return _buildLandscapeLayout(
            context,
            featuredCars,
            supercars,
            suvs,
            sedans,
            coupes,
            cars,
          );
        } else {
          return _buildPortraitLayout(
            context,
            featuredCars,
            supercars,
            suvs,
            sedans,
            coupes,
            cars,
          );
        }
      },
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    List<Car> featuredCars,
    List<Car> supercars,
    List<Car> suvs,
    List<Car> sedans,
    List<Car> coupes,
    List<Car> allCars,
  ) {
    final featured = featuredCars.isNotEmpty ? featuredCars.first : null;

    return CustomScrollView(
      slivers: [
        if (featured != null)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    featured.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey[900]),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Theme.of(
                            context,
                          ).scaffoldBackgroundColor.withValues(alpha: 0.8),
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                        stops: const [0.0, 0.4, 0.8, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 40,
                    right: 40,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white30),
                                  borderRadius: BorderRadius.circular(4),
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
                              const SizedBox(height: 12),
                              Text(
                                featured.model.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                featured.brand.toUpperCase(),
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 14,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const WeatherDisplay(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(40, 32, 40, 16),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEGENDARY MOTORS',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Premium Fleet Collection',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          sliver: SliverToBoxAdapter(child: _buildLocationBanner(context)),
        ),

        if (supercars.isNotEmpty)
          _buildLandscapeGridSection(context, 'Supercars', supercars),
        if (suvs.isNotEmpty) _buildLandscapeGridSection(context, 'SUVs', suvs),
        if (sedans.isNotEmpty)
          _buildLandscapeGridSection(context, 'Luxury Sedans', sedans),
        if (coupes.isNotEmpty)
          _buildLandscapeGridSection(context, 'Sport Coupes', coupes),

        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }

  Widget _buildLandscapeGridSection(
    BuildContext context,
    String title,
    List<Car> cars,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(40, 24, 40, 0),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: title,
              onMoreTap: () {
                String cat = '';
                if (title.contains('Supercar')) cat = 'supercar';
                if (title.contains('SUV')) cat = 'suv';
                if (title.contains('Sedan')) cat = 'sedan';
                if (title.contains('Coupe')) cat = 'coupe';
                context.push('/inventory?category=$cat');
              },
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: cars.length > 6 ? 6 : cars.length,
              itemBuilder: (ctx, i) {
                return PremiumCarCard(car: cars[i], index: i);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    List<Car> featuredCars,
    List<Car> supercars,
    List<Car> suvs,
    List<Car> sedans,
    List<Car> coupes,
    List<Car> allCars,
  ) {
    final sectionList = [
      _buildLocationBanner(context),
      if (supercars.isNotEmpty) _buildSection(context, 'Supercars', supercars),
      if (suvs.isNotEmpty) _buildSection(context, 'SUVs', suvs),
      if (sedans.isNotEmpty) _buildSection(context, 'Luxury Sedans', sedans),
      if (coupes.isNotEmpty) _buildSection(context, 'Sport Coupes', coupes),
      if (allCars.isNotEmpty)
        _buildSection(context, 'Recently Added', allCars.reversed.toList()),
      const SizedBox(height: 48),
    ];

    return CustomScrollView(
      slivers: [
        _buildHeroSection(featuredCars),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sectionList,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(List<Car> featuredCars) {
    if (featuredCars.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverAppBar(
      expandedHeight: 500,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              controller: _heroController,
              itemCount: featuredCars.length,
              onPageChanged: (index) {
                setState(() {
                  _currentHeroIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return HeroBannerContent(
                  featured: featuredCars[index],
                  weatherDisplay: index == 0 ? const WeatherDisplay() : null,
                );
              },
            ),
            if (featuredCars.length > 1)
              Positioned(
                bottom: 120, // Adjust based on HeroBannerContent layout
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(featuredCars.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      width: _currentHeroIndex == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentHeroIndex == index
                            ? const Color(0xFFE30613)
                            : Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationBanner(BuildContext context) {
    return GestureDetector(
          onTap: () => context.push('/locations'),
          child: Container(
            height: 110,
            margin: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&q=80&w=800',
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.4),
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE30613).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFE30613,
                              ).withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PREMIUM SHOWROOMS',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Experience the fleet in person',
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        radius: 16,
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildSection(BuildContext context, String title, List<Car> cars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: SectionHeader(
            title: title,
            onMoreTap: () {
              String cat = '';
              if (title.contains('Supercar')) cat = 'supercar';
              if (title.contains('SUV')) cat = 'suv';
              if (title.contains('Sedan')) cat = 'sedan';
              if (title.contains('Coupe')) cat = 'coupe';
              context.push('/inventory?category=$cat');
            },
          ),
        ),
        SizedBox(
          height: 220, // Increased height for TiltParallax room
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ), // Vertical padding for shadows
            scrollDirection: Axis.horizontal,
            itemCount: cars.length,
            separatorBuilder: (ctx, i) => const SizedBox(width: 20),
            itemBuilder: (ctx, i) {
              final car = cars[i];
              return SizedBox(
                width: 280,
                child: TiltParallax(
                  intensity: 15,
                  child: PremiumCarCard(car: car, index: i),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
