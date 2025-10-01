import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/features/splash/splash_screen.dart';
import 'package:ekush_ponji/features/home/home_screen.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),

      // Home Screen
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
      ),

      // Calendar Screen (placeholder for now)
      GoRoute(
        path: RouteNames.calendar,
        name: 'calendar',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const _PlaceholderScreen(title: 'Calendar'),
        ),
      ),

      // Events List Screen (placeholder)
      GoRoute(
        path: RouteNames.eventsList,
        name: 'eventsList',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const _PlaceholderScreen(title: 'Events'),
        ),
      ),

      // Add Event Screen (placeholder)
      GoRoute(
        path: RouteNames.addEvent,
        name: 'addEvent',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const _PlaceholderScreen(title: 'Add Event'),
        ),
      ),

      // Edit Event Screen (placeholder)
      GoRoute(
        path: RouteNames.editEvent,
        name: 'editEvent',
        pageBuilder: (context, state) {
          final eventId = state.uri.queryParameters['id'] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: _PlaceholderScreen(title: 'Edit Event: $eventId'),
          );
        },
      ),

      // Reminders Screen (placeholder)
      GoRoute(
        path: RouteNames.reminders,
        name: 'reminders',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const _PlaceholderScreen(title: 'Reminders'),
        ),
      ),

      // Add Reminder Screen (placeholder)
      GoRoute(
        path: RouteNames.addReminder,
        name: 'addReminder',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const _PlaceholderScreen(title: 'Add Reminder'),
        ),
      ),

      // Quotes Screen (placeholder)
      GoRoute(
        path: RouteNames.quotes,
        name: 'quotes',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const _PlaceholderScreen(title: 'Quotes'),
        ),
      ),

      // Saved Quotes Screen (placeholder)
      GoRoute(
        path: RouteNames.savedQuotes,
        name: 'savedQuotes',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const _PlaceholderScreen(title: 'Saved Quotes'),
        ),
      ),

      // Words Screen (placeholder)
      GoRoute(
        path: RouteNames.words,
        name: 'words',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const _PlaceholderScreen(title: 'Words'),
        ),
      ),

      // Saved Words Screen (placeholder)
      GoRoute(
        path: RouteNames.savedWords,
        name: 'savedWords',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const _PlaceholderScreen(title: 'Saved Words'),
        ),
      ),

      // Settings Screen (placeholder)
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const _PlaceholderScreen(title: 'Settings'),
        ),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodySmall,
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
    ),
  );
}

// Placeholder screen for routes not yet implemented
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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