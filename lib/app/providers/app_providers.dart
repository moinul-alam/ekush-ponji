// lib/app/providers/app_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ekush_ponji/core/services/data_sync_service.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_bottom_nav.dart';

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
    } catch (e) {
      debugPrint('❌ Error saving theme mode: $e');
    }
  }

  void setThemeModeWithFeedback(
      BuildContext context, ThemeMode mode, String message) {
    setThemeMode(mode);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void toggleThemeWithFeedback(BuildContext context, String message) {
    toggleTheme();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
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
      BuildContext context, Locale newLocale) async {
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: success ? Colors.green : Colors.red,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

/// Current Tab Notifier
class CurrentTabNotifier extends Notifier<int> {
  @override
  int build() => AppTab.home;

  void setTab(int tab) {
    if (state == tab) return;
    state = tab;
  }

  void setStandalone() {
    if (state == AppTab.none) return;
    state = AppTab.none;
  }
}

// ── Providers ──────────────────────────────────────────────

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

final currentTabProvider =
    NotifierProvider<CurrentTabNotifier, int>(CurrentTabNotifier.new);

final dataSyncServiceProvider = Provider<DataSyncService>((ref) {
  return DataSyncService();
});

/// Global data-change version used to force reactive refreshes across screens.
/// Increment this whenever events/reminders/user data are mutated.
class AppDataVersionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void markChanged() {
    state = state + 1;
  }
}

final appDataVersionProvider =
    NotifierProvider<AppDataVersionNotifier, int>(AppDataVersionNotifier.new);
