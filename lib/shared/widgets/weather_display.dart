import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import './/live_clock.dart';
import '../../providers/weather_provider.dart';

class WeatherDisplay extends StatelessWidget {
  const WeatherDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherState = context.watch<WeatherProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LiveClock(),
        const SizedBox(height: 4),
        _buildWeatherContent(weatherState),
      ],
    ).animate().fadeIn(duration: 800.ms);
  }

  Widget _buildWeatherContent(WeatherProvider state) {
    if (state.isLoading) {
      return const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
      );
    }

    if (state.error != null || state.weather == null) {
      return const SizedBox.shrink();
    }

    final data = state.weather!;
    return Row(
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
    );
  }
}
