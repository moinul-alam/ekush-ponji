import 'package:flutter/material.dart';

/// Bottom navigation bar with Home, Calendar, Calculator, and Settings
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap ?? (index) {
        // TODO: Navigate to respective screens
        if (index != currentIndex) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getDestinationName(index)),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      backgroundColor: colorScheme.surface,
      elevation: 3,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: 'Home',
          tooltip: 'Home',
        ),
        NavigationDestination(
          icon: const Icon(Icons.calendar_today_outlined),
          selectedIcon: const Icon(Icons.calendar_today_rounded),
          label: 'Calendar',
          tooltip: 'Calendar',
        ),
        NavigationDestination(
          icon: const Icon(Icons.calculate_outlined),
          selectedIcon: const Icon(Icons.calculate_rounded),
          label: 'Calculator',
          tooltip: 'Calculator',
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings_rounded),
          label: 'Settings',
          tooltip: 'Settings',
        ),
      ],
    );
  }

  String _getDestinationName(int index) {
    switch (index) {
      case 0:
        return 'Home (Currently active)';
      case 1:
        return 'Calendar - Coming soon';
      case 2:
        return 'Calculator - Coming soon';
      case 3:
        return 'Settings - Coming soon';
      default:
        return '';
    }
  }
}