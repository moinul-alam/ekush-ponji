// lib/app/config/app_initializer.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ekush_ponji/core/themes/app_theme.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/core/services/sync_service.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';
import 'package:ekush_ponji/features/words/models/word.dart';
import 'package:ekush_ponji/features/quotes/data/datasources/local/quotes_local_datasource.dart';
import 'package:ekush_ponji/features/words/data/datasources/local/words_local_datasource.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/core/services/background_task_dispatcher.dart';
import 'package:workmanager/workmanager.dart';

class AppInitializer {

  // ── Phase 1: Critical path — runs BEFORE runApp ───────────────────────────
  // Goal: absolute minimum to get first frame on screen.
  // Only opens the 'settings' box — all providers need it at first frame.
  // Everything else deferred to Phase 2.
  // Target: < 30ms total.

  static Future<void> initializeCore() async {
    try {
      // These two are independent — run concurrently
      await Future.wait([
        _setDeviceOrientation(),
        _initializeHiveAndSettings(),
      ]);
      debugPrint('✅ Core initialization completed');
    } catch (e, stackTrace) {
      debugPrint('❌ Core initialization failed: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow; // Fatal — app cannot run without Hive settings box
    }
  }

  // ── Phase 2: Background — runs AFTER runApp + splash is visible ───────────
  // All tasks are independent — run concurrently with Future.wait.
  // Errors are non-fatal — app falls back to cached data gracefully.
  // WorkManager moved here — no need to block Phase 1.

  static Future<void> initializeBackground() async {
    try {
      // Step A: Open remaining Hive boxes + Firebase + SharedPreferences
      // concurrently — none depend on each other
      await Future.wait([
        _openSecondaryHiveBoxes(),
        _initializeFirebase(),
        _initializeSharedPreferences(),
        _initializeWorkManager(),
      ]);

      // Step B: Notifications depends on nothing above but benefits from
      // Firebase being ready. Run after Step A.
      // Sync also starts here — with a hard timeout so it never blocks home.
      await Future.wait([
        _initializeNotifications(),
        _performInitialSyncWithTimeout(),
      ]);

      debugPrint('✅ Background initialization completed');
    } catch (e, stackTrace) {
      debugPrint('❌ Background initialization error: $e');
      debugPrint('StackTrace: $stackTrace');
      // Non-fatal — app proceeds to home with cached data
    }
  }

  // ── Phase 1 Steps ─────────────────────────────────────────────────────────

  static Future<void> _setDeviceOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    debugPrint('✅ Device orientation set');
  }

  /// Initializes Hive, registers all adapters, then opens ONLY the settings
  /// box. Providers read theme + locale from this box on first frame.
  /// All other boxes open in Phase 2.
  static Future<void> _initializeHiveAndSettings() async {
    try {
      await Hive.initFlutter();

      // Register all adapters upfront — cheap, pure Dart
      _registerHiveAdapters();

      // Only open settings — the only box needed before first frame
      await Hive.openBox('settings');

      debugPrint('✅ Hive + settings box ready');
    } catch (e) {
      debugPrint('❌ Hive initialization failed: $e');
      rethrow;
    }
  }

  static void _registerHiveAdapters() {
    Hive.registerAdapter(HolidayAdapter());
    Hive.registerAdapter(HolidayTypeAdapter());
    Hive.registerAdapter(QuoteModelAdapter());
    Hive.registerAdapter(WordModelAdapter());
    debugPrint('✅ Hive adapters registered');
  }

  // ── Phase 2 Steps ─────────────────────────────────────────────────────────

  /// Opens all boxes not needed at first frame
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

  static Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      debugPrint('✅ Firebase initialized');
    } catch (e) {
      debugPrint('❌ Firebase initialization failed: $e');
      rethrow;
    }
  }

  static Future<void> _initializeSharedPreferences() async {
    try {
      // Warms up the SharedPreferences singleton so first read is instant
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
      await Workmanager().registerOneOffTask(
        kReschedulePrayerTask,
        kReschedulePrayerTask,
        initialDelay: const Duration(seconds: 30),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        constraints: Constraints(networkType: NetworkType.notRequired),
      );
      debugPrint('✅ WorkManager initialized and boot task registered');
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

  /// Holiday sync with a hard 5-second timeout.
  /// If network is slow or offline, app proceeds immediately.
  /// Sync will retry next launch or via background task.
  static Future<void> _performInitialSyncWithTimeout() async {
    try {
      debugPrint('🔄 Starting holiday sync...');
      final syncService = SyncService();
      final success = await syncService
          .syncHolidays()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('⏱️ Holiday sync timed out — using cached data');
              return false;
            },
          );
      debugPrint(success
          ? '✅ Holiday sync completed'
          : '⚠️ Holiday sync failed — using cached data');
    } catch (e) {
      debugPrint('⚠️ Holiday sync error: $e');
    }
  }

  // ── System UI ─────────────────────────────────────────────────────────────

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

  // ── Cleanup ───────────────────────────────────────────────────────────────

  static Future<void> dispose() async {
    try {
      await Hive.close();
      debugPrint('✅ Hive boxes closed');
    } catch (e) {
      debugPrint('❌ Failed to close Hive boxes: $e');
    }
  }
}