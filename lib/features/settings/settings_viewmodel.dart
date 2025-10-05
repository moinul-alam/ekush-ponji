// lib/features/settings/settings_viewmodel.dart

import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';

class SettingsViewModel extends BaseViewModel {
  static const String _notificationsKey = 'notifications_enabled';
  static const String _autoBackupKey = 'auto_backup_enabled';
  static const String _soundKey = 'sound_enabled';
  static const String _vibrationKey = 'vibration_enabled';

  bool _notificationsEnabled = true;
  bool _autoBackupEnabled = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoBackupEnabled => _autoBackupEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    await executeAsync(
      operation: () async {
        final prefs = await SharedPreferences.getInstance();
        _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
        _autoBackupEnabled = prefs.getBool(_autoBackupKey) ?? false;
        _soundEnabled = prefs.getBool(_soundKey) ?? true;
        _vibrationEnabled = prefs.getBool(_vibrationKey) ?? true;
      },
      loadingMessage: 'Loading settings...',
      successMessage: null,
      errorMessage: 'Failed to load settings',
    );
  }

  Future<void> changeTheme(ThemeMode mode, WidgetRef ref) async {
    await executeAsync(
      operation: () async {
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
      },
      successMessage: 'Theme changed successfully',
      errorMessage: 'Failed to change theme',
      showLoading: false,
    );
  }

  Future<void> changeLanguage(String languageCode, WidgetRef ref) async {
    await executeAsync(
      operation: () async {
        final locale = languageCode == 'bn'
            ? const Locale('bn', 'BD')
            : const Locale('en', 'US');
        await ref.read(localeProvider.notifier).setLocale(locale);
      },
      successMessage: 'Language changed successfully',
      errorMessage: 'Failed to change language',
      showLoading: false,
    );
  }

  Future<void> toggleNotifications(bool value) async {
    await executeAsync(
      operation: () async {
        _notificationsEnabled = value;
        await _saveSetting(_notificationsKey, value);
      },
      successMessage: value ? 'Notifications enabled' : 'Notifications disabled',
      errorMessage: 'Failed to update notifications',
      showLoading: false,
    );
  }

  Future<void> toggleAutoBackup(bool value) async {
    await executeAsync(
      operation: () async {
        _autoBackupEnabled = value;
        await _saveSetting(_autoBackupKey, value);
      },
      successMessage: value ? 'Auto backup enabled' : 'Auto backup disabled',
      errorMessage: 'Failed to update auto backup',
      showLoading: false,
    );
  }

  Future<void> toggleSound(bool value) async {
    await executeAsync(
      operation: () async {
        _soundEnabled = value;
        await _saveSetting(_soundKey, value);
      },
      successMessage: value ? 'Sound enabled' : 'Sound disabled',
      errorMessage: 'Failed to update sound',
      showLoading: false,
    );
  }

  Future<void> toggleVibration(bool value) async {
    await executeAsync(
      operation: () async {
        _vibrationEnabled = value;
        await _saveSetting(_vibrationKey, value);
      },
      successMessage: value ? 'Vibration enabled' : 'Vibration disabled',
      errorMessage: 'Failed to update vibration',
      showLoading: false,
    );
  }

  Future<void> clearAllData() async {
    await executeAsync(
      operation: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        _notificationsEnabled = true;
        _autoBackupEnabled = false;
        _soundEnabled = true;
        _vibrationEnabled = true;
      },
      loadingMessage: 'Clearing all data...',
      successMessage: 'All data cleared successfully',
      errorMessage: 'Failed to clear data',
    );
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, ViewState>(
  () => SettingsViewModel(),
);