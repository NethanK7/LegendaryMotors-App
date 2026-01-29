import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class LiveClock extends StatelessWidget {
  const LiveClock({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final timeStr = DateFormat('hh:mm a').format(now);
        final dateStr = DateFormat('EEE, MMM d').format(now).toUpperCase();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timeStr,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 24,
                height: 1.0,
                shadows: [
                  const Shadow(
                    color: Colors.black,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            Text(
              dateStr,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 10,
                letterSpacing: 1.5,
                shadows: [
                  const Shadow(
                    color: Colors.black,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
