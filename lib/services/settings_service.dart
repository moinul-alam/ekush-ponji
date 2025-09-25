import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekush_ponji/constants/constants.dart';

class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;
  final bool notificationsEnabled;
  final bool soundEnabled;

  AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale = AppConstants.defaultLocale,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'languageCode': locale.languageCode,
      'countryCode': locale.countryCode,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      themeMode: ThemeMode.values[map['themeMode'] ?? 0],
      locale: Locale(
        map['languageCode'] ?? 'bn',
        map['countryCode'] ?? 'BD',
      ),
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      soundEnabled: map['soundEnabled'] ?? true,
    );
  }

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? notificationsEnabled,
    bool? soundEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}

class SettingsService {
  static const String _settingsKey = 'app_settings';
  late Box _settingsBox;

  SettingsService() {
    _settingsBox = Hive.box(AppConstants.settingsBoxName);
  }

  // Load all settings
  Future<AppSettings> loadSettings() async {
    try {
      final settingsMap = _settingsBox.get(_settingsKey);
      if (settingsMap != null) {
        return AppSettings.fromMap(Map<String, dynamic>.from(settingsMap));
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
    
    // Return default settings if none found or error occurred
    return AppSettings();
  }

  // Save all settings
  Future<void> saveSettings(AppSettings settings) async {
    try {
      await _settingsBox.put(_settingsKey, settings.toMap());
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  // Individual setting methods for convenience
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final currentSettings = await loadSettings();
    await saveSettings(currentSettings.copyWith(themeMode: themeMode));
  }

  Future<void> saveLocale(Locale locale) async {
    final currentSettings = await loadSettings();
    await saveSettings(currentSettings.copyWith(locale: locale));
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    final currentSettings = await loadSettings();
    await saveSettings(currentSettings.copyWith(notificationsEnabled: enabled));
  }

  Future<void> saveSoundEnabled(bool enabled) async {
    final currentSettings = await loadSettings();
    await saveSettings(currentSettings.copyWith(soundEnabled: enabled));
  }

  // Get individual settings
  Future<ThemeMode> getThemeMode() async {
    final settings = await loadSettings();
    return settings.themeMode;
  }

  Future<Locale> getLocale() async {
    final settings = await loadSettings();
    return settings.locale;
  }

  Future<bool> getNotificationsEnabled() async {
    final settings = await loadSettings();
    return settings.notificationsEnabled;
  }

  Future<bool> getSoundEnabled() async {
    final settings = await loadSettings();
    return settings.soundEnabled;
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    await saveSettings(AppSettings());
  }
}