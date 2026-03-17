// lib/app/router/route_names.dart

class RouteNames {
  RouteNames._();

  // Root
  static const String splash = '/';
  static const String home = '/home';

  // Calendar (nested under /calendar shell branch)
  static const String calendar = '/calendar';
  static const String calendarDayDetails = '/calendar/day-details';
  static const String calendarAddEvent = '/calendar/add-event';
  static const String calendarAddReminder = '/calendar/add-reminder';
  static const String calendarEditEvent = '/calendar/edit-event';
  static const String calendarEditReminder = '/calendar/edit-reminder';

  // Calculator
  static const String calculator = '/calculator';

  // Events — standalone routes used by EventsListScreen
  static const String eventsList = '/events';
  static const String addEvent = '/events/add';
  static const String editEvent = '/events/edit';

  // Reminders — standalone routes used by RemindersListScreen
  static const String reminders = '/reminders';
  static const String addReminder = '/reminders/add';
  static const String editReminder = '/reminders/edit';

  // Quotes
  static const String quotes = '/quotes';
  static const String savedQuotes = '/quotes/saved';

  // Words
  static const String words = '/words';
  static const String savedWords = '/words/saved';

  // Settings
  static const String settings = '/settings';

  // Holidays
  static const String holidays = '/holidays';

  // About
  static const String about = '/about';

  // Onboarding
  static const String onboarding = '/onboarding';
}
