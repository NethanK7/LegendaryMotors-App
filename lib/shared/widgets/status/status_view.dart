import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/premium_button.dart';

class StatusView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onAction;
  final bool isSliver;

  const StatusView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onAction,
    this.isSliver = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final content = Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: onSurface.withValues(alpha: 0.05),
              ),
              child: Icon(
                icon,
                size: 48,
                color: onSurface.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: onSurface,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: onSurface.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
            if (buttonText != null && onAction != null) ...[
              const SizedBox(height: 48),
              PremiumButton(
                text: buttonText!.toUpperCase(),
                onPressed: onAction!,
                isPrimary: false,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );

    if (isSliver) {
      return SliverFillRemaining(child: content);
    }
    return content;
  }
}
