import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/widgets/sliver_page_header.dart';
import '../../shared/models/location.dart';
import '../../shared/widgets/location_list_item.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  Position? _currentPosition;

  late final MapController _mapController;

  final List<Location> _locations = [
    Location(
      name: 'Legendary Motors Colombo',
      address: 'Lotus Tower Rd, Colombo 01, Sri Lanka',
      lat: 6.9271,
      lng: 79.8612,
      imageUrl:
          'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&q=80&w=800',
    ),
    Location(
      name: 'Kandy Heritage Showroom',
      address: 'Dalada Veediya, Kandy, Sri Lanka',
      lat: 7.2906,
      lng: 80.6337,
      imageUrl:
          'https://images.unsplash.com/photo-1582650625119-3a31f8fa2699?auto=format&fit=crop&q=80&w=800',
    ),
    Location(
      name: 'Galle Fort Atelier',
      address: 'Church Street, Galle Fort, Sri Lanka',
      lat: 6.0535,
      lng: 80.2210,
      imageUrl:
          'https://images.unsplash.com/photo-1533106497176-45ae19e68ba2?auto=format&fit=crop&q=80&w=800',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    setState(() => _currentPosition = pos);
  }

  double _calculateDistance(double lat, double lng) {
    if (_currentPosition == null) return 0;
    return Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          lat,
          lng,
        ) /
        1000; // to KM
  }

  void _onLocationTap(Location loc) {
    _mapController.move(latlong.LatLng(loc.lat, loc.lng), 15);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return Row(
              children: [
                // Map Panel (Left)
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: onSurface.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: Stack(
                      children: [
                        _buildMapContent(onSurface, radius: 0),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                'LOCATIONS',
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  shadows: [
                                    const Shadow(
                                      color: Colors.black,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // List Panel (Right)
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _locations.length,
                    itemBuilder: (context, index) {
                      final loc = _locations[index];
                      final dist = _calculateDistance(loc.lat, loc.lng);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child:
                            LocationListItem(
                                  location: loc,
                                  distanceInKm: dist,
                                  onTap: () => _onLocationTap(loc),
                                )
                                .animate()
                                .fadeIn(delay: (100 * index).ms)
                                .moveX(begin: 20, end: 0),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          // Portrait Layout
          return CustomScrollView(
            slivers: [
              const SliverPageHeader(
                title: 'LOCATIONS',
                backgroundColor: Colors.transparent,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    height: 250,
                    child: _buildMapContent(onSurface),
                  ),
                ),
              ),
              _buildLocationsListSliver(theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMapContent(Color onSurface, {double radius = 24}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: onSurface.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const latlong.LatLng(
              7.8731,
              80.7718,
            ), // Sri Lanka Center
            initialZoom: 7,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.mobile_app',
            ),
            MarkerLayer(
              markers: _locations.map((loc) {
                return Marker(
                  point: latlong.LatLng(loc.lat, loc.lng),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () {
                      _mapController.move(latlong.LatLng(loc.lat, loc.lng), 15);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${loc.name}: ${loc.address}'),
                          backgroundColor: Colors.black,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFFE30613),
                      size: 40,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildLocationsListSliver(ThemeData theme) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final loc = _locations[index];
          final dist = _calculateDistance(loc.lat, loc.lng);

          return LocationListItem(
            location: loc,
            distanceInKm: dist,
            onTap: () => _onLocationTap(loc),
          ).animate().fadeIn(delay: (200 * index).ms).moveX(begin: 20, end: 0);
        }, childCount: _locations.length),
      ),
    );
  }
}
