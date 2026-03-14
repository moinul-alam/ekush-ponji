// lib/core/widgets/navigation/app_bottom_nav.dart
//
// CHANGED:
//  • New tabs: Home, Calendar, Holidays, Prayer (conditional), More
//  • Calculator removed as a tab — moved to More bottom sheet
//  • AppTab constants updated accordingly
//  • More tab opens more_bottom_sheet.dart instead of navigating
//  • currentIndex accepts -1 (no tab selected) for standalone screens —
//    in that case the last active shell tab stays highlighted
//  • onMoreTap callback added so the shell can handle the More tap

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/onboarding/onboarding_viewmodel.dart';

/// Logical tab indices for shell branches.
/// Use these constants everywhere instead of raw integers.
class AppTab {
  AppTab._();
  static const int home = 0;
  static const int calendar = 1;
  static const int holidays = 2;
  static const int prayerTimes = 3;

  /// Sentinel — used when the current screen is not a shell tab.
  /// The nav bar will keep the last active tab highlighted.
  static const int none = -1;
}

/// Bottom navigation bar.
///
/// Tabs: Home | Calendar | Holidays | Prayer (conditional) | More
///
/// [currentIndex] uses logical [AppTab] indices, or [AppTab.none] for
/// standalone screens (settings, quotes, etc.) — the bar stays visible
/// but no tab gets the "active" highlight in that case.
///
/// [onTap] is called for shell tab taps (Home, Calendar, Holidays, Prayer).
/// [onMoreTap] is called when the More tab is tapped — the shell should
/// call showMoreBottomSheet(context) in response.
class AppBottomNav extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onMoreTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final showPrayer = ref.watch(prayerTimesEnabledProvider);

    // ── Build the ordered list of SHELL tabs (excludes More) ──────────
    final shellTabs = [
      AppTab.home,
      AppTab.calendar,
      AppTab.holidays,
      if (showPrayer) AppTab.prayerTimes,
    ];

    // Total visual destinations = shell tabs + More button
    final totalDestinations = shellTabs.length + 1; // +1 for More

    // ── Resolve visual selected index ─────────────────────────────────
    // If currentIndex is a known shell tab → highlight it.
    // If currentIndex is AppTab.none (standalone screen) → -1 means
    // NavigationBar will show no item selected. We pass the last shell
    // tab index as a fallback so the bar doesn't look broken, but this
    // requires a workaround: we clamp to 0 if nothing matches.
    int visualIndex;
    if (currentIndex == AppTab.none) {
      // No active shell tab — keep the bar visible but nothing highlighted.
      // NavigationBar requires selectedIndex >= 0, so we use a value that
      // is out of the normal range. We work around this by using a
      // _StatefulNavBar wrapper below that tracks last known index.
      visualIndex = 0; // fallback, overridden by _LastTabTracker
    } else {
      visualIndex = shellTabs.contains(currentIndex)
          ? shellTabs.indexOf(currentIndex)
          : 0;
    }

    return _AppBottomNavInner(
      shellTabs: shellTabs,
      currentShellIndex: currentIndex,
      onTap: onTap,
      onMoreTap: onMoreTap,
      showPrayer: showPrayer,
      l10n: l10n,
      colorScheme: colorScheme,
    );
  }
}

/// Inner stateful widget that tracks the last active shell tab index,
/// so when the user navigates to a standalone screen the last tab
/// stays highlighted (Option 2 behaviour).
class _AppBottomNavInner extends StatefulWidget {
  final List<int> shellTabs;
  final int currentShellIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onMoreTap;
  final bool showPrayer;
  final AppLocalizations l10n;
  final ColorScheme colorScheme;

  const _AppBottomNavInner({
    required this.shellTabs,
    required this.currentShellIndex,
    required this.onTap,
    required this.onMoreTap,
    required this.showPrayer,
    required this.l10n,
    required this.colorScheme,
  });

  @override
  State<_AppBottomNavInner> createState() => _AppBottomNavInnerState();
}

class _AppBottomNavInnerState extends State<_AppBottomNavInner> {
  // Tracks the last visual index of a shell tab — preserved when on
  // standalone screens so the correct tab stays highlighted.
  int _lastVisualIndex = 0;

  @override
  void didUpdateWidget(_AppBottomNavInner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentShellIndex != AppTab.none &&
        widget.shellTabs.contains(widget.currentShellIndex)) {
      _lastVisualIndex = widget.shellTabs.indexOf(widget.currentShellIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final colorScheme = widget.colorScheme;
    final shellTabs = widget.shellTabs;

    // The visual index to highlight:
    // - On a shell tab → that tab's visual index
    // - On a standalone screen → last known shell tab index
    final visualIndex = widget.currentShellIndex != AppTab.none &&
            shellTabs.contains(widget.currentShellIndex)
        ? shellTabs.indexOf(widget.currentShellIndex)
        : _lastVisualIndex;

    // More tab visual index is always the last one
    final moreVisualIndex = shellTabs.length;

    return NavigationBar(
      selectedIndex: visualIndex,
      onDestinationSelected: (visualIdx) {
        if (visualIdx == moreVisualIndex) {
          // More tapped — open bottom sheet, do NOT change selectedIndex
          widget.onMoreTap();
          return;
        }
        // Shell tab tapped — map back to logical AppTab index
        widget.onTap(shellTabs[visualIdx]);
      },
      backgroundColor: colorScheme.surface,
      elevation: 3,
      animationDuration: const Duration(milliseconds: 200),
      destinations: [
        // ── Home ────────────────────────────────────────
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: l10n.navHome,
        ),

        // ── Calendar ────────────────────────────────────
        NavigationDestination(
          icon: const Icon(Icons.calendar_today_outlined),
          selectedIcon: const Icon(Icons.calendar_today_rounded),
          label: l10n.navCalendar,
        ),

        // ── Holidays ────────────────────────────────────
        NavigationDestination(
          icon: const Icon(Icons.beach_access_outlined),
          selectedIcon: const Icon(Icons.beach_access_rounded),
          label: l10n.navHolidays,
        ),

        // ── Prayer Times (conditional) ───────────────────
        if (widget.showPrayer)
          NavigationDestination(
            icon: const Icon(Icons.mosque_outlined),
            selectedIcon: const Icon(Icons.mosque_rounded),
            label: l10n.navPrayerTimes,
          ),

        // ── More ────────────────────────────────────────
        NavigationDestination(
          icon: const Icon(Icons.more_horiz_outlined),
          selectedIcon: const Icon(Icons.more_horiz_rounded),
          label: l10n.navMore,
        ),
      ],
    );
  }
}
