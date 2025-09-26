// lib/app/config/app_config.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppConfig {
  // App Identity
  static const String appName = 'Ekush Ponji';
  static const String appVersion = '1.0.0';
  
  // Build Configuration
  static const bool debugShowCheckedModeBanner = false;
  
  // Localization Configuration
  static const List<LocalizationsDelegate> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  
  static const List<Locale> supportedLocales = [
    Locale('bn', 'BD'),
    Locale('en', 'US'),
  ];
  
  static const Locale defaultLocale = Locale('bn', 'BD');
  
  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}