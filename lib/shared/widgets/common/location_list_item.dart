import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/location.dart';

class LocationListItem extends StatelessWidget {
  final Location location;
  final double? distanceInKm;
  final VoidCallback? onTap;
  final VoidCallback? onDirectionsTap;

  final bool isNearest;

  const LocationListItem({
    super.key,
    required this.location,
    this.distanceInKm,
    this.onTap,
    this.onDirectionsTap,
    this.isNearest = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: onSurface.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                location.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location.address,
                    style: GoogleFonts.inter(
                      color: onSurface.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (distanceInKm != null)
                        Text(
                          '${distanceInKm!.toStringAsFixed(0)} KM AWAY',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFE30613),
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                      if (isNearest) ...[
                        if (distanceInKm != null) const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'NEAREST',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Directions Button
            IconButton(
              onPressed: onDirectionsTap,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE30613).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions,
                  color: Color(0xFFE30613),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
