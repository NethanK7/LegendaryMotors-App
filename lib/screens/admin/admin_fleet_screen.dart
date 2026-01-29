import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/car.dart';
import '../../services/car_service.dart';
import '../../providers/inventory_provider.dart';
import '../../shared/widgets/layout/premium_app_bar.dart';
import '../../shared/widgets/common/premium_badge.dart';

class AdminFleetScreen extends StatefulWidget {
  const AdminFleetScreen({super.key});

  @override
  State<AdminFleetScreen> createState() => _AdminFleetScreenState();
}

class _AdminFleetScreenState extends State<AdminFleetScreen> {
  late Future<List<Car>> _carsFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCars();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _carsFuture = Provider.of<CarService>(context, listen: false).getCars();
  }

  Future<void> _loadCars() async {
    setState(() {
      _carsFuture = Provider.of<CarService>(context, listen: false).getCars();
    });
    await _carsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PremiumAppBar(
        title: 'FLEET MANAGEMENT',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFE30613)),
            onPressed: () {
              context.push('/admin/add');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Car>>(
        future: _carsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE30613)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final cars = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: _loadCars,
            child: ListView.builder(
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: car.imageUrl.isNotEmpty
                        ? Image.network(
                            car.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) => const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          )
                        : const Icon(Icons.directions_car, color: Colors.white),
                    title: Text(
                      '${car.brand} ${car.model}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: PremiumBadge(
                      text: '\$${car.price.toInt()}',
                      color: Colors.white10,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            context.push('/admin/edit/${car.id}', extra: car);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Confirm delete
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: Colors.grey[900],
                                title: const Text(
                                  'Delete Car',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: const Text(
                                  'Are you sure you want to delete this car?',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(ctx).pop(); // Close dialog

                                      final carService =
                                          Provider.of<CarService>(
                                            context,
                                            listen: false,
                                          );
                                      final inventoryProvider =
                                          Provider.of<InventoryProvider>(
                                            context,
                                            listen: false,
                                          );
                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );

                                      try {
                                        await carService.deleteCar(car.id);

                                        if (mounted) {
                                          // Refresh local list
                                          _loadCars();

                                          // Update global inventory
                                          inventoryProvider.fetchInventory();
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Car deleted successfully',
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text('Error: $e'),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
