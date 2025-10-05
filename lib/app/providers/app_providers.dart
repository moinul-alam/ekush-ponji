// lib/app/providers/app_providers.dart

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
  Future<bool> setLocale(Locale newLocale) async {
    try {
      if (state.languageCode == newLocale.languageCode) {
        debugPrint('⚠️ Locale already set to: ${newLocale.languageCode}');
        return false; // No change needed
      }

      // Validate locale
      if (!_isValidLocale(newLocale)) {
        debugPrint('❌ Invalid locale: ${newLocale.languageCode}');
        return false;
      }

      // Update state
      state = newLocale;

      // Persist to Hive
      final box = Hive.box(settingsBoxName);
      await box.put(_localeKey, newLocale.languageCode);

      debugPrint('✅ Locale changed to: ${newLocale.languageCode}');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving locale: $e');
      return false;
    }
  }

  /// Switch between available languages
  Future<bool> toggleLanguage() async {
    final newLocale = state.languageCode == 'en'
        ? const Locale('bn', 'BD')
        : const Locale('en', 'US');
    return await setLocale(newLocale);
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

  /// Validate locale
  bool _isValidLocale(Locale locale) {
    return ['bn', 'en'].contains(locale.languageCode);
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

  /// Get current language display name with flag
  String get currentLanguageDisplay {
    return state.languageCode == 'bn' ? '🇧🇩 বাংলা' : '🇺🇸 English';
  }

  /// Get opposite language (for toggle button)
  String get oppositeLanguageName {
    return state.languageCode == 'bn' ? 'English' : 'বাংলা';
  }

  /// Get list of available locales
  List<Locale> get availableLocales => const [
        Locale('bn', 'BD'),
        Locale('en', 'US'),
      ];
}

/// Providers
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

// ========================================
// HELPER EXTENSIONS FOR UI
// ========================================

/// Extension to show SnackBar for locale changes
extension LocaleNotifierUI on LocaleNotifier {
  /// Change locale and show feedback
  Future<void> setLocaleWithFeedback(
    BuildContext context,
    Locale newLocale,
  ) async {
    final success = await setLocale(newLocale);

    if (!context.mounted) return;

    if (success) {
      _showSuccessSnackBar(context);
    } else {
      _showErrorSnackBar(context);
    }
  }

  /// Toggle language and show feedback
  Future<void> toggleLanguageWithFeedback(BuildContext context) async {
    final success = await toggleLanguage();

    if (!context.mounted) return;

    if (success) {
      _showSuccessSnackBar(context);
    } else {
      _showErrorSnackBar(context);
    }
  }

  /// Show success SnackBar
  void _showSuccessSnackBar(BuildContext context) {
    // Get localized message based on NEW language
    final message = state.languageCode == 'bn'
        ? 'ভাষা পরিবর্তিত হয়েছে'
        : 'Language changed';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Show error SnackBar
  void _showErrorSnackBar(BuildContext context) {
    final message = state.languageCode == 'bn'
        ? 'ভাষা পরিবর্তন ব্যর্থ হয়েছে'
        : 'Failed to change language';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

/// Extension to show SnackBar for theme changes
extension ThemeModeNotifierUI on ThemeModeNotifier {
  /// Set theme mode and show feedback
  void setThemeModeWithFeedback(
    BuildContext context,
    ThemeMode mode,
    String message,
  ) {
    setThemeMode(mode);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Toggle theme and show feedback
  void toggleThemeWithFeedback(BuildContext context, String message) {
    toggleTheme();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
