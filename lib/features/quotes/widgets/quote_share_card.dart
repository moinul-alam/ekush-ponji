// lib/features/quotes/widgets/quote_share_card.dart
//
// A self-contained, off-screen-renderable card used ONLY for share image
// generation. It has no interactive elements and uses explicit colors so
// it always looks great as a PNG regardless of app theme.

import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';

class QuoteShareCard extends StatelessWidget {
  final QuoteModel quote;

  const QuoteShareCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    // Fixed palette — looks good in both light & dark host themes
    const bgTop = Color(0xFFF0FDF8);
    const bgBottom = Color(0xFFE6F7FF);
    const accentGreen = Color(0xFF006B54);
    const accentTeal = Color(0xFF3D6373);
    const textDark = Color(0xFF1A2E27);
    const chipBg = Color(0xFFD0F5EA);
    const chipText = Color(0xFF004D3B);

    return Container(
      width: 420,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [bgTop, bgBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative large quote mark background
          Positioned(
            top: -10,
            left: 16,
            child: Text(
              '\u201C',
              style: TextStyle(
                fontSize: 180,
                height: 1,
                color: accentGreen.withValues(alpha: 0.07),
                fontFamily: 'Georgia',
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(32, 36, 32, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    quote.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: chipText,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Opening quote icon
                const Icon(
                  Icons.format_quote_rounded,
                  color: accentGreen,
                  size: 32,
                ),

                const SizedBox(height: 12),

                // Quote text
                Text(
                  quote.text,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: textDark,
                    height: 1.55,
                    letterSpacing: 0.1,
                  ),
                ),

                const SizedBox(height: 28),

                // Divider line
                Container(
                  height: 1,
                  color: accentGreen.withValues(alpha: 0.15),
                ),

                const SizedBox(height: 20),

                // Author row + watermark
                Row(
                  children: [
                    // Color bar accent
                    Container(
                      width: 3,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [accentGreen, accentTeal],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quote.author,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                      ),
                    ),
                    // App logo / watermark
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: accentGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: accentGreen.withValues(alpha: 0.2)),
                      ),
                      child: const Text(
                        'একুশ পঞ্জি',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: accentGreen,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
