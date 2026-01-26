import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'LEGACY & VISION',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?q=80&w=2672&auto=format&fit=crop',
                  ), // Placeholder
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black, Colors.transparent],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THE LEGEND',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    color: const Color(0xFFE30613),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Since 1977, we have been synonymous with high-performance automobiles. We transform standard vehicles into unique masterpieces of power and luxury.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.8,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Our philosophy is simple: Don\'t just build cars, create legends. Every engine we tune, every interior we stitch, is a testament to engineering excellence.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.8,
                      color: Colors.grey[400],
                    ),
                  ),

                  const SizedBox(height: 48),
                  Text(
                    'HEADQUARTERS',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactRow(
                    Icons.location_on,
                    'Brabus-Allee, Bottrop, Germany',
                  ),
                  _buildContactRow(Icons.phone, '+49 2041 777-0'),
                  _buildContactRow(Icons.email, 'info@brabus.com'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE30613), size: 18),
          const SizedBox(width: 16),
          Text(
            text,
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
