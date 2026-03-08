import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';

class SettingsViewModel extends BaseViewModel {
  static const String _notificationsKey = 'notifications_enabled';
  static const String _autoBackupKey = 'auto_backup_enabled';

  // Cached instance — fetched once in loadSettings, reused everywhere
  SharedPreferences? _prefs;

  bool _notificationsEnabled = true;
  bool _autoBackupEnabled = false;

  bool get notificationsEnabled => _notificationsEnabled;

  /// Auto-backup is not yet implemented. Always returns false so the switch
  /// stays off. The UI intercepts the toggle and shows "coming soon".
  bool get autoBackupEnabled => false;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    await executeAsync(
      operation: () async {
        // Fetch and cache once here — all subsequent calls reuse _prefs
        _prefs = await SharedPreferences.getInstance();
        _notificationsEnabled = _prefs!.getBool(_notificationsKey) ?? true;
        _autoBackupEnabled = _prefs!.getBool(_autoBackupKey) ?? false;
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

  /// No-op kept for API compatibility. Auto-backup is not implemented yet.
  Future<void> toggleAutoBackup(bool value) async {
    _autoBackupEnabled = false;
    await _saveSetting(_autoBackupKey, false);
  }

  /// Clears user personal data (events, reminders, etc.) stored outside
  /// of SharedPreferences. Settings/preferences are NOT touched.
  Future<void> clearAllData() async {
    await executeAsync(
      operation: () async {
        // TODO: clear Hive boxes that hold user events, reminders, etc.
        // e.g. await Hive.box('events').clear();
        //      await Hive.box('reminders').clear();
      },
      loadingMessage: 'Clearing all data...',
      successMessage: 'All data cleared successfully',
      errorMessage: 'Failed to clear data',
    );
  }

  /// Resets all user preferences to defaults and propagates to Riverpod
  /// providers so the UI updates immediately — no restart required.
  Future<void> resetSettings(WidgetRef ref) async {
    await executeAsync(
      operation: () async {
        // 1. Wipe SharedPreferences using cached instance
        final prefs = _prefs ?? await SharedPreferences.getInstance();
        await prefs.clear();

        // 2. Reset in-memory viewmodel state
        _notificationsEnabled = true;
        _autoBackupEnabled = false;

        // 3. Reset Riverpod providers so theme/locale widgets rebuild instantly
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

  // Uses cached _prefs — no repeated getInstance() calls
  Future<void> _saveSetting(String key, bool value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, ViewState>(
  () => SettingsViewModel(),
);