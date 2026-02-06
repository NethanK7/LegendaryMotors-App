import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dio/dio.dart';
import '../../shared/widgets/layout/sliver_page_header.dart';
import '../../shared/models/location.dart';
import '../../shared/widgets/common/location_list_item.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  Position? _currentPosition;
  List<latlong.LatLng> _routePoints = [];
  bool _isRouting = false;

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

  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _determinePosition();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
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

    // Get initial position
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (mounted) {
      setState(() => _currentPosition = pos);
      // Center map on user location immediately
      _mapController.move(latlong.LatLng(pos.latitude, pos.longitude), 15);
    }

    // Subscribe to real-time updates
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5, // Update every 5 meters
          ),
        ).listen((Position position) {
          if (mounted) {
            bool isFirstFix = _currentPosition == null;
            setState(() {
              _currentPosition = position;
            });
            if (isFirstFix) {
              _mapController.move(
                latlong.LatLng(position.latitude, position.longitude),
                15,
              );
            }
          }
        });
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

  Future<void> _openDirections(double lat, double lng) async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Calculating route...')));
      return;
    }

    setState(() {
      _isRouting = true;
      _routePoints = [];
    });

    try {
      final dio = Dio();
      final response = await dio.get(
        'https://router.project-osrm.org/route/v1/driving/'
        '${_currentPosition!.longitude},${_currentPosition!.latitude};$lng,$lat'
        '?overview=full&geometries=geojson',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final List<dynamic> coordinates =
              data['routes'][0]['geometry']['coordinates'];

          setState(() {
            _routePoints = coordinates
                .map((coord) => latlong.LatLng(coord[1], coord[0]))
                .toList();
            _isRouting = false;
          });
        } else {
          throw Exception('No route found');
        }

        // Fit map to route
        _fitMapToRoute();
      }
    } catch (e) {
      // Fallback to straight line
      setState(() {
        _routePoints = [
          latlong.LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          latlong.LatLng(lat, lng),
        ];
        _isRouting = false;
      });

      _fitMapToRoute();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Driving route unavailable. Top view shown.'),
            backgroundColor: Colors.orange[800],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _fitMapToRoute() {
    if (_routePoints.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(_routePoints);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
    }
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
                  child: Builder(
                    builder: (context) {
                      final sortedLocations = List<Location>.from(_locations);
                      if (_currentPosition != null) {
                        sortedLocations.sort(
                          (a, b) => _calculateDistance(
                            a.lat,
                            a.lng,
                          ).compareTo(_calculateDistance(b.lat, b.lng)),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: sortedLocations.length,
                        itemBuilder: (context, index) {
                          final loc = sortedLocations[index];
                          final dist = _calculateDistance(loc.lat, loc.lng);
                          final isNearest =
                              _currentPosition != null && index == 0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child:
                                LocationListItem(
                                      location: loc,
                                      distanceInKm: dist,
                                      onTap: () => _onLocationTap(loc),
                                      onDirectionsTap: () =>
                                          _openDirections(loc.lat, loc.lng),
                                      isNearest: isNearest,
                                    )
                                    .animate()
                                    .fadeIn(delay: (100 * index).ms)
                                    .moveX(begin: 20, end: 0),
                          );
                        },
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
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                onMapReady: () {
                  if (_currentPosition != null) {
                    _mapController.move(
                      latlong.LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      15,
                    );
                  }
                },
                initialCenter: _currentPosition != null
                    ? latlong.LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      )
                    : const latlong.LatLng(7.8731, 80.7718), // Sri Lanka Center
                initialZoom: _currentPosition != null ? 15 : 7,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.mobile_app',
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 5,
                        color: const Color(0xFFE30613),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    // User Location Marker
                    if (_currentPosition != null)
                      Marker(
                        point: latlong.LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        width: 24,
                        height: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Showroom Markers
                    ..._locations.map((loc) {
                      return Marker(
                        point: latlong.LatLng(loc.lat, loc.lng),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            _mapController.move(
                              latlong.LatLng(loc.lat, loc.lng),
                              15,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${loc.name}: ${loc.address}'),
                                backgroundColor: Colors.black,
                                behavior: SnackBarBehavior.floating,
                                action: SnackBarAction(
                                  label: 'DIRECTIONS',
                                  textColor: const Color(0xFFE30613),
                                  onPressed: () =>
                                      _openDirections(loc.lat, loc.lng),
                                ),
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
                    }),
                  ],
                ),
              ],
            ),
          ),
          _buildRoutingOverlay(),
          _buildMapControls(),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildMapControls() {
    return Positioned(
      bottom: 16,
      left: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.white,
            mini: true,
            heroTag: 'zoom_in',
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                currentZoom + 1,
              );
            },
            child: const Icon(Icons.add, color: Colors.black),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            backgroundColor: Colors.white,
            mini: true,
            heroTag: 'zoom_out',
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                currentZoom - 1,
              );
            },
            child: const Icon(Icons.remove, color: Colors.black),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            backgroundColor: const Color(0xFFE30613),
            mini: true,
            heroTag: 'recenter',
            onPressed: () {
              if (_currentPosition != null) {
                _mapController.move(
                  latlong.LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  15,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location not valid')),
                );
              }
            },
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutingOverlay() {
    if (_isRouting) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const CircularProgressIndicator(color: Color(0xFFE30613)),
        ),
      ).animate().fadeIn(duration: 300.ms);
    }
    if (_routePoints.isNotEmpty) {
      return Positioned(
        bottom: 16,
        right: 16,
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFFE30613),
          label: const Text(
            'CLEAR ROUTE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: const Icon(Icons.clear, color: Colors.white, size: 16),
          onPressed: () => setState(() => _routePoints = []),
        ),
      ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9));
    }
    return const SizedBox.shrink();
  }

  Widget _buildLocationsListSliver(ThemeData theme) {
    final sortedLocations = List<Location>.from(_locations);
    if (_currentPosition != null) {
      sortedLocations.sort(
        (a, b) => _calculateDistance(
          a.lat,
          a.lng,
        ).compareTo(_calculateDistance(b.lat, b.lng)),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final loc = sortedLocations[index];
          final dist = _calculateDistance(loc.lat, loc.lng);
          final isNearest = _currentPosition != null && index == 0;

          return LocationListItem(
            location: loc,
            distanceInKm: dist,
            onTap: () => _onLocationTap(loc),
            onDirectionsTap: () => _openDirections(loc.lat, loc.lng),
            isNearest: isNearest,
          ).animate().fadeIn(delay: (200 * index).ms).moveX(begin: 20, end: 0);
        }, childCount: sortedLocations.length),
      ),
    );
  }
}
