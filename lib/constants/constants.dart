import 'package:flutter/material.dart';

/// Language-independent constants for the Ekush Ponji app
class AppConstants {
  // App Info
  static const String appName = 'Ekush Ponji';
  static const String appVersion = '1.0.0';
  
  // Localization
  static const List<Locale> supportedLocales = [
    Locale('bn', 'BD'), // Bengali Bangladesh
    Locale('en', 'US'), // English
  ];
  
  static const Locale defaultLocale = Locale('bn', 'BD');
  
  // Database
  static const String holidaysBoxName = 'holidays';
  static const String remindersBoxName = 'reminders';
  static const String settingsBoxName = 'settings';
  
  // Event Types (using IDs, not display text)
  static const String nationalHoliday = 'national';
  static const String culturalHoliday = 'cultural';
  static const String religiousHoliday = 'religious';
  static const String personalReminder = 'personal';
  
  // Colors for different event types
  static const Map<String, Color> eventColors = {
    nationalHoliday: Color(0xFFE53935), // Red
    culturalHoliday: Color(0xFF1B5E20), // Green
    religiousHoliday: Color(0xFF6A1B9A), // Purple
    personalReminder: Color(0xFF1976D2), // Blue
  };
  
  // Icons for different event types
  static const Map<String, IconData> eventIcons = {
    nationalHoliday: Icons.flag,
    culturalHoliday: Icons.celebration,
    religiousHoliday: Icons.mosque,
    personalReminder: Icons.notification_important,
  };
  
  // Notification
  static const String reminderChannelId = 'reminder_channel';
  static const String reminderChannelName = 'Personal Reminders';
  static const String reminderChannelDescription = 'Notifications for user reminders';
  
  // Pricing (numbers are universal, currency symbols in localization)
  static const int premiumMonthlyPriceAmount = 99;
  static const int premiumYearlyPriceAmount = 999;
  
  // API endpoints (for future use)
  static const String baseApiUrl = 'https://api.ekushponji.com';
  static const String holidaysEndpoint = '/holidays';
  static const String personalitiesEndpoint = '/personalities';
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Layout constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultRadius = 12.0;
  static const double cardRadius = 16.0;
}
