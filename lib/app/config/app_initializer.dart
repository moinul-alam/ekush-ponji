// lib/app/config/app_initializer.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';
import 'package:ekush_ponji/core/themes/app_theme.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';
import 'package:ekush_ponji/features/words/models/word.dart';
import 'package:ekush_ponji/features/quotes/data/datasources/local/quotes_local_datasource.dart';
import 'package:ekush_ponji/features/words/data/datasources/local/words_local_datasource.dart';
import 'package:ekush_ponji/features/quotes/quotes_viewmodel.dart';
import 'package:ekush_ponji/features/words/words_viewmodel.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/core/services/background_task_dispatcher.dart';
import 'package:ekush_ponji/features/calendar/data/calendar_repository.dart';
import 'package:ekush_ponji/features/holidays/services/holiday_notification_prefs.dart';
import 'package:ekush_ponji/features/holidays/services/holiday_notification_service.dart';
// QuoteNotificationPrefs is accessed via quote_notification_service.dart
import 'package:ekush_ponji/features/quotes/services/quote_notification_service.dart';
// WordNotificationPrefs is accessed via word_notification_service.dart
import 'package:ekush_ponji/features/words/services/word_notification_service.dart';
import 'package:workmanager/workmanager.dart';

class AppInitializer {
  // ── Phase 1: Critical path ─────────────────────────────────

  static Future<void> initializeCore() async {
    try {
      await Future.wait([
        _setDeviceOrientation(),
        _initializeHiveAndSettings(),
      ]);
      await _openSecondaryHiveBoxes();
      debugPrint('✅ Core initialization completed');
    } catch (e, stackTrace) {
      debugPrint('❌ Core initialization failed: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  // ── Phase 2: Background ────────────────────────────────────

  static Future<void> initializeBackground(ProviderContainer container) async {
    try {
      await Future.wait([
        _initializeSharedPreferences(),
        _initializeWorkManager(),
      ]);

      await Future.wait([
        _initializeNotifications(),
        _performDataSyncWithTimeout(container),
      ]);

      await Future.wait([
        _scheduleHolidayNotifications(container),
        _scheduleQuoteNotifications(),
        _scheduleWordNotifications(),
      ]);

      debugPrint('✅ Background initialization completed');
    } catch (e, stackTrace) {
      debugPrint('❌ Background initialization error: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  // ── Phase 1 Steps ──────────────────────────────────────────

  static Future<void> _setDeviceOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    debugPrint('✅ Device orientation set');
  }

  static Future<void> _initializeHiveAndSettings() async {
    try {
      await Hive.initFlutter();
      _registerHiveAdapters();
      await Hive.openBox('settings');
      debugPrint('✅ Hive + settings box ready');
    } catch (e) {
      debugPrint('❌ Hive initialization failed: $e');
      rethrow;
    }
  }

  static void _registerHiveAdapters() {
    Hive.registerAdapter(HolidayAdapter());
    Hive.registerAdapter(GazetteTypeAdapter());
    Hive.registerAdapter(HolidayCategoryAdapter());
    Hive.registerAdapter(QuoteModelAdapter());
    Hive.registerAdapter(WordModelAdapter());
    debugPrint('✅ Hive adapters registered');
  }

  static Future<void> _openSecondaryHiveBoxes() async {
    try {
      await Future.wait([
        Hive.openBox('holidays'),
        Hive.openBox<QuoteModel>(savedQuotesBoxName),
        Hive.openBox<WordModel>(savedWordsBoxName),
      ]);
      debugPrint('✅ Secondary Hive boxes opened');
    } catch (e) {
      debugPrint('⚠️ Secondary Hive boxes warning: $e');
    }
  }

  // ── Phase 2 Steps ──────────────────────────────────────────

  static Future<void> _initializeSharedPreferences() async {
    try {
      await SharedPreferences.getInstance();
      debugPrint('✅ SharedPreferences warmed up');
    } catch (e) {
      debugPrint('⚠️ SharedPreferences warning: $e');
    }
  }

  static Future<void> _initializeWorkManager() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );

      await Future.wait([
        Workmanager().registerOneOffTask(
          kReschedulePrayerTask,
          kReschedulePrayerTask,
          initialDelay: const Duration(seconds: 30),
          existingWorkPolicy: ExistingWorkPolicy.replace,
          constraints: Constraints(networkType: NetworkType.notRequired),
        ),
        Workmanager().registerOneOffTask(
          kRescheduleQuoteTask,
          kRescheduleQuoteTask,
          initialDelay: const Duration(seconds: 30),
          existingWorkPolicy: ExistingWorkPolicy.replace,
          constraints: Constraints(networkType: NetworkType.notRequired),
        ),
        Workmanager().registerOneOffTask(
          kRescheduleWordTask,
          kRescheduleWordTask,
          initialDelay: const Duration(seconds: 30),
          existingWorkPolicy: ExistingWorkPolicy.replace,
          constraints: Constraints(networkType: NetworkType.notRequired),
        ),
      ]);

      debugPrint(
          '✅ WorkManager initialized — prayer, quote, word tasks registered');
    } catch (e) {
      debugPrint('⚠️ WorkManager warning: $e');
    }
  }

  static Future<void> _initializeNotifications() async {
    try {
      await LocalNotificationService.initialize();
      debugPrint('✅ Notifications initialized');
    } catch (e) {
      debugPrint('⚠️ Notifications warning: $e');
    }
  }

  static Future<void> _performDataSyncWithTimeout(
    ProviderContainer container,
  ) async {
    try {
      debugPrint('🌱 Starting data seed + sync...');
      final syncService = container.read(dataSyncServiceProvider);
      await syncService.initialize().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          debugPrint('⏱️ Data sync timed out — using cached/bundled data');
        },
      );

      container.read(quotesViewModelProvider.notifier).loadQuotes();
      container.read(wordsViewModelProvider.notifier).loadWords();

      debugPrint('✅ Quotes + Words viewmodels reloaded after sync');
    } catch (e) {
      debugPrint('⚠️ Data sync error: $e');
    }
  }

