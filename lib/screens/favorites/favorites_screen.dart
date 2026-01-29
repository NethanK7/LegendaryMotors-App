import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/orders_provider.dart';
import '../../shared/models/car.dart';
import '../../shared/widgets/car/premium_car_card.dart';
import '../../shared/widgets/status/status_view.dart';
import '../../shared/widgets/common/premium_badge.dart';
import '../../shared/widgets/layout/premium_app_bar.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: PremiumAppBar(
          title: 'YOUR GARAGE',
          bottom: TabBar(
            indicatorColor: const Color(0xFFE30613),
            labelColor: const Color(0xFFE30613),
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
            tabs: const [
              Tab(text: 'MY COLLECTION'),
              Tab(text: 'WISHLIST'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                Provider.of<FavoritesProvider>(
                  context,
                  listen: false,
                ).fetchFavorites();
                Provider.of<OrdersProvider>(
                  context,
                  listen: false,
                ).fetchOrders();
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [_PurchasedCarsTab(), _FavoriteCarsTab()],
        ),
      ),
    );
  }
}

class _PurchasedCarsTab extends StatelessWidget {
  const _PurchasedCarsTab();

  @override
  Widget build(BuildContext context) {
    final ordersState = context.watch<OrdersProvider>();

    if (ordersState.isLoading && ordersState.orders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE30613)),
      );
    }

    if (ordersState.error != null && ordersState.orders.isEmpty) {
      return StatusView(
        icon: Icons.error_outline,
        title: 'UNABLE TO LOAD COLLECTION',
        message: 'There was a problem connecting to our showroom.',
        buttonText: 'RETRY',
        onAction: () =>
            Provider.of<OrdersProvider>(context, listen: false).fetchOrders(),
      );
    }

    final cars = ordersState.orders;
    if (cars.isEmpty) {
      return StatusView(
        icon: Icons.garage_outlined,
        title: 'COLLECTION EMPTY',
        message: 'You haven\'t purchased any vehicles yet.',
        buttonText: 'VISIT SHOWROOM',
        onAction: () => context.go('/inventory'),
      );
    }
    return _CarList(cars: cars, isPurchased: true);
  }
}

class _FavoriteCarsTab extends StatelessWidget {
  const _FavoriteCarsTab();

  @override
  Widget build(BuildContext context) {
    final favoritesState = context.watch<FavoritesProvider>();

    if (favoritesState.isLoading && favoritesState.favorites.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE30613)),
      );
    }

    if (favoritesState.error != null && favoritesState.favorites.isEmpty) {
      return StatusView(
        icon: Icons.error_outline,
        title: 'UNABLE TO LOAD WISHLIST',
        message: 'There was a problem connecting to our showroom.',
        buttonText: 'RETRY',
        onAction: () => Provider.of<FavoritesProvider>(
          context,
          listen: false,
        ).fetchFavorites(),
      );
    }

    final cars = favoritesState.favorites;
    if (cars.isEmpty) {
      return StatusView(
        icon: Icons.favorite_border,
        title: 'WISHLIST EMPTY',
        message: 'Save your dream configurations here.',
        buttonText: 'BROWSE CARS',
        onAction: () => context.go('/inventory'),
      );
    }
    return _CarList(cars: cars, isPurchased: false);
  }
}

class _CarList extends StatelessWidget {
  final List<Car> cars;
  final bool isPurchased;

  const _CarList({required this.cars, required this.isPurchased});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              return PremiumCarCard(
                car: cars[index],
                index: index,
                isDark: true,
              );
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cars.length,
          itemBuilder: (context, index) {
            final car = cars[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GestureDetector(
                onTap: () => context.go('/inventory/car/${car.id}', extra: car),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    border: Border.all(
                      color: isPurchased
                          ? const Color(0xFFE30613)
                          : Colors.white10,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 60,
                        child: car.imageUrl.isNotEmpty
                            ? Image.network(
                                car.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) =>
                                    Container(color: Colors.grey[900]),
                              )
                            : Container(color: Colors.grey[900]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.brand.toUpperCase(),
                              style: GoogleFonts.inter(
                                color: const Color(0xFFE30613),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              car.model.toUpperCase(),
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            if (isPurchased) ...[
                              const SizedBox(height: 4),
                              const PremiumBadge(
                                text: 'OWNED',
                                color: Colors.white,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
