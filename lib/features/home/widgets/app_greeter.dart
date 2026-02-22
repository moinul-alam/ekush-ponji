// lib/features/home/widgets/app_greeter.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

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
      duration: const Duration(seconds: 20),
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    _animationController.repeat();
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
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: greetingColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(colorScheme),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getIconBorderColor(colorScheme),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getIconColor(colorScheme).withValues(alpha: 0.3),
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
                      size: 24,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                greeting,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(colorScheme),
                  letterSpacing: -0.8,
                  height: 1.1,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(context);
    if (hour >= 5 && hour < 12) return l10n.goodMorning;
    if (hour >= 12 && hour < 17) return l10n.goodAfternoon;
    if (hour >= 17 && hour < 21) return l10n.goodEvening;
    return l10n.goodNight;
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return Icons.wb_sunny_rounded;
    if (hour >= 12 && hour < 17) return Icons.wb_sunny_outlined;
    if (hour >= 17 && hour < 21) return Icons.wb_twilight_rounded;
    return Icons.nights_stay_rounded;
  }

  List<Color> _getGreetingColors(ColorScheme colorScheme) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return [colorScheme.primaryContainer, colorScheme.primaryContainer.withValues(alpha: 0.7)];
    } else if (hour >= 12 && hour < 17) {
      return [colorScheme.secondaryContainer, colorScheme.secondaryContainer.withValues(alpha: 0.7)];
    } else if (hour >= 17 && hour < 21) {
      return [colorScheme.tertiaryContainer, colorScheme.tertiaryContainer.withValues(alpha: 0.7)];
    } else {
      return [colorScheme.tertiaryContainer.withValues(alpha: 0.8), colorScheme.primaryContainer.withValues(alpha: 0.6)];
    }
  }

  Color _getTextColor(ColorScheme colorScheme) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return colorScheme.onPrimaryContainer;
    if (hour >= 12 && hour < 17) return colorScheme.onSecondaryContainer;
    return colorScheme.onTertiaryContainer;
  }

  Color _getIconColor(ColorScheme colorScheme) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return colorScheme.primary;
    if (hour >= 12 && hour < 17) return colorScheme.secondary;
    if (hour >= 17 && hour < 21) return colorScheme.tertiary;
    return colorScheme.tertiary.withValues(alpha: 0.9);
  }

  Color _getIconBackgroundColor(ColorScheme colorScheme) =>
      colorScheme.surface.withValues(alpha: 0.5);

  Color _getIconBorderColor(ColorScheme colorScheme) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return colorScheme.primary.withValues(alpha: 0.2);
    if (hour >= 12 && hour < 17) return colorScheme.secondary.withValues(alpha: 0.2);
    return colorScheme.tertiary.withValues(alpha: 0.2);
  }
}