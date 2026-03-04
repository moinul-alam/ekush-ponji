// lib/app/config/app_initializer.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';
import 'package:ekush_ponji/core/themes/app_theme.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/core/services/sync_service.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';
import 'package:ekush_ponji/features/words/models/word.dart';
import 'package:ekush_ponji/features/quotes/data/datasources/local/quotes_local_datasource.dart';
import 'package:ekush_ponji/features/words/data/datasources/local/words_local_datasource.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/core/services/background_task_dispatcher.dart';

class AppInitializer {

  // ── Public Entry Point ────────────────────────────────────────────────────

  static Future<void> initialize() async {
    try {
      await _setDeviceOrientation();
      await _initializeFirebase();
      await _initializeHive();
      await _registerHiveAdapters();
      await _openHiveBoxes();
      await _initializeSharedPreferences();
      await _initializeNotifications();
      await _registerBootTask();
      await _performInitialSync();

      debugPrint('✅ App initialization completed successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ App initialization failed: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  // ── Steps ─────────────────────────────────────────────────────────────────

  static Future<void> _setDeviceOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    debugPrint('✅ Device orientation set to portrait');
  }

  /// Firebase must be initialized before any Firestore/Auth access.
  /// Called without FirebaseOptions — reads from google-services.json directly.
  static Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      debugPrint('✅ Firebase initialized');
    } catch (e) {
      debugPrint('❌ Firebase initialization failed: $e');
      rethrow; // Fatal — Firestore won't work without this
    }
  }

  static Future<void> _initializeHive() async {
    await Hive.initFlutter();
    debugPrint('✅ Hive initialized');
  }

  static Future<void> _registerHiveAdapters() async {
    try {
      Hive.registerAdapter(HolidayAdapter());
      Hive.registerAdapter(HolidayTypeAdapter());
      Hive.registerAdapter(QuoteModelAdapter());
      Hive.registerAdapter(WordModelAdapter());
      debugPrint('✅ Hive adapters registered');
    } catch (e) {
      debugPrint('❌ Failed to register Hive adapters: $e');
      rethrow;
    }
  }

  static Future<void> _openHiveBoxes() async {
    try {
      await Hive.openBox('settings');
      await Hive.openBox('holidays');
      await Hive.openBox<QuoteModel>(savedQuotesBoxName);
      await Hive.openBox<WordModel>(savedWordsBoxName);
      debugPrint('✅ Hive boxes opened');
    } catch (e) {
      debugPrint('❌ Failed to open Hive boxes: $e');
      rethrow;
    }
  }

  static Future<void> _initializeSharedPreferences() async {
    try {
      await SharedPreferences.getInstance();
      debugPrint('✅ SharedPreferences initialized');
    } catch (e) {
      debugPrint('⚠️ SharedPreferences init warning: $e');
    }
  }

  static Future<void> _initializeNotifications() async {
    try {
      await LocalNotificationService.initialize();
      debugPrint('✅ Notification service initialized');
    } catch (e) {
      debugPrint('⚠️ Notification service init warning: $e');
    }
  }

  /// Registers a one-off WorkManager task that fires after device reboot.
  /// WorkManager persists this across reboots automatically — when Android
  /// restarts it runs [callbackDispatcher] in a background isolate to
  /// restore prayer alarms without the user needing to open the app.
  static Future<void> _registerBootTask() async {
    try {
      await Workmanager().registerOneOffTask(
        kReschedulePrayerTask,
        kReschedulePrayerTask,
        initialDelay: const Duration(seconds: 30),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        constraints: Constraints(
          networkType: NetworkType.notRequired,
        ),
      );
      debugPrint('✅ Boot reschedule task registered');
    } catch (e) {
      debugPrint('⚠️ Boot task registration warning: $e');
    }
  }

  static Future<void> _performInitialSync() async {
    try {
      debugPrint('🔄 Starting initial holiday sync...');
      final syncService = SyncService();
      final success = await syncService.syncHolidays();
      if (success) {
        debugPrint('✅ Initial holiday sync completed');
      } else {
        debugPrint('⚠️ Holiday sync failed — app will use cached data');
      }
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

    final colorScheme =
        isDark ? AppTheme.darkTheme.colorScheme : AppTheme.lightTheme.colorScheme;

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