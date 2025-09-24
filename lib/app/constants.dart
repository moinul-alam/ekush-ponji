import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Ekush Ponji';
  static const String appNameBengali = 'একুশ পঞ্জি';
  static const String appVersion = '1.0.0';
  
  // Localization
  static const List<Locale> supportedLocales = [
    Locale('bn', 'BD'), // Bengali Bangladesh
    Locale('en', 'US'), // English
  ];
  
  static const Locale defaultLocale = Locale('bn', 'BD');
  
  // Routes
  static const String homeRoute = '/home';
  static const String settingsRoute = '/settings';
  static const String addReminderRoute = '/add-reminder';
  static const String premiumRoute = '/premium';
  
  // Database
  static const String holidaysBoxName = 'holidays';
  static const String remindersBoxName = 'reminders';
  static const String settingsBoxName = 'settings';
  
  // Bengali Months
  static const List<String> bengaliMonths = [
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 
    'মে', 'জুন', 'জুলাই', 'আগস্ট', 
    'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
  ];
  
  // Bengali Numbers
  static const List<String> bengaliNumbers = [
    '০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'
  ];
  
  // Event Types
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
  
  // Event type texts in Bengali
  static const Map<String, String> eventTypeTexts = {
    nationalHoliday: 'জাতীয় দিবস',
    culturalHoliday: 'সাংস্কৃতিক দিবস',
    religiousHoliday: 'ধর্মীয় দিবস',
    personalReminder: 'ব্যক্তিগত স্মারক',
  };
  
  // Common Bengali texts
  static const String todayText = 'আজ';
  static const String addReminderText = 'স্মারক যোগ করুন';
  static const String settingsText = 'সেটিংস';
  static const String closeText = 'বন্ধ করুন';
  static const String saveText = 'সংরক্ষণ করুন';
  static const String cancelText = 'বাতিল';
  static const String deleteText = 'মুছে ফেলুন';
  
  // Notification
  static const String reminderChannelId = 'reminder_channel';
  static const String reminderChannelName = 'Personal Reminders';
  static const String reminderChannelDescription = 'Notifications for user reminders';
  
  // Premium features
  static const String premiumMonthlyPrice = '৳৯৯';
  static const String premiumYearlyPrice = '৳৯৯৯';
  
  // API endpoints (for future use)
  static const String baseApiUrl = 'https://api.ekushponji.com';
  static const String holidaysEndpoint = '/holidays';
  static const String personalitiesEndpoint = '/personalities';
}