import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Box and key constants
const String settingsBoxName = 'settings';
const String _themeKey = 'themeMode';
const String _localeKey = 'languageCode';

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

/// Locale Notifier
/// Manages app locale (language) with persistent storage
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    try {
      final box = Hive.box(settingsBoxName);
      final savedLanguage = box.get(_localeKey, defaultValue: 'bn');
      return _getLocaleFromCode(savedLanguage);
    } catch (e) {
      debugPrint('❌ Error loading locale: $e');
      return const Locale('bn', 'BD'); // Fallback to Bengali
    }
  }

  /// Change the app locale
  Future<void> setLocale(Locale newLocale) async {
    try {
      if (state.languageCode == newLocale.languageCode) return;

      // Update state
      state = newLocale;

      // Persist to Hive
      final box = Hive.box(settingsBoxName);
      await box.put(_localeKey, newLocale.languageCode);

      debugPrint('✅ Locale changed to: ${newLocale.languageCode}');
    } catch (e) {
      debugPrint('❌ Error saving locale: $e');
    }
  }

  /// Switch between available languages
  Future<void> toggleLanguage() async {
    final newLocale = state.languageCode == 'en'
        ? const Locale('bn', 'BD')
        : const Locale('en', 'US');
    await setLocale(newLocale);
  }

  /// Get locale from language code
  Locale _getLocaleFromCode(String code) {
    switch (code) {
      case 'bn':
        return const Locale('bn', 'BD');
      case 'en':
        return const Locale('en', 'US');
      default:
        return const Locale('bn', 'BD');
    }
  }

  /// Get language code from state
  String get languageCode => state.languageCode;

  /// Check if current locale is Bangla
  bool get isBangla => state.languageCode == 'bn';

  /// Check if current locale is English
  bool get isEnglish => state.languageCode == 'en';

  /// Get current language name
  String get currentLanguageName {
    return state.languageCode == 'bn' ? 'বাংলা' : 'English';
  }
}

/// Providers
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
