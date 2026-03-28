import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/features/home/home_screen.dart';
import 'package:ekush_ponji/features/calendar/calendar_screen.dart';
import 'package:ekush_ponji/features/calendar/day_details_screen.dart';
import 'package:ekush_ponji/features/events/add_event_screen.dart';
import 'package:ekush_ponji/features/events/events_list_screen.dart';
import 'package:ekush_ponji/features/reminders/add_reminder_screen.dart';
import 'package:ekush_ponji/features/reminders/reminders_list_screen.dart';
import 'package:ekush_ponji/features/calculator/calculator_screen.dart';
import 'package:ekush_ponji/features/settings/settings_screen.dart';
import 'package:ekush_ponji/features/quotes/quotes_screen.dart';
import 'package:ekush_ponji/features/quotes/saved_quotes_screen.dart';
import 'package:ekush_ponji/features/words/words_screen.dart';
import 'package:ekush_ponji/features/words/saved_words_screen.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_bottom_nav.dart';
import 'package:ekush_ponji/core/widgets/navigation/more_bottom_sheet.dart';
import 'package:ekush_ponji/core/widgets/ads/app_ad_banner_bottom.dart';
import 'package:ekush_ponji/features/events/models/event.dart';
import 'package:ekush_ponji/features/reminders/models/reminder.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/holidays/holidays_screen.dart';
import 'package:ekush_ponji/features/about/about_screen.dart';
import 'package:ekush_ponji/features/onboarding/onboarding_screen.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';
import 'package:ekush_ponji/features/onboarding/onboarding_viewmodel.dart';
import 'package:ekush_ponji/main.dart' show pendingNotificationPayload;

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const _noBarRoutes = {RouteNames.onboarding};

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation:
        isOnboardingDone() ? RouteNames.home : RouteNames.onboarding,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final payload = pendingNotificationPayload;
      if (payload == null || payload.isEmpty) return null;
      pendingNotificationPayload = null;
      return _payloadToRoute(payload);
    },
    routes: [
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          final location = state.uri.toString();
          final showBar = !_noBarRoutes.contains(location);
          return RootScaffold(showBar: showBar, child: child);
        },
        routes: [
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
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return _TabShellBody(navigationShell: navigationShell);
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
                        builder: (context, state) => DayDetailsScreen(
                          initialDate: _dayDetailsInitialDate(state),
                        ),
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
            ],
          ),
          GoRoute(
            path: RouteNames.calculator,
            name: 'calculator',
            builder: (context, state) => const CalculatorScreen(),
          ),
          GoRoute(
            path: RouteNames.eventsList,
            name: 'eventsList',
            builder: (context, state) => const EventsListScreen(),
          ),
          GoRoute(
            path: RouteNames.addEvent,
            name: 'addEvent',
            builder: (context, state) => AddEventScreen(
              prefilledDate: state.extra as DateTime?,
            ),
          ),
          GoRoute(
            path: RouteNames.editEvent,
            name: 'editEvent',
            builder: (context, state) => AddEventScreen(
              eventToEdit: state.extra as Event,
            ),
          ),
          GoRoute(
            path: RouteNames.reminders,
            name: 'reminders',
            builder: (context, state) => const RemindersListScreen(),
          ),
          GoRoute(
            path: RouteNames.addReminder,
            name: 'addReminder',
            builder: (context, state) => AddReminderScreen(
              prefilledDate: state.extra as DateTime?,
            ),
          ),
          GoRoute(
            path: RouteNames.editReminder,
            name: 'editReminder',
            builder: (context, state) => AddReminderScreen(
              reminderToEdit: state.extra as Reminder,
            ),
          ),
          GoRoute(
            path: RouteNames.quotes,
            name: 'quotes',
            builder: (context, state) => QuotesScreen(
              initialIndex: _quoteOrWordInitialIndex(state),
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
              initialIndex: _quoteOrWordInitialIndex(state),
            ),
          ),
          GoRoute(
            path: RouteNames.savedWords,
            name: 'savedWords',
            builder: (context, state) => const SavedWordsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => _ErrorScreen(state: state),
  );

  /// Cold-start [redirect] can only change the location string — not [GoRouterState.extra].
  /// Encode quote/word indices and calendar dates in the query so notification taps
  /// open the correct item after launch.
  static String? _payloadToRoute(String payload) {
    if (payload == 'holiday') return RouteNames.holidays;
    if (payload.startsWith('quote:')) {
      final index = int.tryParse(payload.substring('quote:'.length));
      if (index == null) return RouteNames.quotes;
      return Uri(
        path: RouteNames.quotes,
        queryParameters: {_quoteWordIndexQueryKey: '$index'},
      ).toString();
    }
    if (payload.startsWith('word:')) {
      final index = int.tryParse(payload.substring('word:'.length));
      if (index == null) return RouteNames.words;
      return Uri(
        path: RouteNames.words,
        queryParameters: {_quoteWordIndexQueryKey: '$index'},
      ).toString();
    }
    if (payload.startsWith('event:')) {
      return _calendarDayDetailsLocation(payload.substring('event:'.length));
    }
    if (payload.startsWith('reminder:')) {
      return _calendarDayDetailsLocation(payload.substring('reminder:'.length));
    }
    return RouteNames.home;
  }

  static const String _quoteWordIndexQueryKey = 'i';
  static const String _calendarDateQueryKey = 'date';

  static String _calendarDayDetailsLocation(String dateStr) {
    try {
      DateTime.parse(dateStr);
    } catch (_) {
      return RouteNames.calendar;
    }
    return Uri(
      path: RouteNames.calendarDayDetails,
      queryParameters: {_calendarDateQueryKey: dateStr},
    ).toString();
  }
}

int _quoteOrWordInitialIndex(GoRouterState state) {
  final raw = state.uri.queryParameters[AppRouter._quoteWordIndexQueryKey];
  if (raw != null) {
    final fromQuery = int.tryParse(raw);
    if (fromQuery != null) return fromQuery;
  }
  final extra = state.extra;
  if (extra is int) return extra;
  return 0;
}

DateTime? _dayDetailsInitialDate(GoRouterState state) {
  final raw = state.uri.queryParameters[AppRouter._calendarDateQueryKey];
  if (raw != null && raw.isNotEmpty) {
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }
  final extra = state.extra;
  if (extra is DateTime) return extra;
  return null;
}

class RootScaffold extends ConsumerWidget {
  final Widget child;
  final bool showBar;

  const RootScaffold({super.key, required this.child, required this.showBar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: showBar
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppAdBannerBottom(),
                AppBottomNav(
                  currentIndex: currentTab,
                  onTap: (logicalIndex) {
                    ref.read(currentTabProvider.notifier).setTab(logicalIndex);
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
                    }
                  },
                  onMoreTap: () => showMoreBottomSheet(context),
                ),
              ],
            )
          : null,
    );
  }
}

class _TabShellBody extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _TabShellBody({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(currentTabProvider.notifier)
          .setTab(_toLogical(navigationShell.currentIndex));
    });
    return navigationShell;
  }

  int _toLogical(int branch) {
    switch (branch) {
      case 0:
        return AppTab.home;
      case 1:
        return AppTab.calendar;
      case 2:
        return AppTab.holidays;
      default:
        return AppTab.home;
    }
  }
}

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
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
