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

  // Cached settings to avoid repeated SharedPreferences access
  AppSettings? _cachedSettings;
  bool _isInitialized = false;

  // Load all settings with better error handling
  Future<AppSettings> loadSettings() async {
    try {
      // Return cached settings if available and app is already initialized
      if (_cachedSettings != null && _isInitialized) {
        return _cachedSettings!;
      }

      final prefs = await SharedPreferences.getInstance();
      
      // Load theme mode with bounds checking
      final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
      final themeMode = (themeIndex >= 0 && themeIndex < ThemeMode.values.length) 
          ? ThemeMode.values[themeIndex] 
          : ThemeMode.system;
      
      // Load locale with validation
      final localeCode = prefs.getString(_localeKey) ?? 'bn';
      final locale = _validateLocale(localeCode);
      
      // Load notification settings
      final notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
      final soundEnabled = prefs.getBool(_soundKey) ?? true;
      
      final settings = AppSettings(
        themeMode: themeMode,
        locale: locale,
        notificationsEnabled: notificationsEnabled,
        soundEnabled: soundEnabled,
      );

      // Cache the loaded settings
      _cachedSettings = settings;
      _isInitialized = true;
      
      debugPrint('Settings loaded successfully: ${settings.toMap()}');
      return settings;
      
    } catch (e, stackTrace) {
      debugPrint('Error loading settings: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Return and cache default settings on error
      final defaultSettings = AppSettings();
      _cachedSettings = defaultSettings;
      _isInitialized = true;
      
      return defaultSettings;
    }
  }

  // Validate and return appropriate locale
  Locale _validateLocale(String localeCode) {
    switch (localeCode.toLowerCase()) {
      case 'bn':
        return const Locale('bn', 'BD');
      case 'en':
        return const Locale('en', 'US');
      default:
        debugPrint('Unknown locale code: $localeCode, defaulting to Bengali');
        return const Locale('bn', 'BD');
    }
  }

  // Save all settings with caching
  Future<void> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save all settings in a batch
      await Future.wait([
        prefs.setInt(_themeKey, settings.themeMode.index),
        prefs.setString(_localeKey, settings.locale.languageCode),
        prefs.setBool(_notificationsKey, settings.notificationsEnabled),
        prefs.setBool(_soundKey, settings.soundEnabled),
      ]);
      
      // Update cache
      _cachedSettings = settings;
      debugPrint('Settings saved successfully');
      
    } catch (e, stackTrace) {
      debugPrint('Error saving settings: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Individual setting methods for convenience with caching
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);
      
      // Update cache
      if (_cachedSettings != null) {
        _cachedSettings = _cachedSettings!.copyWith(themeMode: themeMode);
      }
      
      debugPrint('Theme mode saved: $themeMode');
    } catch (e, stackTrace) {
      debugPrint('Error saving theme mode: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> saveLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      
      // Update cache
      if (_cachedSettings != null) {
        _cachedSettings = _cachedSettings!.copyWith(locale: locale);
      }
      
      debugPrint('Locale saved: $locale');
    } catch (e, stackTrace) {
      debugPrint('Error saving locale: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsKey, enabled);
      
      // Update cache
      if (_cachedSettings != null) {
        _cachedSettings = _cachedSettings!.copyWith(notificationsEnabled: enabled);
      }
      
      debugPrint('Notifications enabled saved: $enabled');
    } catch (e, stackTrace) {
      debugPrint('Error saving notifications setting: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> saveSoundEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundKey, enabled);
      
      // Update cache
      if (_cachedSettings != null) {
        _cachedSettings = _cachedSettings!.copyWith(soundEnabled: enabled);
      }
      
      debugPrint('Sound enabled saved: $enabled');
    } catch (e, stackTrace) {
      debugPrint('Error saving sound setting: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Get individual settings (using cache when available)
  Future<ThemeMode> getThemeMode() async {
    if (_cachedSettings != null && _isInitialized) {
      return _cachedSettings!.themeMode;
    }
    final settings = await loadSettings();
    return settings.themeMode;
  }

  Future<Locale> getLocale() async {
    if (_cachedSettings != null && _isInitialized) {
      return _cachedSettings!.locale;
    }
    final settings = await loadSettings();
    return settings.locale;
  }

  Future<bool> getNotificationsEnabled() async {
    if (_cachedSettings != null && _isInitialized) {
      return _cachedSettings!.notificationsEnabled;
    }
    final settings = await loadSettings();
    return settings.notificationsEnabled;
  }

  Future<bool> getSoundEnabled() async {
    if (_cachedSettings != null && _isInitialized) {
      return _cachedSettings!.soundEnabled;
    }
    final settings = await loadSettings();
    return settings.soundEnabled;
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    try {
      final defaultSettings = AppSettings();
      await saveSettings(defaultSettings);
      debugPrint('Settings reset to defaults');
    } catch (e) {
      debugPrint('Error resetting settings to defaults: $e');
      rethrow;
    }
  }

  // Clear cache (useful for testing or troubleshooting)
  void clearCache() {
    _cachedSettings = null;
    _isInitialized = false;
    debugPrint('Settings cache cleared');
  }

  // Check if settings are initialized
  bool get isInitialized => _isInitialized;

  // Get cached settings (null if not loaded yet)
  AppSettings? get cachedSettings => _cachedSettings;
}