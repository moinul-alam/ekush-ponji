import 'package:flutter/material.dart';

class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // Splash Screen
  static const int splashDurationSeconds = 2;
  static const String splashLogoPath = 'assets/images/logo.png';

  // Date & Time Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';
  static const String bengaliDateFormat = 'dd MMMM yyyy'; // Will be localized

  // Limits
  static const int maxRemindersPerDay = 10;
  static const int maxCustomEvents = 100;
  static const int maxReminderMessageLength = 200;
  static const int maxEventTitleLength = 100;
  static const int maxEventDescriptionLength = 500;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Cache Duration
  static const Duration cacheValidityDuration = Duration(hours: 24);
  static const Duration quoteCacheDuration = Duration(hours: 12);
  static const Duration wordCacheDuration = Duration(hours: 12);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 2.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Default Values
  static const String defaultLanguage = 'bn'; // Bengali
  static const String fallbackLanguage = 'en'; // English
  static const bool defaultNotificationsEnabled = true;
  static const bool defaultDarkModeEnabled = false;

  // ========== ADD THESE NEW SECTIONS ==========

  // Supported Locales
  static const List<Locale> supportedLocales = [
    Locale('bn', 'BD'), // Bangla (Bangladesh)
    Locale('en', 'US'), // English (US)
  ];

  // Default Locale
  static const Locale defaultLocale = Locale('bn', 'BD');

  // Language Names
  static const Map<String, String> languageNames = {
    'bn': 'বাংলা',
    'en': 'English',
  };

  // Language Display (with flags)
  static const Map<String, String> languageDisplay = {
    'bn': '🇧🇩 বাংলা',
    'en': '🇺🇸 English',
  };

  // Storage Keys
  static const String storageKeyLocale = 'app_locale';
  static const String storageKeyThemeMode = 'theme_mode';
  static const String storageKeyFirstLaunch = 'first_launch';

  // ========== HELPER METHODS ==========

  /// Get language name by code
  static String getLanguageName(String code) {
    return languageNames[code] ?? 'Unknown';
  }

  /// Get language display by code
  static String getLanguageDisplay(String code) {
    return languageDisplay[code] ?? 'Unknown';
  }

  /// Check if locale is supported
  static bool isLocaleSupported(Locale locale) {
    return supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }
}
