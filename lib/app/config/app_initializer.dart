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

class AppInitializer {
  /// Initialize app services
  static Future<void> initialize() async {
    try {
      await _setDeviceOrientation();
      await _initializeHive();
      await _registerHiveAdapters();
      await _openHiveBoxes();
      await _initializeSharedPreferences();
      await _performInitialSync();

      debugPrint('✅ App initialization completed successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ App initialization failed: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

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
    debugPrint('✅ Hive initialized successfully');
  }

  /// Register Hive type adapters
  static Future<void> _registerHiveAdapters() async {
    try {
      Hive.registerAdapter(HolidayAdapter());
      Hive.registerAdapter(HolidayTypeAdapter());
      Hive.registerAdapter(QuoteModelAdapter());
      Hive.registerAdapter(WordModelAdapter());
      debugPrint('✅ Hive adapters registered successfully');
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
      debugPrint('✅ All Hive boxes opened successfully');
    } catch (e) {
      debugPrint('❌ Failed to open Hive boxes: $e');
      rethrow;
    }
  }

  /// Initialize SharedPreferences for locale storage
  static Future<void> _initializeSharedPreferences() async {
    try {
      await SharedPreferences.getInstance();
      debugPrint('✅ SharedPreferences initialized');
    } catch (e) {
      debugPrint('❌ Error initializing SharedPreferences: $e');
    }
  }

  /// Perform initial holiday sync from Firebase
  static Future<void> _performInitialSync() async {
    try {
      debugPrint('🔄 Starting initial holiday sync...');

      final syncService = SyncService();
      final success = await syncService.syncHolidays();

      if (success) {
        debugPrint('✅ Initial holiday sync completed successfully');
      } else {
        debugPrint('⚠️ Initial holiday sync failed (app will use cached data)');
      }
    } catch (e) {
      debugPrint('⚠️ Error during initial sync: $e (app will continue)');
    }
  }

  /// Update system UI based on current ThemeMode and platform brightness
  static void updateSystemUIFromTheme(
      BuildContext context, ThemeMode themeMode) {
    final platformBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            platformBrightness == Brightness.dark);
    final colorScheme = isDarkMode
        ? AppTheme.darkTheme.colorScheme
        : AppTheme.lightTheme.colorScheme;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: colorScheme.surface,
      systemNavigationBarIconBrightness:
          isDarkMode ? Brightness.light : Brightness.dark,
    ));
  }

  /// Close all Hive boxes and cleanup
  static Future<void> dispose() async {
    try {
      await Hive.close();
      debugPrint('✅ Hive boxes closed successfully');
    } catch (e) {
      debugPrint('❌ Failed to close Hive boxes: $e');
    }
  }
}