import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumButton extends StatelessWidget {
  final String text; // Button label
  final VoidCallback? onPressed; // Action to perform on click
  final bool isLoading; // If true, shows a spinner instead of text
  final bool
  isPrimary; // Switches between Brabus Red (primary) and White/Transparent (secondary)
  final IconData? icon; // Optional icon to show before text
  final double? width; // Optional custom width
  final EdgeInsetsGeometry? padding; // Optional custom padding

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.icon,
    this.width = double.infinity,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isPrimary ? const Color(0xFFE30613) : Colors.white;
    final foregroundColor = isPrimary ? Colors.white : Colors.black;

    return SizedBox(
      width: width,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onPressed?.call();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: padding,
          shape: const RoundedRectangleBorder(),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: foregroundColor,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: foregroundColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: foregroundColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
