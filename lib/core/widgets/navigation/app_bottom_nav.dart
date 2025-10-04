import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';

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
      onDestinationSelected:
          onTap ?? (index) => _handleNavigation(context, index),
      backgroundColor: colorScheme.surface,
      elevation: 3,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
          tooltip: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today_rounded),
          label: 'Calendar',
          tooltip: 'Calendar',
        ),
        NavigationDestination(
          icon: Icon(Icons.calculate_outlined),
          selectedIcon: Icon(Icons.calculate_rounded),
          label: 'Calculator',
          tooltip: 'Calculator',
        ),
        // NavigationDestination(
        //   icon: Icon(Icons.settings_outlined),
        //   selectedIcon: Icon(Icons.settings_rounded),
        //   label: 'Settings',
        //   tooltip: 'Settings',
        // ),
      ],
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.calendar);
        break;
      case 2:
        context.go(RouteNames.calculator);
        break;
      // case 3:
      //   context.go(RouteNames.settings);
      //   break;
    }
  }
}
