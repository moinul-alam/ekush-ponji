// lib/features/settings/settings_viewmodel.dart

import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/services/data_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';
import 'package:ekush_ponji/features/home/home_viewmodel.dart';
import 'package:ekush_ponji/features/onboarding/onboarding_viewmodel.dart';

class SettingsViewModel extends BaseViewModel {
  static const String _notificationsKey = 'notifications_enabled';
  static const String _autoBackupKey = 'auto_backup_enabled';
  static const String _prayerTimesEnabledKey = 'prayer_times_enabled';

  SharedPreferences? _prefs;
  bool _notificationsEnabled = true;
  bool _prayerTimesEnabled = true;
  DataSyncResult? _lastSyncResult;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get prayerTimesEnabled => _prayerTimesEnabled;
  bool get autoBackupEnabled => false;
  DataSyncResult? get lastSyncResult => _lastSyncResult;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    await executeAsync(
      operation: () async {
        _prefs = await SharedPreferences.getInstance();
        _notificationsEnabled = _prefs!.getBool(_notificationsKey) ?? true;
        // Prayer times pref lives in Hive (set during onboarding)
        final box = Hive.box('settings');
        _prayerTimesEnabled = box.get(_prayerTimesEnabledKey, defaultValue: true) as bool;
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
      successMessage:
          value ? 'Notifications enabled' : 'Notifications disabled',
      errorMessage: 'Failed to update notifications',
      showLoading: false,
    );
  }

  Future<void> togglePrayerTimes(bool value, WidgetRef ref) async {
    await executeAsync(
      operation: () async {
        _prayerTimesEnabled = value;
        final box = Hive.box('settings');
        await box.put(_prayerTimesEnabledKey, value);
        // Invalidate so bottom nav and any other listeners update immediately
        ref.invalidate(prayerTimesEnabledProvider);
      },
      successMessage:
          value ? 'Prayer times enabled' : 'Prayer times disabled',
      errorMessage: 'Failed to update prayer times',
      showLoading: false,
    );
  }

  Future<void> toggleAutoBackup(bool value) async {
    await _saveSetting(_autoBackupKey, false);
  }

  Future<void> clearAllData() async {
    await executeAsync(
      operation: () async {
        // TODO: clear Hive boxes for events, reminders, etc.
      },
      loadingMessage: 'Clearing all data...',
      successMessage: 'All data cleared successfully',
      errorMessage: 'Failed to clear data',
    );
  }

  Future<void> resetSettings(WidgetRef ref) async {
    await executeAsync(
      operation: () async {
        final prefs = _prefs ?? await SharedPreferences.getInstance();
        await prefs.clear();
        _notificationsEnabled = true;
        ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
        await ref
            .read(localeProvider.notifier)
            .setLocale(const Locale('bn', 'BD'));
      },
      loadingMessage: 'Resetting settings...',
      successMessage: 'Settings reset to defaults',
      errorMessage: 'Failed to reset settings',
    );
  }

  /// Full data sync — holidays + quotes + words in parallel.
  /// Called from the Settings "Data Sync" section.
  Future<void> syncAllData({required WidgetRef widgetRef}) async {
    _lastSyncResult = null;
    setLoading(message: 'Syncing data...');
    try {
      final syncService = widgetRef.read(dataSyncServiceProvider);
      _lastSyncResult = await syncService.forceSync().timeout(
            const Duration(seconds: 30),
            onTimeout: () => const DataSyncResult(
              success: false,
              holidaysUpdated: false,
              quotesUpdated: false,
              wordsUpdated: false,
            ),
          );

      // Invalidate home if any content changed
      if (_lastSyncResult!.anyUpdated) {
        widgetRef.invalidate(homeViewModelProvider);
      }

      setSuccess(message: _lastSyncResult!.summary(isBn: false));
    } catch (e, st) {
      handleError(e, st, customMessage: 'Sync failed — check your connection');
    }
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, ViewState>(
  SettingsViewModel.new,
);