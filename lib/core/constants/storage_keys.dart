class StorageKeys {
  // Private constructor to prevent instantiation
  StorageKeys._();

  // User Preferences
  static const String userSettings = 'user_settings';
  static const String themeMode = 'theme_mode';
  static const String languageCode = 'language_code';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String selectedColorScheme = 'selected_color_scheme';

  // Date Display Settings
  static const String dateDisplayFormat = 'date_display_format';
  static const String showBengaliDate = 'show_bengali_date';
  static const String showGregorianDate = 'show_gregorian_date';

  // Cache Keys
  static const String cachedHolidays = 'cached_holidays';
  static const String cachedQuotes = 'cached_quotes';
  static const String cachedWords = 'cached_words';
  static const String lastSyncTime = 'last_sync_time';

  // User Data
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String isLoggedIn = 'is_logged_in';
  static const String authToken = 'auth_token';

  // First Launch
  static const String isFirstLaunch = 'is_first_launch';
  static const String onboardingCompleted = 'onboarding_completed';

  // Reminder Settings
  static const String defaultReminderTime = 'default_reminder_time';
  static const String reminderSound = 'reminder_sound';
  static const String reminderVibration = 'reminder_vibration';
}