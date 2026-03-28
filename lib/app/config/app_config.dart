// lib/core/config/app_config.dart

/// Central application configuration.
/// Environment is injected at build time via --dart-define=ENV=production
class AppConfig {
  AppConfig._();

  // ═══════════════════════════════════════════
  // APP INFORMATION
  // ═══════════════════════════════════════════

  static const String appName = 'একুশ পঞ্জি';
  static const String appNameEn = 'Ekush Ponji';
  /// Marketing / store id only. Runtime version → [AppVersionCache] / [appVersionProvider].
  static const String packageName = 'com.ekushlabs.ponji';

  // ═══════════════════════════════════════════
  // ENVIRONMENT
  // ═══════════════════════════════════════════

  static const String _env = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static bool get isProduction => _env == 'production';
  static bool get isStaging => _env == 'staging';
  static bool get isDevelopment => _env == 'development';

  // ═══════════════════════════════════════════
  // API CONFIGURATION
  // ═══════════════════════════════════════════

  static String get apiBaseUrl {
    if (isProduction) return 'https://api.ekushponji.com';
    if (isStaging) return 'https://staging-api.ekushponji.com';
    return 'https://dev-api.ekushponji.com';
  }

  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  static const int maxRetryAttempts = 3;

  // ═══════════════════════════════════════════
  // FIREBASE
  // ═══════════════════════════════════════════

  static bool get useFirebaseEmulator => isDevelopment;

  static const String firestoreEmulatorHost = 'localhost';
  static const int firestoreEmulatorPort = 8080;
  static const int authEmulatorPort = 9099;

  // ═══════════════════════════════════════════
  // FEATURE FLAGS
  // ═══════════════════════════════════════════

  static bool get enableAnalytics => isProduction;
  static bool get enableCrashReporting => !isDevelopment;
  static bool get enableRemoteConfig => isProduction || isStaging;
  static bool get enableLogging => isDevelopment;

  // ═══════════════════════════════════════════
  // STORAGE
  // ═══════════════════════════════════════════

  static const String hiveSettingsBox = 'settings';
  static const String hiveCalendarBox = 'calendar';
  static const String hiveRemindersBox = 'reminders';

  // ═══════════════════════════════════════════
  // CONTENT & LIMITS
  // ═══════════════════════════════════════════

  static const int maxEventsPerDay = 10;
  static const int maxReminderTitleLen = 100;
  static const int maxEventTitleLen = 150;
  static const Duration notificationLead = Duration(minutes: 30);
}
