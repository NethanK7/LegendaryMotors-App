import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/inventory_provider.dart';
import '../../shared/models/car.dart';
import '../../shared/widgets/car/premium_car_card.dart';
import '../../shared/widgets/layout/sliver_page_header.dart';
import '../../shared/widgets/status/status_view.dart';

class InventoryScreen extends StatefulWidget {
  final String? category;
  const InventoryScreen({super.key, this.category});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late String _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All Models',
    'Supercars',
    'SUVs',
    'Motorbikes',
    'Luxury',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory =
        widget.category != null && _categories.contains(widget.category)
        ? widget.category!
        : 'All Models';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _buildBody(context, inventoryProvider, theme, isDark, onSurface),
    );
  }

  Widget _buildBody(
    BuildContext context,
    InventoryProvider state,
    ThemeData theme,
    bool isDark,
    Color onSurface,
  ) {
    if (state.isLoading && state.cars.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (state.error != null && state.cars.isEmpty) {
      return _buildErrorState(context);
    }

    final filteredCars = _getFilteredCars(state.cars);

    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return _buildLandscapeLayout(
            context,
            filteredCars,
            onSurface,
            isDark,
          );
        }
        return _buildPortraitLayout(
          context,
          filteredCars,
          onSurface,
          theme,
          isDark,
        );
      },
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    List<Car> cars,
    Color onSurface,
    ThemeData theme,
    bool isDark,
  ) {
    return CustomScrollView(
      slivers: [
        const SliverPageHeader(title: 'THE FLEET'),
        _buildSearchAndFilters(onSurface, theme, isDark, isLandscape: false),
        if (cars.isEmpty)
          _buildEmptyState(onSurface, isSliver: true)
        else
          _buildGridSliver(cars, isDark),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    List<Car> cars,
    Color onSurface,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.white10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'THE FLEET',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: onSurface,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: GoogleFonts.inter(color: onSurface),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: GoogleFonts.inter(
                        color: onSurface.withValues(alpha: 0.4),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: onSurface.withValues(alpha: 0.4),
                      ),
                      filled: true,
                      fillColor: onSurface.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _categories.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE30613)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white12,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category.toUpperCase(),
                                style: GoogleFonts.inter(
                                  color: isSelected ? Colors.white : onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          flex: 7,
          child: cars.isEmpty
              ? _buildEmptyState(onSurface, isSliver: false)
              : GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    return PremiumCarCard(
                      car: cars[index],
                      isDark: isDark,
                      index: index,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return StatusView(
      icon: Icons.error_outline,
      title: 'UNABLE TO LOAD FLEET',
      message: 'There was a problem connecting to our showroom.',
      buttonText: 'RETRY',
      onAction: () => Provider.of<InventoryProvider>(
        context,
        listen: false,
      ).fetchInventory(),
    );
  }

  List<Car> _getFilteredCars(List<Car> allCars) {
    return allCars.where((c) {
      final matchesSearch =
          c.model.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.brand.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;
      if (_selectedCategory == 'All Models') return true;

      final carCat = c.category.toLowerCase().trim();
      final selected = _selectedCategory.toLowerCase();

      if (selected == 'supercars') return carCat.contains('supercar');
      if (selected == 'suvs') return carCat.contains('suv');
      if (selected == 'motorbikes') {
        return carCat.contains('motorbike') || carCat.contains('motorcycle');
      }

      return carCat.contains(selected);
    }).toList();
  }

  Widget _buildSearchAndFilters(
    Color onSurface,
    ThemeData theme,
    bool isDark, {
    required bool isLandscape,
  }) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: GoogleFonts.inter(color: onSurface),
              decoration: InputDecoration(
                hintText: 'Search models, brands...',
                hintStyle: GoogleFonts.inter(
                  color: onSurface.withValues(alpha: 0.4),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: onSurface.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: onSurface.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (c, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = category);
                  },
                  backgroundColor: Colors.transparent,
                  selectedColor: const Color(0xFFE30613),
                  labelStyle: GoogleFonts.inter(
                    color: isSelected ? Colors.white : onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color onSurface, {required bool isSliver}) {
    return StatusView(
      icon: Icons.search_off,
      title: 'NO VEHICLES FOUND',
      message: 'No vehicles match your current search criteria.',
      isSliver: isSliver,
    );
  }

  Widget _buildGridSliver(List<Car> cars, bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1, // Full width in portrait
          mainAxisExtent: 280,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final car = cars[index];
          return PremiumCarCard(car: car, isDark: isDark, index: index);
        }, childCount: cars.length),
      ),
    );
  }
}
