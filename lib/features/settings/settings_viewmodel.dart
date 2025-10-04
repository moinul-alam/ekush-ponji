import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';

/// ViewModel for Settings Screen
/// Manages app settings including theme, language, notifications, etc.
class SettingsViewModel extends BaseViewModel<ViewState> {
  // Settings keys
  static const String _notificationsKey = 'notifications_enabled';
  static const String _autoBackupKey = 'auto_backup_enabled';
  static const String _soundKey = 'sound_enabled';
  static const String _vibrationKey = 'vibration_enabled';

  // State variables
  bool _notificationsEnabled = true;
  bool _autoBackupEnabled = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoBackupEnabled => _autoBackupEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  /// Load all settings from storage
  Future<void> loadSettings() async {
    try {
      setLoading('Loading settings...');

      final prefs = await SharedPreferences.getInstance();

      _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
      _autoBackupEnabled = prefs.getBool(_autoBackupKey) ?? false;
      _soundEnabled = prefs.getBool(_soundKey) ?? true;
      _vibrationEnabled = prefs.getBool(_vibrationKey) ?? true;

      setSuccess(message: 'Settings loaded');
    } catch (e, stackTrace) {
      handleError(e, stackTrace, customMessage: 'Failed to load settings');
    }
  }

  /// Change theme mode
  Future<void> changeTheme(ThemeMode mode, WidgetRef ref) async {
    try {
      ref.read(themeModeProvider.notifier).setThemeMode(mode);
      setSuccess(message: 'Theme changed successfully');
    } catch (e, stackTrace) {
      handleError(e, stackTrace, customMessage: 'Failed to change theme');
    }
  }

  /// Change language
  // Future<void> changeLanguage(String languageCode, WidgetRef ref) async {
  //   try {
  //     // Update Hive storage (existing provider)
  //     ref.read(languageProvider.notifier).setLanguage(languageCode);

  //     // Update locale provider (SharedPreferences) for localization system
  //     final locale = languageCode == 'bn'
  //         ? const Locale('bn', 'BD')
  //         : const Locale('en', 'US');
  //     await ref.read(localeProvider.notifier).setLocale(locale);

  //     setSuccess(message: 'Language changed successfully');
  //   } catch (e, stackTrace) {
  //     handleError(e, stackTrace, customMessage: 'Failed to change language');
  //   }
  // }
  /// Change language
  Future<void> changeLanguage(String languageCode, WidgetRef ref) async {
    try {
      final locale = languageCode == 'bn'
          ? const Locale('bn', 'BD')
          : const Locale('en', 'US');

      // Only need to update one provider now
      await ref.read(localeProvider.notifier).setLocale(locale);

      setSuccess(message: 'Language changed successfully');
    } catch (e, stackTrace) {
      handleError(e, stackTrace, customMessage: 'Failed to change language');
    }
  }

  /// Toggle notifications
  Future<void> toggleNotifications(bool value) async {
    try {
      _notificationsEnabled = value;
      await _saveSetting(_notificationsKey, value);

      // TODO: Enable/disable actual notifications here
      // if (value) {
      //   await NotificationService.enable();
      // } else {
      //   await NotificationService.disable();
      // }

      setSuccess(
        message: value ? 'Notifications enabled' : 'Notifications disabled',
      );
    } catch (e, stackTrace) {
      handleError(e, stackTrace,
          customMessage: 'Failed to update notifications');
    }
  }

  /// Toggle auto backup
  Future<void> toggleAutoBackup(bool value) async {
    try {
      _autoBackupEnabled = value;
      await _saveSetting(_autoBackupKey, value);

      // TODO: Enable/disable auto backup service
      // if (value) {
      //   await BackupService.enable();
      // } else {
      //   await BackupService.disable();
      // }

      setSuccess(
        message: value ? 'Auto backup enabled' : 'Auto backup disabled',
      );
    } catch (e, stackTrace) {
      handleError(e, stackTrace, customMessage: 'Failed to update auto backup');
    }
  }

  /// Toggle sound
  Future<void> toggleSound(bool value) async {
    try {
      _soundEnabled = value;
      await _saveSetting(_soundKey, value);
      setSuccess(message: value ? 'Sound enabled' : 'Sound disabled');
    } catch (e, stackTrace) {
      handleError(e, stackTrace, customMessage: 'Failed to update sound');
    }
  }

  /// Toggle vibration
  Future<void> toggleVibration(bool value) async {
    try {
      _vibrationEnabled = value;
      await _saveSetting(_vibrationKey, value);
      setSuccess(message: value ? 'Vibration enabled' : 'Vibration disabled');
    } catch (e, stackTrace) {
      handleError(e, stackTrace, customMessage: 'Failed to update vibration');
    }
  }

  /// Clear all app data (reset to defaults)
  Future<void> clearAllData() async {
    try {
      setLoading('Clearing all data...');

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Reset to defaults
      _notificationsEnabled = true;
      _autoBackupEnabled = false;
      _soundEnabled = true;
      _vibrationEnabled = true;

      setSuccess(message: 'All data cleared successfully');
    } catch (e, stackTrace) {
      handleError(e, stackTrace, customMessage: 'Failed to clear data');
    }
  }

  /// Save a boolean setting
  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}

/// Provider for SettingsViewModel
final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, ViewState>(
  () => SettingsViewModel(),
);
