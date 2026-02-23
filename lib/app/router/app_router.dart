// lib/app/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/features/splash/splash_screen.dart';
import 'package:ekush_ponji/features/home/home_screen.dart';
import 'package:ekush_ponji/features/calendar/calendar_screen.dart';
// import 'package:ekush_ponji/features/prayer_times/prayer_times_screen.dart';
import 'package:ekush_ponji/features/calculator/calculator_screen.dart';
import 'package:ekush_ponji/features/settings/settings_screen.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_bottom_nav.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    routes: [
      // Splash (outside main navigation)
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Main Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // 0 — Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // 1 — Calendar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.calendar,
                name: 'calendar',
                builder: (context, state) => const CalendarScreen(),
                routes: [
                  GoRoute(
                    path: 'day-details',
                    name: 'calendarDayDetails',
                    builder: (context, state) =>
                        const _PlaceholderScreen(title: 'Day Details'),
                  ),
                  GoRoute(
                    path: 'add-event',
                    name: 'calendarAddEvent',
                    builder: (context, state) =>
                        const _PlaceholderScreen(title: 'Add Event'),
                  ),
                  GoRoute(
                    path: 'add-reminder',
                    name: 'calendarAddReminder',
                    builder: (context, state) =>
                        const _PlaceholderScreen(title: 'Add Reminder'),
                  ),
                ],
              ),
            ],
          ),

          // 2 — Prayer Times (new, between Calendar and Calculator)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.prayerTimes,
                name: 'prayerTimes',
                builder: (context, state) => const PrayerTimesScreen(),
              ),
            ],
          ),

          // 3 — Calculator
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.calculator,
                name: 'calculator',
                builder: (context, state) => const CalculatorScreen(),
              ),
            ],
          ),
        ],
      ),

      // Standalone routes (outside bottom nav)
      GoRoute(
        path: RouteNames.eventsList,
        name: 'eventsList',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Events'),
      ),
      GoRoute(
        path: RouteNames.addEvent,
        name: 'addEvent',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Add Event'),
      ),
      GoRoute(
        path: RouteNames.editEvent,
        name: 'editEvent',
        builder: (context, state) {
          final eventId = state.uri.queryParameters['id'] ?? '';
          return _PlaceholderScreen(title: 'Edit Event: $eventId');
        },
      ),
      GoRoute(
        path: RouteNames.reminders,
        name: 'reminders',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Reminders'),
      ),
      GoRoute(
        path: RouteNames.addReminder,
        name: 'addReminder',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Add Reminder'),
      ),
      GoRoute(
        path: RouteNames.quotes,
        name: 'quotes',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Quotes'),
      ),
      GoRoute(
        path: RouteNames.savedQuotes,
        name: 'savedQuotes',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Saved Quotes'),
      ),
      GoRoute(
        path: RouteNames.words,
        name: 'words',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Words'),
      ),
      GoRoute(
        path: RouteNames.savedWords,
        name: 'savedWords',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Saved Words'),
      ),
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],

    errorBuilder: (context, state) => _ErrorScreen(state: state),
  );
}

// ─── Scaffold with bottom nav ─────────────────────────────────
class _ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _ScaffoldWithNavBar({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

// ─── Error screen ─────────────────────────────────────────────
class _ErrorScreen extends StatelessWidget {
  final GoRouterState state;
  const _ErrorScreen({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Page not found', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(RouteNames.home),
              icon: const Icon(Icons.home),
              label: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Placeholder screen ───────────────────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Coming Soon...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(RouteNames.home),
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}


//Delete later
class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen();

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderScreen(title: 'Prayer Times');
  }
}
