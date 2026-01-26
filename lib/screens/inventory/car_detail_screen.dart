import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../shared/models/car.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/inventory_provider.dart';

class CarDetailScreen extends ConsumerStatefulWidget {
  final int carId;
  final Car? car;

  const CarDetailScreen({super.key, required this.carId, this.car});

  @override
  ConsumerState<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends ConsumerState<CarDetailScreen> {
  // Mock Configuration State
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
              decoration: BoxDecoration(
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
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12),

                  Expanded(
                    child: ListView(
                      children: [
                        // Exterior Color
                        _buildSectionHeader('EXTERIOR FINISH'),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(_colors.length, (index) {
                            return GestureDetector(
                              onTap: () {
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

                        // Wheels
                        _buildSectionHeader('WHEELS'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: List.generate(_wheelOptions.length, (
                            index,
                          ) {
                            final isSelected = _selectedWheels == index;
                            final price = index == 0
                                ? 0
                                : index == 1
                                ? 5000
                                : 12000;
                            return ChoiceChip(
                              label: Text(
                                "${_wheelOptions[index].toUpperCase()} ${price > 0 ? '(+\$$price)' : ''}",
                              ),
                              selected: isSelected,
                              selectedColor: const Color(0xFFE30613),
                              backgroundColor: Colors.black,
                              labelStyle: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (v) {
                                setModalState(() => _selectedWheels = index);
                                setState(() => _selectedWheels = index);
                              },
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.white24,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 32),

                        // Interior
                        _buildSectionHeader('INTERIOR'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: List.generate(_interiorOptions.length, (
                            index,
                          ) {
                            final isSelected = _selectedInterior == index;
                            final price = index == 0
                                ? 0
                                : index == 1
                                ? 15000
                                : 25000;
                            return ChoiceChip(
                              label: Text(
                                "${_interiorOptions[index].toUpperCase()} ${price > 0 ? '(+\$$price)' : ''}",
                              ),
                              selected: isSelected,
                              selectedColor: const Color(0xFFE30613),
                              backgroundColor: Colors.black,
                              labelStyle: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (v) {
                                setModalState(() => _selectedInterior = index);
                                setState(() => _selectedInterior = index);
                              },
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.white24,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Calculate final price
                        double addOns = 0;
                        // Wheel prices: 0, 5000, 12000
                        addOns += _selectedWheels == 0
                            ? 0
                            : _selectedWheels == 1
                            ? 5000
                            : 12000;
                        // Interior prices: 0, 15000, 25000
                        addOns += _selectedInterior == 0
                            ? 0
                            : _selectedInterior == 1
                            ? 15000
                            : 25000;
                        // Color prices: Black/White 0, Grey 2000, Red 5000
                        addOns += _selectedColor <= 1
                            ? 0
                            : _selectedColor == 2
                            ? 2000
                            : 5000;

                        final totalPrice = car.price + addOns;

                        Navigator.pop(context); // Close modal
                        context.push(
                          '/checkout',
                          extra: {
                            'car': car,
                            'config': {
                              'color': _colors[_selectedColor].toARGB32(),
                              'wheels': _wheelOptions[_selectedWheels],
                              'interior': _interiorOptions[_selectedInterior],
                              'totalPrice': totalPrice,
                            },
                          },
                        ); // Proceed
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: Builder(
                        builder: (context) {
                          double addOns = 0;
                          addOns += _selectedWheels == 0
                              ? 0
                              : _selectedWheels == 1
                              ? 5000
                              : 12000;
                          addOns += _selectedInterior == 0
                              ? 0
                              : _selectedInterior == 1
                              ? 15000
                              : 25000;
                          addOns += _selectedColor <= 1
                              ? 0
                              : _selectedColor == 2
                              ? 2000
                              : 5000;
                          final total = car.price + addOns;

                          return Text(
                            'CONFIRM & REQUEST (\$${total.toStringAsFixed(0)})',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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

    // If we have the car object passed in, use it. Otherwise fetch from provider.
    Car? displayCar = widget.car;

    if (displayCar == null) {
      final inventoryState = ref.watch(inventoryProvider);
      displayCar = inventoryState.maybeWhen(
        data: (cars) => cars.firstWhere((c) => c.id == widget.carId,
            orElse: () => cars.first),
        orElse: () => null,
      );
    }

    if (displayCar == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final car = displayCar;
    final favoritesState = ref.watch(favoritesProvider);
    final boolisFavorite = favoritesState.maybeWhen(
      data: (favs) => favs.any((f) => f.id == car.id),
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return _buildLandscapeLayout(car, boolisFavorite, isDark, onSurface, theme);
          } else {
            return _buildPortraitLayout(car, boolisFavorite, isDark, onSurface, theme);
          }
        },
      ),
    );
  }

  Widget _buildPortraitLayout(Car car, bool boolisFavorite, bool isDark, Color onSurface, ThemeData theme) {
    return CustomScrollView(
      slivers: [
        _buildHeroImage(car, isDark, onSurface),
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
                _buildActions(car, boolisFavorite, onSurface, theme),
                const SizedBox(height: 32),
                _buildDescription(car, onSurface),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(Car car, bool boolisFavorite, bool isDark, Color onSurface, ThemeData theme) {
    return Row(
      children: [
        // Left: Image
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
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () => context.pop(),
                ),
              ),
            ],
          ),
        ),
        // Right: Details
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
                _buildActions(car, boolisFavorite, onSurface, theme),
                const SizedBox(height: 32),
                _buildDescription(car, onSurface),
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
        Text(
          '\$${car.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
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
        _buildSpecItem(
          '${car.specs['hp'] ?? 'N/A'}',
          'HP',
          onSurface,
        ),
        const SizedBox(width: 32),
        _buildSpecItem(
          '${car.specs['0_60'] ?? 'N/A'}s',
          '0-60',
          onSurface,
        ),
        const SizedBox(width: 32),
        _buildSpecItem(
          '${car.specs['top_speed'] ?? 'N/A'}',
          'MPH',
          onSurface,
        ),
      ],
    );
  }

  Widget _buildSpecItem(String value, String label, Color onSurface) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            color: onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: onSurface.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(Car car, bool boolisFavorite, Color onSurface, ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showConfigurator(car),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE30613),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              'CONFIGURE & ORDER',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(favoritesProvider.notifier).toggleFavorite(car.id);
                },
                icon: Icon(
                  boolisFavorite ? Icons.check : Icons.add,
                  color: onSurface,
                ),
                label: Text(
                  "MY LIST",
                  style: GoogleFonts.inter(color: onSurface),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: onSurface.withValues(alpha: 0.2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
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
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: car.imageUrl,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) =>
                  Container(color: Colors.grey[900]),
            ),
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
    );
  }
}
