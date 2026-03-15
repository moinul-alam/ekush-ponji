// lib/core/services/background_task_dispatcher.dart
//
// CHANGED:
//   • Removed separate quote_notification_prefs.dart and
//     word_notification_prefs.dart imports — prefs classes are accessed
//     through their service files only, preventing duplicate name errors.
//   • Fixed QuotesLocalDatasource() and WordsLocalDatasource() constructors
//     — they require savedBox and settingsBox, opened here via Hive.

import 'dart:convert';

import 'package:adhan/adhan.dart' hide Prayer;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/features/prayer_times/services/prayer_notification_service.dart';
import 'package:ekush_ponji/features/prayer_times/models/prayer_times_model.dart';
import 'package:ekush_ponji/features/quotes/services/quote_notification_service.dart';
import 'package:ekush_ponji/features/quotes/data/datasources/local/quotes_local_datasource.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';
import 'package:ekush_ponji/features/words/services/word_notification_service.dart';
import 'package:ekush_ponji/features/words/data/datasources/local/words_local_datasource.dart';
import 'package:ekush_ponji/features/words/models/word.dart';

// ── Task name constants ────────────────────────────────────────────────────────

const String kReschedulePrayerTask = 'reschedule_prayer_notifications';
const String kRescheduleQuoteTask = 'reschedule_quote_notifications';
const String kRescheduleWordTask = 'reschedule_word_notifications';

// ── SharedPreferences keys ────────────────────────────────────────────────────

const String _cachedLatKey = 'prayer_cached_lat';
const String _cachedLngKey = 'prayer_cached_lng';
const String _cachedLocationDisplayKey = 'prayer_cached_location_display';
const String _calcSettingsKey = 'prayer_calculation_settings';
const String _notifPrefsKey = 'prayer_notification_prefs';
const String _languageCodeKey = 'languageCode';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint('🔄 Background task started: $taskName');

    try {
      switch (taskName) {
        case kReschedulePrayerTask:
          await _reschedulePrayerNotifications();
          break;
        case kRescheduleQuoteTask:
          await _rescheduleQuoteNotifications();
          break;
        case kRescheduleWordTask:
          await _rescheduleWordNotifications();
          break;
        default:
          debugPrint('⚠️ Unknown background task: $taskName');
      }

      debugPrint('✅ Background task completed: $taskName');
      return true;
    } catch (e) {
      debugPrint('❌ Background task failed: $taskName — $e');
      return false;
    }
  });
}

// ── Prayer reschedule ─────────────────────────────────────────────────────────

Future<void> _reschedulePrayerNotifications() async {
  final prefs = await SharedPreferences.getInstance();

  final lat = prefs.getDouble(_cachedLatKey);
  final lng = prefs.getDouble(_cachedLngKey);
  final locationDisplay = prefs.getString(_cachedLocationDisplayKey);

  if (lat == null || lng == null || locationDisplay == null) {
    debugPrint('ℹ️ Prayer reschedule: no cached location — skipping');
    return;
  }

  PrayerNotificationPrefs notifPrefs = const PrayerNotificationPrefs();
  final notifJson = prefs.getString(_notifPrefsKey);
  if (notifJson != null) {
    try {
      notifPrefs = PrayerNotificationPrefs.fromJson(
          jsonDecode(notifJson) as Map<String, dynamic>);
    } catch (_) {}
  }

  if (!notifPrefs.masterEnabled) {
    debugPrint('ℹ️ Prayer reschedule: master switch off — skipping');
    return;
  }

  PrayerCalculationSettings calcSettings = const PrayerCalculationSettings();
  final calcJson = prefs.getString(_calcSettingsKey);
  if (calcJson != null) {
    try {
      calcSettings = PrayerCalculationSettings.fromJson(
          jsonDecode(calcJson) as Map<String, dynamic>);
    } catch (_) {}
  }

  final languageCode = prefs.getString(_languageCodeKey) ?? 'bn';
  final coords = Coordinates(lat, lng);
  final params = calcSettings.adhanParams;
  final today = DateTime.now();
  final tomorrow = today.add(const Duration(days: 1));

  final todayModel = PrayerTimesModel.fromAdhan(
    times: PrayerTimes(
        coords, DateComponents(today.year, today.month, today.day), params),
    latitude: lat,
    longitude: lng,
    locationDisplay: locationDisplay,
    tomorrowFajr: PrayerTimes(coords,
            DateComponents(tomorrow.year, tomorrow.month, tomorrow.day), params)
        .fajr,
  );

  final tomorrowModel = PrayerTimesModel.fromAdhan(
    times: PrayerTimes(coords,
        DateComponents(tomorrow.year, tomorrow.month, tomorrow.day), params),
    latitude: lat,
    longitude: lng,
    locationDisplay: locationDisplay,
  );

  await LocalNotificationService.initialize();
  await PrayerNotificationService.scheduleAll(
    today: todayModel,
    tomorrow: tomorrowModel,
    prefs: notifPrefs,
    languageCode: languageCode,
  );

  debugPrint('✅ Prayer notifications rescheduled from background');
}

// ── Quote reschedule ──────────────────────────────────────────────────────────

Future<void> _rescheduleQuoteNotifications() async {
  // QuoteNotificationPrefs accessed via quote_notification_service.dart import
  final prefs = await QuoteNotificationPrefs.load();

  if (!prefs.enabled) {
    debugPrint('ℹ️ Quote reschedule: disabled — skipping');
    return;
  }

  final sp = await SharedPreferences.getInstance();
  final languageCode = sp.getString(_languageCodeKey) ?? 'bn';

  // Hive must be initialised in background isolate before opening boxes.
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(QuoteModelAdapter());
  }

  final savedBox = await Hive.openBox<QuoteModel>(savedQuotesBoxName);
  final settingsBox = await Hive.openBox('settings');

  final datasource = QuotesLocalDatasource(
    savedBox: savedBox,
    settingsBox: settingsBox,
  );
  await datasource.init();

  await QuoteNotificationService.scheduleUpcoming(
    datasource: datasource,
    prefs: prefs,
    languageCode: languageCode,
  );

  debugPrint('✅ Quote notifications rescheduled from background');
}

// ── Word reschedule ───────────────────────────────────────────────────────────

Future<void> _rescheduleWordNotifications() async {
  // WordNotificationPrefs accessed via word_notification_service.dart import
  final prefs = await WordNotificationPrefs.load();

  if (!prefs.enabled) {
    debugPrint('ℹ️ Word reschedule: disabled — skipping');
    return;
  }

  final sp = await SharedPreferences.getInstance();
  final languageCode = sp.getString(_languageCodeKey) ?? 'bn';

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(11)) {
    Hive.registerAdapter(WordModelAdapter());
  }

  final savedBox = await Hive.openBox<WordModel>(savedWordsBoxName);
  final settingsBox = await Hive.openBox('settings');

  final datasource = WordsLocalDatasource(
    savedBox: savedBox,
    settingsBox: settingsBox,
  );
  await datasource.init();

  await WordNotificationService.scheduleUpcoming(
    datasource: datasource,
    prefs: prefs,
    languageCode: languageCode,
  );

  debugPrint('✅ Word notifications rescheduled from background');
}
