// lib/app/config/app_config.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppConfig {
  // App Identity
  static const String appName = 'Ekush Ponji';
  static const String version = '1.0.0'; // Changed from appVersion to match usage
  static const String appId = 'com.example.ekushponji'; // Added for future use
  
  // Build Configuration
  static const bool debugShowCheckedModeBanner = false;
  static const bool isDebugMode = true; // Added for development flags
  
  // Localization Configuration
  static const List<LocalizationsDelegate> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  
  static const List<Locale> supportedLocales = [
    Locale('bn', 'BD'), // Bengali (Bangladesh)
    Locale('en', 'US'), // English (US)
  ];
  
  static const Locale defaultLocale = Locale('bn', 'BD');
  
  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0; // Added for consistency
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(milliseconds: 2500); // Added
  
  // Theme Colors (Optional - can be moved to theme file later)
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  
  // Network Configuration (for future API usage)
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  
  // Storage Configuration
  static const String hiveBoxName = 'ekush_ponji_box';
  static const int maxCacheSize = 100; // MB
  
  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  
  // Development helpers
  static void logDebug(String message) {
    if (isDebugMode) {
      debugPrint('[EkushPonji] $message');
    }
  }
  
  static void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('[EkushPonji ERROR] $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null && isDebugMode) debugPrint('StackTrace: $stackTrace');
  }
}