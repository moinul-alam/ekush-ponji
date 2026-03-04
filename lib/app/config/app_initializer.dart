// lib/app/config/app_initializer.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekush_ponji/core/themes/app_theme.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/core/services/sync_service.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';
import 'package:ekush_ponji/features/words/models/word.dart';
import 'package:ekush_ponji/features/quotes/data/datasources/local/quotes_local_datasource.dart';
import 'package:ekush_ponji/features/words/data/datasources/local/words_local_datasource.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';

class AppInitializer {

  // ── Public Entry Point ────────────────────────────────────────────────────

  /// Runs all startup initialization in the correct order.
  /// Called once from main() before runApp().
  static Future<void> initialize() async {
    try {
      await _setDeviceOrientation();
      await _initializeHive();
      await _registerHiveAdapters();
      await _openHiveBoxes();
      await _initializeSharedPreferences();
      await _initializeNotifications();
      await _performInitialSync();

      debugPrint('✅ App initialization completed successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ App initialization failed: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  // ── Steps ─────────────────────────────────────────────────────────────────

  /// Lock device orientation to portrait only
  static Future<void> _setDeviceOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    debugPrint('✅ Device orientation set to portrait');
  }

  /// Initialize Hive local storage
  static Future<void> _initializeHive() async {
    await Hive.initFlutter();
    debugPrint('✅ Hive initialized');
  }

  /// Register Hive type adapters
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

  /// Open all required Hive boxes
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

  /// Initialize SharedPreferences
  /// Called early so it's warmed up and available synchronously later
  static Future<void> _initializeSharedPreferences() async {
    try {
      await SharedPreferences.getInstance();
      debugPrint('✅ SharedPreferences initialized');
    } catch (e) {
      // Non-fatal — SharedPreferences will re-initialize on first use
      debugPrint('⚠️ SharedPreferences init warning: $e');
    }
  }

  /// Initialize notification service — timezone + plugin setup.
  /// Must run after Hive (settings box) is open, before any feature
  /// that schedules notifications (prayer times, reminders, events).
  static Future<void> _initializeNotifications() async {
    try {
      await LocalNotificationService.initialize();
      debugPrint('✅ Notification service initialized');
    } catch (e) {
      // Non-fatal — app works without notifications
      debugPrint('⚠️ Notification service init warning: $e');
    }
  }

  /// Perform initial holiday sync from Firebase
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
      // Non-fatal — cached data will be used
      debugPrint('⚠️ Holiday sync error: $e');
    }
  }

  // ── System UI ─────────────────────────────────────────────────────────────

  /// Update system UI overlay style (status bar, nav bar) to match
  /// the current theme. Call this on first build and on theme changes.
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

  /// Close all Hive boxes. Call from app lifecycle dispose if needed.
  static Future<void> dispose() async {
    try {
      await Hive.close();
      debugPrint('✅ Hive boxes closed');
    } catch (e) {
      debugPrint('❌ Failed to close Hive boxes: $e');
    }
  }
}