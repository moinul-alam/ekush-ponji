import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/services/data_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';
import 'package:ekush_ponji/features/home/home_viewmodel.dart';
import 'package:ekush_ponji/features/reminders/data/reminder_repository.dart';
import 'package:ekush_ponji/features/events/data/event_repository.dart';
import 'package:ekush_ponji/features/reminders/services/reminder_notification_service.dart';
import 'package:ekush_ponji/features/events/services/event_notification_service.dart';
import 'package:ekush_ponji/features/calendar/data/local/calendar_local_datasource.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';
import 'package:ekush_ponji/features/words/models/word.dart';
import 'package:ekush_ponji/features/quotes/data/datasources/local/quotes_local_datasource.dart'
    show savedQuotesBoxName;
import 'package:ekush_ponji/features/words/data/datasources/local/words_local_datasource.dart'
    show savedWordsBoxName;
import 'package:ekush_ponji/features/quotes/quotes_viewmodel.dart'
    show quotesViewModelProvider;
import 'package:ekush_ponji/features/words/words_viewmodel.dart'
    show wordsViewModelProvider;
import 'package:ekush_ponji/features/calendar/calendar_viewmodel.dart'
    show calendarViewModelProvider;

class SettingsViewModel extends BaseViewModel {
  static const String _notificationsKey = 'notifications_enabled';

  SharedPreferences? _prefs;
  bool _notificationsEnabled = true;
  DataSyncResult? _lastSyncResult;

  bool get notificationsEnabled => _notificationsEnabled;
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
      successMessage: null,
      errorMessage: null,
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
      successMessage: null,
      errorMessage: null,
      showLoading: false,
    );
  }

  Future<void> toggleNotifications(bool value) async {
    await executeAsync(
      operation: () async {
        _notificationsEnabled = value;
        await _saveSetting(_notificationsKey, value);
      },
      successMessage: null,
      errorMessage: null,
      showLoading: false,
    );
  }

  // Resets only language and theme preferences to defaults (Bengali + Light).
  Future<void> resetSettings(WidgetRef ref, AppLocalizations l10n) async {
    await executeAsync(
      operation: () async {
        final prefs = _prefs ?? await SharedPreferences.getInstance();
        await prefs.remove('themeMode');
        await prefs.remove('languageCode');

        ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
        await ref
            .read(localeProvider.notifier)
            .setLocale(const Locale('bn', 'BD'));
      },
      loadingMessage: 'Resetting settings...',
      successMessage: l10n.resetSettingsSuccessMessage,
      errorMessage: '${l10n.error}: ${l10n.resetSettings}',
    );
  }

  // Clears all user data: events, reminders, custom holidays, saved quotes/words,
  // and resets language/theme preferences. Does NOT touch holiday/quote/word notifications.
  Future<void> clearAllData(WidgetRef ref, AppLocalizations l10n) async {
    await executeAsync(
      operation: () async {
        // Cancel all scheduled event notifications before deleting records
        final eventRepo = EventRepository();
        final events = await eventRepo.getAllEvents();
        for (final e in events) {
          await EventNotificationService.cancel(e);
        }

        // Cancel all scheduled reminder notifications before deleting records
        final reminderRepo = ReminderRepository();
        final reminders = await reminderRepo.getAllReminders();
        for (final r in reminders) {
          await ReminderNotificationService.cancel(r);
        }

        // Ensure boxes are open before clearing
        if (!Hive.isBoxOpen('events')) await Hive.openBox('events');
        if (!Hive.isBoxOpen('reminders')) await Hive.openBox('reminders');

        await Hive.box('events').clear();
        await Hive.box('reminders').clear();

        // Clear custom holidays
        final calendarLocalDs = CalendarLocalDatasource();
        final customHolidays = await calendarLocalDs.getCustomHolidays();
        for (final h in customHolidays) {
          await calendarLocalDs.deleteCustomHoliday(h.id);
        }

        // Clear saved quotes and words
        if (!Hive.isBoxOpen(savedQuotesBoxName)) {
          await Hive.openBox<QuoteModel>(savedQuotesBoxName);
        }
        if (!Hive.isBoxOpen(savedWordsBoxName)) {
          await Hive.openBox<WordModel>(savedWordsBoxName);
        }
        await Hive.box<QuoteModel>(savedQuotesBoxName).clear();
        await Hive.box<WordModel>(savedWordsBoxName).clear();

        // Reset language and theme preferences
        final prefs = _prefs ?? await SharedPreferences.getInstance();
        await prefs.remove('themeMode');
        await prefs.remove('languageCode');

        ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
        await ref
            .read(localeProvider.notifier)
            .setLocale(const Locale('bn', 'BD'));

        // Invalidate viewmodels so saved lists reflect the cleared state
        ref.invalidate(quotesViewModelProvider);
        ref.invalidate(wordsViewModelProvider);
        ref.invalidate(homeViewModelProvider);
        ref.invalidate(calendarViewModelProvider);
        ref.read(appDataVersionProvider.notifier).markChanged();
      },
      loadingMessage: 'Clearing data...',
      successMessage: l10n.deleteAllDataSuccessMessage,
      errorMessage: '${l10n.error}: ${l10n.deleteAllData}',
    );
  }

  Future<void> syncAllData({
    required WidgetRef widgetRef,
    required AppLocalizations l10n,
  }) async {
    _lastSyncResult = null;
    setLoading(message: 'Updating data...');
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

      if (_lastSyncResult!.anyUpdated) {
        widgetRef.invalidate(homeViewModelProvider);
      }

      setSuccess(message: _lastSyncResult!.summary(l10n));
    } catch (e, st) {
      handleError(e, st, customMessage: l10n.syncFailed);
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
