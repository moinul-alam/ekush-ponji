// lib/features/home/widgets/app_greeter.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

/// Modern, simple greeting widget with dynamic time-based backgrounds
class AppGreeter extends StatelessWidget {
  final String? userName;

  const AppGreeter({
    super.key,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final greeting = _getGreeting(context);
    final greetingColors = _getGreetingColors(colorScheme);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: greetingColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: greetingColors.first.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background shape
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _getGreetingIcon(),
                    color: _getIconColor(),
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        greeting,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getTextColor(),
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      if (userName != null && userName!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          userName!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: _getTextColor().withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(context);

    if (hour >= 5 && hour < 12) {
      return l10n.goodMorning;
    } else if (hour >= 12 && hour < 17) {
      return l10n.goodAfternoon;
    } else if (hour >= 17 && hour < 21) {
      return l10n.goodEvening;
    } else {
      return l10n.goodNight;
    }
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return Icons.wb_sunny_rounded; // Morning sun
    } else if (hour >= 12 && hour < 17) {
      return Icons.wb_sunny_outlined; // Afternoon sun
    } else if (hour >= 17 && hour < 21) {
      return Icons.wb_twilight_rounded; // Evening twilight
    } else {
      return Icons.nights_stay_rounded; // Night moon
    }
  }

  /// Get dynamic gradient colors based on time of day
  List<Color> _getGreetingColors(ColorScheme colorScheme) {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      // Morning: Warm sunrise colors (Orange/Yellow tones)
      return [
        const Color(0xFFFFD89B), // Soft peach
        const Color(0xFFFFB347), // Light orange
      ];
    } else if (hour >= 12 && hour < 17) {
      // Afternoon: Bright, vibrant colors (Blue/Cyan tones)
      return [
        const Color(0xFF4FC3F7), // Sky blue
        const Color(0xFF29B6F6), // Bright blue
      ];
    } else if (hour >= 17 && hour < 21) {
      // Evening: Sunset colors (Purple/Pink tones)
      return [
        const Color(0xFFCE93D8), // Soft purple
        const Color(0xFFBA68C8), // Medium purple
      ];
    } else {
      // Night: Dark, calming colors (Deep blue/Indigo)
      return [
        const Color(0xFF5C6BC0), // Deep indigo
        const Color(0xFF3949AB), // Dark blue
      ];
    }
  }

  /// Get text color that contrasts well with background
  Color _getTextColor() {
    final hour = DateTime.now().hour;

    // Morning and Afternoon use dark text
    if (hour >= 5 && hour < 17) {
      return const Color(0xFF1A1A1A); // Very dark gray (almost black)
    }

    // Evening and Night use light text
    return Colors.white;
  }

  /// Get icon color that matches the theme
  Color _getIconColor() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return const Color(0xFFFF6F00); // Deep orange (sun)
    } else if (hour >= 12 && hour < 17) {
      return const Color(0xFFFFA000); // Amber (bright sun)
    } else if (hour >= 17 && hour < 21) {
      return const Color(0xFF7B1FA2); // Deep purple (sunset)
    } else {
      return const Color(0xFFE1F5FE); // Very light blue (moon)
    }
  }
}