  // ── Notification scheduling ────────────────────────────────

  static Future<void> _scheduleHolidayNotifications(
    ProviderContainer container,
  ) async {
    try {
      debugPrint('🔔 Scheduling holiday notifications...');

      final prefs = await HolidayNotificationPrefs.load();
      if (!prefs.enabled) {
        debugPrint('ℹ️ Holiday notifications disabled — skipping');
        return;
      }

      final sp = await SharedPreferences.getInstance();
      final languageCode = sp.getString('languageCode') ?? 'bn';

      final calendarRepo = container.read(calendarRepositoryProvider);
      final holidays = await calendarRepo.getUpcomingHolidays(days: 60);

      if (holidays.isEmpty) {
        debugPrint('ℹ️ No upcoming holidays found — nothing to schedule');
        return;
      }

      await HolidayNotificationService.scheduleAll(
        holidays: holidays,
        prefs: prefs,
        languageCode: languageCode,
      );

      debugPrint(
          '✅ Holiday notifications scheduled (${holidays.length} checked)');
    } catch (e) {
      debugPrint('⚠️ Holiday notification scheduling error: $e');
    }
  }

  static Future<void> _scheduleQuoteNotifications() async {
    try {
      debugPrint('🔔 Scheduling quote notifications...');

      // QuoteNotificationPrefs is accessible via quote_notification_service import
      final prefs = await QuoteNotificationPrefs.load();
      if (!prefs.enabled) {
        debugPrint('ℹ️ Quote notifications disabled — skipping');
        return;
      }

      final sp = await SharedPreferences.getInstance();
      final languageCode = sp.getString('languageCode') ?? 'bn';

      final datasource = QuotesLocalDatasource(
        savedBox: Hive.box<QuoteModel>(savedQuotesBoxName),
        settingsBox: Hive.box('settings'),
      );
      await datasource.init();

      await QuoteNotificationService.scheduleUpcoming(
        datasource: datasource,
        prefs: prefs,
        languageCode: languageCode,
      );

      debugPrint('✅ Quote notifications scheduled');
    } catch (e) {
      debugPrint('⚠️ Quote notification scheduling error: $e');
    }
  }

  static Future<void> _scheduleWordNotifications() async {
    try {
      debugPrint('🔔 Scheduling word notifications...');

      // WordNotificationPrefs is accessible via word_notification_service import
      final prefs = await WordNotificationPrefs.load();
      if (!prefs.enabled) {
        debugPrint('ℹ️ Word notifications disabled — skipping');
        return;
      }

      final sp = await SharedPreferences.getInstance();
      final languageCode = sp.getString('languageCode') ?? 'bn';

      final datasource = WordsLocalDatasource(
        savedBox: Hive.box<WordModel>(savedWordsBoxName),
        settingsBox: Hive.box('settings'),
      );
      await datasource.init();

      await WordNotificationService.scheduleUpcoming(
        datasource: datasource,
        prefs: prefs,
        languageCode: languageCode,
      );

      debugPrint('✅ Word notifications scheduled');
    } catch (e) {
      debugPrint('⚠️ Word notification scheduling error: $e');
    }
  }

  // ── System UI ──────────────────────────────────────────────

  static void updateSystemUIFromTheme(
    BuildContext context,
    ThemeMode themeMode,
  ) {
    final platformBrightness = MediaQuery.of(context).platformBrightness;
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            platformBrightness == Brightness.dark);

    final colorScheme = isDark
        ? AppTheme.darkTheme.colorScheme
        : AppTheme.lightTheme.colorScheme;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: colorScheme.surface,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));
  }

  // ── Cleanup ────────────────────────────────────────────────

  static Future<void> dispose() async {
    try {
      await Hive.close();
      debugPrint('✅ Hive boxes closed');
    } catch (e) {
      debugPrint('❌ Failed to close Hive boxes: $e');
    }
  }
}
