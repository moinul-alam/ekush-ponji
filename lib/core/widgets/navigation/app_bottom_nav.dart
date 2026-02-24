// lib/core/widgets/navigation/app_bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

/// Bottom navigation bar with instant tab switching
/// Indices: 0=Home, 1=Calendar, 2=PrayerTimes, 3=Calculator
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: colorScheme.surface,
      elevation: 3,
      animationDuration: const Duration(milliseconds: 200),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: l10n.navHome,
        ),
        NavigationDestination(
          icon: const Icon(Icons.calendar_today_outlined),
          selectedIcon: const Icon(Icons.calendar_today_rounded),
          label: l10n.navCalendar,
        ),
        NavigationDestination(
          icon: const Icon(Icons.mosque_outlined),
          selectedIcon: const Icon(Icons.mosque_rounded),
          label: l10n.navPrayerTimes,
        ),
        NavigationDestination(
          icon: const Icon(Icons.calculate_outlined),
          selectedIcon: const Icon(Icons.calculate_rounded),
          label: l10n.navCalculator,
        ),
      ],
    );
  }
}