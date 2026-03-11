// lib/app/config/app_initializer.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ekush_ponji/core/themes/app_theme.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/core/services/holiday_sync_service.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';
import 'package:ekush_ponji/features/words/models/word.dart';
import 'package:ekush_ponji/features/quotes/data/datasources/local/quotes_local_datasource.dart';
import 'package:ekush_ponji/features/words/data/datasources/local/words_local_datasource.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/core/services/background_task_dispatcher.dart';
import 'package:workmanager/workmanager.dart';

class AppInitializer {

  // ── Phase 1: Critical path ────────────────────────────────────────────────
  static Future<void> initializeCore() async {
    try {
      await Future.wait([
        _setDeviceOrientation(),
        _initializeHiveAndSettings(),
      ]);
      debugPrint('✅ Core initialization completed');
    } catch (e, stackTrace) {
      debugPrint('❌ Core initialization failed: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  // ── Phase 2: Background ───────────────────────────────────────────────────
  static Future<void> initializeBackground() async {
    try {
      await Future.wait([
        _openSecondaryHiveBoxes(),
        _initializeFirebase(),
        _initializeSharedPreferences(),
        _initializeWorkManager(),
      ]);

      await Future.wait([
        _initializeNotifications(),
        _performHolidaySyncWithTimeout(),
      ]);

      debugPrint('✅ Background initialization completed');
    } catch (e, stackTrace) {
      debugPrint('❌ Background initialization error: $e');
      debugPrint('StackTrace: $stackTrace');
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

  // ── Phase 2 Steps ─────────────────────────────────────────────────────────

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

  /// Seeds bundled assets on first launch, then checks GitHub for updates.
  /// Hard 8-second timeout — app proceeds normally if slow/offline.
  static Future<void> _performHolidaySyncWithTimeout() async {
    try {
      debugPrint('🌱 Starting holiday seed + sync...');
      final service = HolidaySyncService();
      await service.initialize().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          debugPrint('⏱️ Holiday sync timed out — using cached/bundled data');
        },
      );
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
      statusBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
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