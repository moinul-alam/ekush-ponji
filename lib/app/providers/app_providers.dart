// lib/app/providers/app_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ekush_ponji/core/services/data_sync_service.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/features/onboarding/onboarding_viewmodel.dart';

// ── Box and key constants ──────────────────────────────────
const String settingsBoxName = 'settings';
const String _themeKey = 'themeMode';
const String _localeKey = 'languageCode';

/// Theme Mode Notifier
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
      return ThemeMode.light;
    }
  }

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveToHive();
  }

  void setThemeMode(ThemeMode mode) {
    if (state == mode) return;
    state = mode;
    _saveToHive();
  }

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void toggleThemeWithFeedback(BuildContext context, String message) {
    toggleTheme();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

/// Locale Notifier
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    try {
      final box = Hive.box(settingsBoxName);
      final savedLanguage = box.get(_localeKey, defaultValue: 'bn');
      return _getLocaleFromCode(savedLanguage);
    } catch (e) {
      debugPrint('❌ Error loading locale: $e');
      return const Locale('bn', 'BD');
    }
  }

  Future<bool> setLocale(Locale newLocale) async {
    try {
      if (state.languageCode == newLocale.languageCode) return false;
      if (!_isValidLocale(newLocale)) return false;
      state = newLocale;
      final box = Hive.box(settingsBoxName);
      await box.put(_localeKey, newLocale.languageCode);
      debugPrint('✅ Locale changed to: ${newLocale.languageCode}');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving locale: $e');
      return false;
    }
  }

  Future<bool> toggleLanguage() async {
    final newLocale = state.languageCode == 'en'
        ? const Locale('bn', 'BD')
        : const Locale('en', 'US');
    return await setLocale(newLocale);
  }

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

  bool _isValidLocale(Locale locale) =>
      ['bn', 'en'].contains(locale.languageCode);

  String get languageCode => state.languageCode;
  bool get isBangla => state.languageCode == 'bn';
  bool get isEnglish => state.languageCode == 'en';
  String get currentLanguageName =>
      state.languageCode == 'bn' ? 'বাংলা' : 'English';
  String get currentLanguageDisplay =>
      state.languageCode == 'bn' ? '🇧🇩 বাংলা' : '🇺🇸 English';
  String get oppositeLanguageName =>
      state.languageCode == 'bn' ? 'English' : 'বাংলা';
  List<Locale> get availableLocales => const [
        Locale('bn', 'BD'),
        Locale('en', 'US'),
      ];

  Future<void> setLocaleWithFeedback(
    BuildContext context,
    Locale newLocale,
  ) async {
    final success = await setLocale(newLocale);
    if (!context.mounted) return;
    _showFeedback(context, success);
  }

  Future<void> toggleLanguageWithFeedback(BuildContext context) async {
    final success = await toggleLanguage();
    if (!context.mounted) return;
    _showFeedback(context, success);
  }

  void _showFeedback(BuildContext context, bool success) {
    final message = success
        ? (state.languageCode == 'bn'
            ? 'ভাষা পরিবর্তিত হয়েছে'
            : 'Language changed')
        : (state.languageCode == 'bn'
            ? 'ভাষা পরিবর্তন ব্যর্থ হয়েছে'
            : 'Failed to change language');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? Colors.green : Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

/// App Readiness Notifier — flips to true when background init completes
class AppReadyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setReady() => state = true;
}

// ── Providers ──────────────────────────────────────────────

final appReadyProvider = NotifierProvider<AppReadyNotifier, bool>(
  AppReadyNotifier.new,
);

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

/// Singleton DataSyncService — shared across the entire app.
final dataSyncServiceProvider = Provider<DataSyncService>((ref) {
  return DataSyncService();
});

/// Reads onboarding status exactly once from Hive (already open in Phase 1)
/// and returns the correct initial route. Cached for the lifetime of the
/// provider — no repeated Hive reads, no UI-thread disk calls.
final initialDestinationProvider = Provider<String>((ref) {
  return isOnboardingDone() ? RouteNames.home : RouteNames.onboarding;
});