import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../shared/models/car.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../shared/widgets/car/car_spec_item.dart';
import '../../shared/widgets/common/premium_button.dart';
import '../../shared/widgets/common/tilt_parallax.dart';
import '../../shared/widgets/car/performance_meter.dart';

class CarDetailScreen extends StatefulWidget {
  final int carId;
  final Car? car;

  const CarDetailScreen({super.key, required this.carId, this.car});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  int _selectedColor = 0;
  int _selectedWheels = 0;
  int _selectedInterior = 0;

  final List<Color> _colors = [
    Colors.black,
    Colors.white,
    Colors.grey.shade800,
    const Color(0xFFE30613), // Brabus Red
  ];

  final List<String> _wheelOptions = [
    'Monoblock Z Platinum',
    'Monoblock Y Black',
    'Monoblock F Cross',
  ];

  final List<String> _interiorOptions = [
    'Mastic Leather Black',
    'Porcelain / Espresso',
    'Royal Blue / Carbon',
  ];

  void _showConfigurator(Car car) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF111111),
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CONFIGURE YOUR SPEC',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12),

                  Expanded(
                    child: ListView(
                      children: [
                        _buildSectionHeader('EXTERIOR FINISH'),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(_colors.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                // Update modal UI and parent screen UI
                                setModalState(() => _selectedColor = index);
                                setState(() => _selectedColor = index);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 16),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _colors[index],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedColor == index
                                        ? const Color(0xFFE30613)
                                        : Colors.white24,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 32),

                        _buildSectionHeader('WHEELS'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: List.generate(_wheelOptions.length, (
                            index,
                          ) {
                            final isSelected = _selectedWheels == index;
                            return ChoiceChip(
                              label: Text(_wheelOptions[index].toUpperCase()),
                              selected: isSelected,
                              selectedColor: const Color(0xFFE30613),
                              onSelected: (v) {
                                setModalState(() => _selectedWheels = index);
                                setState(() => _selectedWheels = index);
                              },
                            );
                          }),
                        ),
                        const SizedBox(height: 32),

                        _buildSectionHeader('INTERIOR'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: List.generate(_interiorOptions.length, (
                            index,
                          ) {
                            final isSelected = _selectedInterior == index;
                            return ChoiceChip(
                              label: Text(
                                _interiorOptions[index].toUpperCase(),
                              ),
                              selected: isSelected,
                              selectedColor: const Color(0xFFE30613),
                              onSelected: (v) {
                                setModalState(() => _selectedInterior = index);
                                setState(() => _selectedInterior = index);
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  PremiumButton(
                    text: 'CONFIRM & REQUEST',
                    onPressed: () {
                      // Note: Calc logic for price can be added here
                      Navigator.pop(context); // Close modal
                      // Navigate to checkout with the selected configuration
                      context.push('/checkout', extra: {'car': car});
                    },
                    isPrimary: false,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDescription(Car car, Color onSurface) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ABOUT THIS VEHICLE',
          style: GoogleFonts.inter(
            color: onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Experience the pinnacle of automotive engineering with the ${car.brand} ${car.model}. '
          'This masterpiece combines raw power with refined luxury, delivering an unparalleled driving experience. '
          'Every detail has been meticulously crafted to exceed expectations.',
          style: GoogleFonts.inter(
            color: onSurface.withValues(alpha: 0.7),
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    Car? displayCar = widget.car;
    if (displayCar == null) {
      final inventoryState = context.watch<InventoryProvider>();
      if (inventoryState.cars.isNotEmpty) {
        displayCar = inventoryState.cars.firstWhere(
          (c) => c.id == widget.carId,
          orElse: () => inventoryState.cars.first,
        );
      }
    }

    if (displayCar == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final car = displayCar;
    final favoritesProvider = context.watch<FavoritesProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isFavorite = favoritesProvider.favorites.any(
            (f) => f.id == car.id,
          );

          if (orientation == Orientation.landscape) {
            return _buildLandscapeLayout(
              car,
              isFavorite,
              isDark,
              onSurface,
              theme,
            );
          } else {
            return _buildPortraitLayout(
              car,
              isFavorite,
              isDark,
              onSurface,
              theme,
            );
          }
        },
      ),
    );
  }

  // PORTRAIT VIEW (Traditional mobile scroll)
  Widget _buildPortraitLayout(
    Car car,
    bool isFavorite,
    bool isDark,
    Color onSurface,
    ThemeData theme,
  ) {
    return CustomScrollView(
      slivers: [
        // 1. Cinematic Header image that shrinks/expands as you scroll
        _buildHeroImage(car, isDark, onSurface),

        // 2. The rest of the content inside a scrollable list
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(car, onSurface),
                const SizedBox(height: 24),
                _buildSpecs(car, onSurface),
                const SizedBox(height: 32),
                _buildActions(car, isFavorite, onSurface, theme),
                const SizedBox(height: 32),
                _buildDescription(car, onSurface),
                const SizedBox(height: 32),
                const PerformanceMeter(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // LANDSCAPE VIEW (Optimized for tablets/rotated phones)
  Widget _buildLandscapeLayout(
    Car car,
    bool isFavorite,
    bool isDark,
    Color onSurface,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: car.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (c, u, e) => Container(color: Colors.grey[900]),
              ),
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(car, onSurface),
                const SizedBox(height: 24),
                _buildSpecs(car, onSurface),
                const SizedBox(height: 32),
                _buildActions(car, isFavorite, onSurface, theme),
                const SizedBox(height: 32),
                _buildDescription(car, onSurface),
                const SizedBox(height: 32),
                const PerformanceMeter(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Car car, Color onSurface) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          car.brand.toUpperCase(),
          style: GoogleFonts.inter(
            color: onSurface.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          car.model.toUpperCase(),
          style: GoogleFonts.inter(
            color: onSurface,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        // Price formatting with commas (e.g., $250,000)
        Text(
          '\$${car.price.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
          style: GoogleFonts.inter(
            color: const Color(0xFFE30613),
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecs(Car car, Color onSurface) {
    return Row(
      children: [
        CarSpecItem(value: '${car.specs['hp'] ?? 'N/A'}', label: 'HP'),
        const SizedBox(width: 32),
        CarSpecItem(value: '${car.specs['0_60'] ?? 'N/A'}s', label: '0-60'),
        const SizedBox(width: 32),
        CarSpecItem(value: '${car.specs['top_speed'] ?? 'N/A'}', label: 'MPH'),
      ],
    );
  }

  // Actions: Confirguration and Favorites
  Widget _buildActions(
    Car car,
    bool isFavorite,
    Color onSurface,
    ThemeData theme,
  ) {
    return Column(
      children: [
        PremiumButton(
          text: 'CONFIGURE & ORDER',
          onPressed: () => _showConfigurator(car),
        ),
        const SizedBox(height: 12),
        PremiumButton(
          text: isFavorite ? "ON MY LIST" : "ADD TO LIST",
          onPressed: () => Provider.of<FavoritesProvider>(
            context,
            listen: false,
          ).toggleFavorite(car.id),
          icon: isFavorite ? Icons.check : Icons.add,
          isPrimary: false,
        ),
      ],
    );
  }

  SliverAppBar _buildHeroImage(Car car, bool isDark, Color onSurface) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: isDark ? Colors.black : Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: onSurface),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: TiltParallax(
          intensity: 15,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: car.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    Container(color: Colors.grey[900]),
              ),
              // Gradient Overlay makes the text on top more readable
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      isDark
                          ? Colors.black.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
