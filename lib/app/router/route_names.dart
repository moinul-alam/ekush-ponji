class RouteNames {
  // Private constructor to prevent instantiation
  RouteNames._();

  // Root routes
  static const String splash = '/';
  static const String home = '/home';

  // Calendar
  static const String calendar = '/calendar';
  static const String calendarDayDetails = '/calendar/day-details';
  static const String calendarAddEvent = '/calendar/add-event';
  static const String calendarAddReminder = '/calendar/add-reminder';

  // Calculator
  static const String calculator = '/calculator';

  // Events
  static const String eventsList = '/events';
  static const String addEvent = '/events/add';
  static const String editEvent = '/events/edit';

  // Reminders
  static const String reminders = '/reminders';
  static const String addReminder = '/reminders/add';

  // Quotes
  static const String quotes = '/quotes';
  static const String savedQuotes = '/quotes/saved';

  // Words
  static const String words = '/words';
  static const String savedWords = '/words/saved';

  // Settings
  static const String settings = '/settings';
}
