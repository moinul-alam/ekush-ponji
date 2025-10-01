import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Box and key constants
const String settingsBoxName = 'settings';
const String _themeKey = 'themeMode';
const String _languageKey = 'languageCode';

/// Theme Mode Notifier
/// Manages app theme (light/dark/system) with persistent storage
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    try {
      final box = Hive.box(settingsBoxName);
      final savedTheme = box.get(_themeKey, defaultValue: 'light');
      
      switch (savedTheme) {
        case 'dark':
          return ThemeMode.dark;
        case 'system':
          return ThemeMode.system;
        default:
          return ThemeMode.light;
      }
    } catch (e) {
      debugPrint('❌ Error loading theme mode: $e');
      return ThemeMode.light; // Fallback to light theme
    }
  }

  /// Toggle between light and dark theme
  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveToHive();
  }

  /// Set specific theme mode
  void setThemeMode(ThemeMode mode) {
    if (state == mode) return; // No need to update if same
    state = mode;
    _saveToHive();
  }

  /// Save theme mode to persistent storage
  void _saveToHive() {
    try {
      final box = Hive.box(settingsBoxName);
      final themeString = state == ThemeMode.dark 
          ? 'dark' 
          : state == ThemeMode.system 
              ? 'system' 
              : 'light';
      box.put(_themeKey, themeString);
      debugPrint('✅ Theme mode saved: $themeString');
    } catch (e) {
      debugPrint('❌ Error saving theme mode: $e');
    }
  }
}

/// Language Code Notifier
/// Manages app language with persistent storage
class LanguageCodeNotifier extends Notifier<String> {
  @override
  String build() {
    try {
      final box = Hive.box(settingsBoxName);
      return box.get(_languageKey, defaultValue: 'bn'); // Bengali default
    } catch (e) {
      debugPrint('❌ Error loading language code: $e');
      return 'bn'; // Fallback to Bengali
    }
  }

  /// Set app language
  void setLanguage(String newCode) {
    if (state == newCode) return; // No need to update if same
    state = newCode;
    _saveToHive(newCode);
  }

  /// Save language code to persistent storage
  void _saveToHive(String code) {
    try {
      final box = Hive.box(settingsBoxName);
      box.put(_languageKey, code);
      debugPrint('✅ Language code saved: $code');
    } catch (e) {
      debugPrint('❌ Error saving language code: $e');
    }
  }
}

/// Providers
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

final languageProvider =
    NotifierProvider<LanguageCodeNotifier, String>(LanguageCodeNotifier.new);