import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

/// Theme Mode Notifier
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // TODO: Load from local storage in future
    return ThemeMode.light;
  }

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

/// Language Code Notifier
class LanguageCodeNotifier extends Notifier<String> {
  @override
  String build() {
    // TODO: Load from local storage in future
    return 'bn'; // Bengali
  }

  void setLanguage(String newCode) {
    state = newCode;
  }
}

/// Theme Mode Provider
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Language Provider
final languageProvider = NotifierProvider<LanguageCodeNotifier, String>(
  LanguageCodeNotifier.new,
);