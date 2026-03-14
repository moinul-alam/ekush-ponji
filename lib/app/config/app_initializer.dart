// lib/app/config/app_initializer.dart
//
// CHANGED: Added _initializeMobileAds() to initializeBackground()

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
import 'package:workmanager/workmanager.dart';

class AppInitializer {
  // ── Phase 1: Critical path ─────────────────────────────────
  /// Everything here must complete BEFORE runApp().
  /// Hive boxes are cheap local disk ops (~1-2ms each) — open them
  /// all here so viewmodels can safely call Hive.box() on first frame.
  static Future<void> initializeCore() async {
    try {
      await Future.wait([
        _setDeviceOrientation(),
        _initializeHiveAndSettings(),
      ]);

      // ✅ Open ALL Hive boxes before runApp.
      // viewmodels call Hive.box('saved_quotes') etc. the moment the
      // home screen renders — those boxes must already be open.
      await _openSecondaryHiveBoxes();

      debugPrint('✅ Core initialization completed');
    } catch (e, stackTrace) {
      debugPrint('❌ Core initialization failed: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  // ── Phase 2: Background ────────────────────────────────────
  /// Heavy work (Firebase, network, WorkManager) runs behind the
  /// custom splash screen. [container] is passed in so we reuse the
  /// singleton DataSyncService from the provider graph.
  static Future<void> initializeBackground(ProviderContainer container) async {
    try {
      await Future.wait([
        _initializeFirebase(),
        _initializeSharedPreferences(),
        _initializeWorkManager(),
        _initializeMobileAds(), // ← ADDED: must run before AdService loads ads
      ]);

      await Future.wait([
        _initializeNotifications(),
        _performDataSyncWithTimeout(container),
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

  /// ✅ MOVED FROM Phase 2 → Phase 1.
  /// Opening boxes is a fast local op. Must be done before runApp()
  /// so that QuotesViewModel.onInit() and WordsViewModel.onInit()
  /// can safely call Hive.box('saved_quotes') / Hive.box('saved_words').
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
      // Non-fatal — app can still function with degraded state
    }
  }

  // ── Phase 2 Steps ──────────────────────────────────────────

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

  // ── ADDED ──────────────────────────────────────────────────
  /// Initializes the Google Mobile Ads SDK.
  /// Must complete before AdService attempts to load any ads.
  /// Non-fatal — app works normally if this fails.
  static Future<void> _initializeMobileAds() async {
    try {
      await MobileAds.instance.initialize();
      debugPrint('✅ MobileAds initialized');
    } catch (e) {
      debugPrint('⚠️ MobileAds initialization warning: $e');
    }
  }

  /// Seeds all bundled assets on first launch, then checks for updates.
  /// Hard 8-second timeout — app proceeds normally if slow/offline.
  ///
  /// After seeding completes, viewmodels are reloaded so they pick up
  /// the freshly written Hive data (quotes_en_json / words_en_json).
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

      // ✅ Reload viewmodels after seed/sync completes.
      // On first launch: seed() just wrote quotes_en_json to Hive,
      // so reload picks up that data instead of the rootBundle fallback.
      // On subsequent launches: picks up any newly synced remote data.
      container.read(quotesViewModelProvider.notifier).loadQuotes();
      container.read(wordsViewModelProvider.notifier).loadWords();

      debugPrint('✅ Quotes + Words viewmodels reloaded after sync');
    } catch (e) {
      debugPrint('⚠️ Data sync error: $e');
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
