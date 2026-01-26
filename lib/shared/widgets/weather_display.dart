import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import './/live_clock.dart';
import '../../providers/weather_provider.dart';

class WeatherDisplay extends ConsumerWidget {
  const WeatherDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LiveClock(),
        const SizedBox(height: 4),
        weatherState.weather.when(
          data: (data) => Row(
            children: [
              const Icon(Icons.cloud_queue, color: Color(0xFFE30613), size: 14),
              const SizedBox(width: 6),
              Text(
                '${data.temp.round()}°C • ${data.condition} • ${data.city.toUpperCase()}',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  shadows: [
                    const Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white54,
            ),
          ),
          error: (e, s) => const SizedBox.shrink(),
        ),
      ],
    ).animate().fadeIn(duration: 800.ms);
  }
}
