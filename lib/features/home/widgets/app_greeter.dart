// lib/features/home/widgets/app_greeter.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

/// Modern greeting widget with dynamic time-based backgrounds
/// Uses app's color scheme for perfect consistency
class AppGreeter extends StatefulWidget {
  const AppGreeter({super.key});

  @override
  State<AppGreeter> createState() => _AppGreeterState();
}

class _AppGreeterState extends State<AppGreeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // Slow, gentle rotation
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159, // Full rotation in radians
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    _animationController.repeat(); // Continuous rotation
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final greeting = _getGreeting(context);
    final greetingColors = _getGreetingColors(colorScheme);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: greetingColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: greetingColors.first.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background shapes
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Row(
              children: [
                // Enhanced icon container with glow effect - only icon rotates
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(colorScheme),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getIconBorderColor(colorScheme),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getIconColor(colorScheme)
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Icon(
                          _getGreetingIcon(),
                          color: _getIconColor(colorScheme),
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 20),

                // Text content - just the greeting
                Expanded(
                  child: Text(
                    greeting,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(colorScheme),
                      letterSpacing: -0.8,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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

  /// Get dynamic gradient colors based on time using app's color scheme
  List<Color> _getGreetingColors(ColorScheme colorScheme) {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      // Morning: Fresh, energetic (Primary colors - vibrant teal/green)
      return [
        colorScheme.primaryContainer,
        colorScheme.primaryContainer.withValues(alpha: 0.7),
      ];
    } else if (hour >= 12 && hour < 17) {
      // Afternoon: Bright, active (Secondary colors - calm green)
      return [
        colorScheme.secondaryContainer,
        colorScheme.secondaryContainer.withValues(alpha: 0.7),
      ];
    } else if (hour >= 17 && hour < 21) {
      // Evening: Relaxing (Tertiary colors - cool blue)
      return [
        colorScheme.tertiaryContainer,
        colorScheme.tertiaryContainer.withValues(alpha: 0.7),
      ];
    } else {
      // Night: Calm, restful (Darker tertiary/primary mix)
      return [
        colorScheme.tertiaryContainer.withValues(alpha: 0.8),
        colorScheme.primaryContainer.withValues(alpha: 0.6),
      ];
    }
  }

  /// Get text color based on background
  Color _getTextColor(ColorScheme colorScheme) {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return colorScheme.onPrimaryContainer;
    } else if (hour >= 12 && hour < 17) {
      return colorScheme.onSecondaryContainer;
    } else if (hour >= 17 && hour < 21) {
      return colorScheme.onTertiaryContainer;
    } else {
      return colorScheme.onTertiaryContainer;
    }
  }

  /// Get icon color that stands out
  Color _getIconColor(ColorScheme colorScheme) {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return colorScheme.primary; // Vibrant green for morning sun
    } else if (hour >= 12 && hour < 17) {
      return colorScheme.secondary; // Medium green for afternoon
    } else if (hour >= 17 && hour < 21) {
      return colorScheme.tertiary; // Blue for evening
    } else {
      return colorScheme.tertiary
          .withValues(alpha: 0.9); // Muted blue for night
    }
  }

  /// Icon background color
  Color _getIconBackgroundColor(ColorScheme colorScheme) {
    return colorScheme.surface.withValues(alpha: 0.5);
  }

  /// Icon border color
  Color _getIconBorderColor(ColorScheme colorScheme) {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return colorScheme.primary.withValues(alpha: 0.2);
    } else if (hour >= 12 && hour < 17) {
      return colorScheme.secondary.withValues(alpha: 0.2);
    } else {
      return colorScheme.tertiary.withValues(alpha: 0.2);
    }
  }
}
