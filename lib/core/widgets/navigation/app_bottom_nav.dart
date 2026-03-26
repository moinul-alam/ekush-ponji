// lib/core/widgets/navigation/app_bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

/// Logical tab indices for shell branches.
class AppTab {
  AppTab._();
  static const int home = 0;
  static const int calendar = 1;
  static const int holidays = 2;
  static const int none = -1;
}

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

    final shellTabs = [
      AppTab.home,
      AppTab.calendar,
      AppTab.holidays,
    ];

    return _AppBottomNavInner(
      shellTabs: shellTabs,
      currentShellIndex: currentIndex,
      onTap: onTap,
      onMoreTap: onMoreTap,
      l10n: l10n,
      colorScheme: colorScheme,
    );
  }
}

class _AppBottomNavInner extends StatefulWidget {
  final List<int> shellTabs;
  final int currentShellIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onMoreTap;
  final AppLocalizations l10n;
  final ColorScheme colorScheme;

  const _AppBottomNavInner({
    required this.shellTabs,
    required this.currentShellIndex,
    required this.onTap,
    required this.onMoreTap,
    required this.l10n,
    required this.colorScheme,
  });

  @override
  State<_AppBottomNavInner> createState() => _AppBottomNavInnerState();
}

class _AppBottomNavInnerState extends State<_AppBottomNavInner> {
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

    final visualIndex = widget.currentShellIndex != AppTab.none &&
            shellTabs.contains(widget.currentShellIndex)
        ? shellTabs.indexOf(widget.currentShellIndex)
        : _lastVisualIndex;

    final moreVisualIndex = shellTabs.length;

    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 16,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color:
                  selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color:
                  selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            );
          }),
          indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: NavigationBar(
        selectedIndex: visualIndex,
        onDestinationSelected: (visualIdx) {
          if (visualIdx == moreVisualIndex) {
            widget.onMoreTap();
            return;
          }
          widget.onTap(shellTabs[visualIdx]);
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
          NavigationDestination(
            icon: const Icon(Icons.flag_outlined),
            selectedIcon: const Icon(Icons.flag),
            label: l10n.navHolidays,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz_outlined),
            selectedIcon: const Icon(Icons.more_horiz_rounded),
            label: l10n.navMore,
          ),
        ],
      ),
    );
  }
}
