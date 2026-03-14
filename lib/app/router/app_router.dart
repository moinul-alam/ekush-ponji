// lib/app/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ekush_ponji/features/splash/splash_screen.dart';
import 'package:ekush_ponji/features/home/home_screen.dart';
import 'package:ekush_ponji/features/calendar/calendar_screen.dart';
import 'package:ekush_ponji/features/calendar/day_details_screen.dart';
import 'package:ekush_ponji/features/events/add_event_screen.dart';
import 'package:ekush_ponji/features/reminders/add_reminder_screen.dart';
import 'package:ekush_ponji/features/prayer_times/prayer_times_screen.dart';
import 'package:ekush_ponji/features/calculator/calculator_screen.dart';
import 'package:ekush_ponji/features/settings/settings_screen.dart';
import 'package:ekush_ponji/features/quotes/quotes_screen.dart';
import 'package:ekush_ponji/features/quotes/saved_quotes_screen.dart';
import 'package:ekush_ponji/features/words/words_screen.dart';
import 'package:ekush_ponji/features/words/saved_words_screen.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_bottom_nav.dart';
import 'package:ekush_ponji/core/widgets/navigation/more_bottom_sheet.dart';
import 'package:ekush_ponji/core/services/ad_service.dart';
import 'package:ekush_ponji/features/events/models/event.dart';
import 'package:ekush_ponji/features/reminders/models/reminder.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/holidays/holidays_screen.dart';
import 'package:ekush_ponji/features/about/about_screen.dart';
import 'package:ekush_ponji/features/onboarding/onboarding_screen.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    routes: [
      // ── No nav bar routes ────────────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.about,
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),

      // ── Tab Shell — Home, Calendar, Holidays, Prayer ─────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
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
                    builder: (context, state) => const DayDetailsScreen(),
                  ),
                  GoRoute(
                    path: 'add-event',
                    name: 'calendarAddEvent',
                    builder: (context, state) => AddEventScreen(
                      prefilledDate: state.extra as DateTime?,
                    ),
                  ),
                  GoRoute(
                    path: 'add-reminder',
                    name: 'calendarAddReminder',
                    builder: (context, state) => AddReminderScreen(
                      prefilledDate: state.extra as DateTime?,
                    ),
                  ),
                  GoRoute(
                    path: 'edit-event',
                    name: 'calendarEditEvent',
                    builder: (context, state) => AddEventScreen(
                      eventToEdit: state.extra as Event,
                    ),
                  ),
                  GoRoute(
                    path: 'edit-reminder',
                    name: 'calendarEditReminder',
                    builder: (context, state) => AddReminderScreen(
                      reminderToEdit: state.extra as Reminder,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.holidays,
                name: 'holidays',
                builder: (context, state) => const HolidaysScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.prayerTimes,
                name: 'prayerTimes',
                builder: (context, state) => const PrayerTimesScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Standalone Shell ─────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            _StandaloneScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: RouteNames.calculator,
            name: 'calculator',
            builder: (context, state) => const CalculatorScreen(),
          ),
          GoRoute(
            path: RouteNames.quotes,
            name: 'quotes',
            builder: (context, state) => QuotesScreen(
              initialIndex: (state.extra as int?) ?? 0,
            ),
          ),
          GoRoute(
            path: RouteNames.savedQuotes,
            name: 'savedQuotes',
            builder: (context, state) => const SavedQuotesScreen(),
          ),
          GoRoute(
            path: RouteNames.words,
            name: 'words',
            builder: (context, state) => WordsScreen(
              initialIndex: (state.extra as int?) ?? 0,
            ),
          ),
          GoRoute(
            path: RouteNames.savedWords,
            name: 'savedWords',
            builder: (context, state) => const SavedWordsScreen(),
          ),
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
        ],
      ),
    ],
    errorBuilder: (context, state) => _ErrorScreen(state: state),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// BANNER AD SLOT
// Watches bannerLoadedProvider (NotifierProvider<bool>) — rebuilds
// automatically when banner finishes loading.
// Always shows 50dp so layout never jumps.
// ─────────────────────────────────────────────────────────────────────────────

class _BannerAdSlot extends ConsumerWidget {
  const _BannerAdSlot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerLoaded = ref.watch(bannerLoadedProvider);
    final adService = ref.read(adServiceProvider);

    if (bannerLoaded && adService.bannerAd != null) {
      final banner = adService.bannerAd!;
      return SizedBox(
        width: banner.size.width.toDouble(),
        height: banner.size.height.toDouble(),
        child: AdWidget(ad: banner),
      );
    }

    // Placeholder — always reserves 50dp so layout never jumps
    return Container(
      height: 50,
      width: double.infinity,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withOpacity(0.4),
      child: Center(
        child: Text(
          'Advertisement',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.4),
                letterSpacing: 1.2,
              ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB SCAFFOLD
// ─────────────────────────────────────────────────────────────────────────────

class _ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _ScaffoldWithNavBar({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _BannerAdSlot(),
          AppBottomNav(
            currentIndex: _toLogical(navigationShell.currentIndex),
            onTap: (logicalIndex) {
              navigationShell.goBranch(
                _toBranch(logicalIndex),
                initialLocation:
                    _toBranch(logicalIndex) == navigationShell.currentIndex,
              );
            },
            onMoreTap: () => showMoreBottomSheet(context),
          ),
        ],
      ),
    );
  }

  int _toLogical(int branch) {
    switch (branch) {
      case 0:
        return AppTab.home;
      case 1:
        return AppTab.calendar;
      case 2:
        return AppTab.holidays;
      case 3:
        return AppTab.prayerTimes;
      default:
        return AppTab.home;
    }
  }

  int _toBranch(int logical) {
    switch (logical) {
      case AppTab.home:
        return 0;
      case AppTab.calendar:
        return 1;
      case AppTab.holidays:
        return 2;
      case AppTab.prayerTimes:
        return 3;
      default:
        return 0;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STANDALONE SCAFFOLD
// ─────────────────────────────────────────────────────────────────────────────

class _StandaloneScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;

  const _StandaloneScaffoldWithNavBar({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _BannerAdSlot(),
          AppBottomNav(
            currentIndex: AppTab.none,
            onTap: (logicalIndex) {
              switch (logicalIndex) {
                case AppTab.home:
                  context.go(RouteNames.home);
                  break;
                case AppTab.calendar:
                  context.go(RouteNames.calendar);
                  break;
                case AppTab.holidays:
                  context.go(RouteNames.holidays);
                  break;
                case AppTab.prayerTimes:
                  context.go(RouteNames.prayerTimes);
                  break;
              }
            },
            onMoreTap: () => showMoreBottomSheet(context),
          ),
        ],
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.error)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(l10n.pageNotFound, style: theme.textTheme.headlineSmall),
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
              label: Text(l10n.goToHome),
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction,
                size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              l10n.comingSoon,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(RouteNames.home),
              icon: const Icon(Icons.home),
              label: Text(l10n.backToHome),
            ),
          ],
        ),
      ),
    );
  }
}
