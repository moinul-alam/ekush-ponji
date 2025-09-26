// lib/services/settings_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;
  final bool notificationsEnabled;
  final bool soundEnabled;

  AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('bn', 'BD'), // Default to Bengali
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
  static const String _themeKey = 'theme_mode';
  static const String _localeKey = 'locale';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _soundKey = 'sound_enabled';

  // Load all settings
  Future<AppSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme mode
      final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
      final themeMode = ThemeMode.values[themeIndex];
      
      // Load locale
      final localeCode = prefs.getString(_localeKey) ?? 'bn';
      final locale = localeCode == 'bn' 
          ? const Locale('bn', 'BD') 
          : const Locale('en', 'US');
      
      // Load notification settings
      final notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
      final soundEnabled = prefs.getBool(_soundKey) ?? true;
      
      return AppSettings(
        themeMode: themeMode,
        locale: locale,
        notificationsEnabled: notificationsEnabled,
        soundEnabled: soundEnabled,
      );
    } catch (e) {
      print('Error loading settings: $e');
      // Return default settings on error
      return AppSettings();
    }
  }

  // Save all settings
  Future<void> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, settings.themeMode.index);
      await prefs.setString(_localeKey, settings.locale.languageCode);
      await prefs.setBool(_notificationsKey, settings.notificationsEnabled);
      await prefs.setBool(_soundKey, settings.soundEnabled);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  // Individual setting methods for convenience
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);
    } catch (e) {
      print('Error saving theme mode: $e');
      rethrow;
    }
  }

  Future<void> saveLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      print('Error saving locale: $e');
      rethrow;
    }
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsKey, enabled);
    } catch (e) {
      print('Error saving notifications setting: $e');
    }
  }

  Future<void> saveSoundEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundKey, enabled);
    } catch (e) {
      print('Error saving sound setting: $e');
    }
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
