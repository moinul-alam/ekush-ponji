// lib/core/services/background_task_dispatcher.dart
//
// This file contains the top-level callbackDispatcher function required by
// workmanager. It MUST be a top-level function (not inside a class) and MUST
// be annotated with @pragma('vm:entry-point') so it survives AOT compilation
// in release builds.
//
// All background tasks for the app are handled here via task name constants.

import 'dart:convert';

import 'package:adhan/adhan.dart' hide Prayer;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/features/prayer_times/services/prayer_notification_service.dart';
import 'package:ekush_ponji/features/prayer_times/models/prayer_times_model.dart';

// ── Task name constants ────────────────────────────────────────────────────────
// Keep these as constants so they're referenced consistently across the app

/// Task that re-schedules prayer notifications after device reboot
const String kReschedulePrayerTask = 'reschedule_prayer_notifications';

// ── SharedPreferences keys ────────────────────────────────────────────────────
// Must match prayer_times_viewmodel.dart and prayer_settings_viewmodel.dart

const String _cachedLatKey = 'prayer_cached_lat';
const String _cachedLngKey = 'prayer_cached_lng';
const String _cachedLocationDisplayKey = 'prayer_cached_location_display';
const String _calcSettingsKey = 'prayer_calculation_settings';
const String _notifPrefsKey = 'prayer_notification_prefs';
const String _languageCodeKey = 'languageCode';

/// Top-level callback dispatcher — entry point for all workmanager background tasks.
///
/// Android calls this function in a background isolate when a registered task
/// is due to run. The widget tree and Riverpod do NOT exist here.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint('🔄 Background task started: $taskName');

    try {
      switch (taskName) {
        case kReschedulePrayerTask:
          await _reschedulePrayerNotifications();
          break;
        default:
          debugPrint('⚠️ Unknown background task: $taskName');
      }

      debugPrint('✅ Background task completed: $taskName');
      return true;
    } catch (e) {
      debugPrint('❌ Background task failed: $taskName — $e');
      // Return false so WorkManager retries the task
      return false;
    }
  });
}

// ── Task implementations ──────────────────────────────────────────────────────

/// Re-schedules prayer notifications from locally cached data.
///
/// No network calls — uses only SharedPreferences + adhan math.
/// Called after device reboot to restore alarms wiped by Android.
Future<void> _reschedulePrayerNotifications() async {
  final prefs = await SharedPreferences.getInstance();

  final lat = prefs.getDouble(_cachedLatKey);
  final lng = prefs.getDouble(_cachedLngKey);
  final locationDisplay = prefs.getString(_cachedLocationDisplayKey);

  if (lat == null || lng == null || locationDisplay == null) {
    debugPrint('ℹ️ Reschedule: no cached location — skipping');
    return;
  }

  // Load notification prefs — respect master switch
  PrayerNotificationPrefs notifPrefs = const PrayerNotificationPrefs();
  final notifJson = prefs.getString(_notifPrefsKey);
  if (notifJson != null) {
    try {
      notifPrefs = PrayerNotificationPrefs.fromJson(
        jsonDecode(notifJson) as Map<String, dynamic>,
      );
    } catch (_) {}
  }

  if (!notifPrefs.masterEnabled) {
    debugPrint('ℹ️ Reschedule: notifications disabled — skipping');
    return;
  }

  // Load calculation settings
  PrayerCalculationSettings calcSettings = const PrayerCalculationSettings();
  final calcJson = prefs.getString(_calcSettingsKey);
  if (calcJson != null) {
    try {
      calcSettings = PrayerCalculationSettings.fromJson(
        jsonDecode(calcJson) as Map<String, dynamic>,
      );
    } catch (_) {}
  }

  final languageCode = prefs.getString(_languageCodeKey) ?? 'bn';

  // Calculate prayer times — pure math, no network
  final coords = Coordinates(lat, lng);
  final params = calcSettings.adhanParams;
  final today = DateTime.now();
  final tomorrow = today.add(const Duration(days: 1));

  final todayModel = PrayerTimesModel.fromAdhan(
    times: PrayerTimes(
      coords,
      DateComponents(today.year, today.month, today.day),
      params,
    ),
    latitude: lat,
    longitude: lng,
    locationDisplay: locationDisplay,
    tomorrowFajr: PrayerTimes(
      coords,
      DateComponents(tomorrow.year, tomorrow.month, tomorrow.day),
      params,
    ).fajr,
  );

  final tomorrowModel = PrayerTimesModel.fromAdhan(
    times: PrayerTimes(
      coords,
      DateComponents(tomorrow.year, tomorrow.month, tomorrow.day),
      params,
    ),
    latitude: lat,
    longitude: lng,
    locationDisplay: locationDisplay,
  );

  // Init notification service (timezone + plugin) then reschedule
  await LocalNotificationService.initialize();
  await PrayerNotificationService.scheduleAll(
    today: todayModel,
    tomorrow: tomorrowModel,
    prefs: notifPrefs,
    languageCode: languageCode,
  );

  debugPrint('✅ Prayer notifications rescheduled from background');
}
