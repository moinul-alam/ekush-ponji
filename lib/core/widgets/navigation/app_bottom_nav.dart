// lib/core/widgets/navigation/app_bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/onboarding/onboarding_viewmodel.dart';

/// Logical tab indices — stable regardless of whether prayer times is shown.
/// Use these constants everywhere in the app instead of raw integers.
class AppTab {
  AppTab._();
  static const int home = 0;
  static const int calendar = 1;
  static const int prayerTimes = 2;
  static const int calculator = 3;
}

/// Bottom navigation bar with instant tab switching.
/// Automatically hides the Prayer Times tab when the feature is disabled.
///
/// [currentIndex] and [onTap] use logical [AppTab] indices.
/// This widget handles the mapping to/from visual positions internally.
class AppBottomNav extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final showPrayer = ref.watch(prayerTimesEnabledProvider);

    // Build the ordered list of visible tabs
    final visibleTabs = [
      AppTab.home,
      AppTab.calendar,
      if (showPrayer) AppTab.prayerTimes,
      AppTab.calculator,
    ];

    // Map logical index → visual index (clamp if prayer tab was active but now hidden)
    final visualIndex = visibleTabs.contains(currentIndex)
        ? visibleTabs.indexOf(currentIndex)
        : 0;

    return NavigationBar(
      selectedIndex: visualIndex,
      onDestinationSelected: (visualIdx) {
        // Map visual index back to logical AppTab index
        onTap(visibleTabs[visualIdx]);
      },
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
        if (showPrayer)
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