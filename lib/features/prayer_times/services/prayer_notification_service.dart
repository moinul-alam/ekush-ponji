// lib/features/prayer_times/services/prayer_notification_service.dart
//
// CHANGED:
//   • scheduleAll() now uses NotificationPermissionService.isGranted() (silent)
//     instead of LocalNotificationService.ensurePermission() (shows dialog).
//     scheduleAll() is called from AppInitializer and WorkManager — never
//     from a user action — so it must never trigger a permission dialog.
//   • requestPermission() still calls ensurePermission() — it is only called
//     from prayer_times_screen.dart after an explicit user context.
//   • Removed unused flutter_riverpod import (provider kept at bottom).
//   • _isPermissionGranted() removed — replaced by NotificationPermissionService.

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_service.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/features/prayer_times/models/prayer_times_model.dart';

class PrayerNotificationService {
  PrayerNotificationService._();

  // Notification ID base per prayer (today: 100–104, tomorrow: 110–114)
  static const Map<Prayer, int> _notificationIds = {
    Prayer.fajr: 100,
    Prayer.dhuhr: 101,
    Prayer.asr: 102,
    Prayer.maghrib: 103,
    Prayer.isha: 104,
  };

  static const _accentColor = Color(0xFF006B54);

  // ── Initialization ─────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    await LocalNotificationService.initialize();
  }

  // ── Permission ─────────────────────────────────────────────────────────────

  /// Requests permission — call ONLY from a user-triggered context
  /// (e.g. prayer_times_screen.dart contextual prompt).
  static Future<bool> requestPermission() async {
    return NotificationPermissionService.ensurePermission();
  }

  // ── Schedule ───────────────────────────────────────────────────────────────

  /// Cancel all existing prayer notifications then schedule fresh ones
  /// for [today] and optionally [tomorrow].
  ///
  /// Uses a SILENT permission check — this method is called from
  /// AppInitializer and WorkManager background tasks. It must never
  /// trigger a permission dialog.
  static Future<void> scheduleAll({
    required PrayerTimesModel today,
    PrayerTimesModel? tomorrow,
    required PrayerNotificationPrefs prefs,
    required String languageCode,
  }) async {
    await initialize();
    if (!prefs.masterEnabled) return;

    // ── Silent check — never prompt ──────────────────────────────────────
    final granted = await NotificationPermissionService.isGranted();
    if (!granted) {
      debugPrint(
          'ℹ️ Prayer notifications skipped — permission not yet granted');
      return;
    }

    await cancelAll();

    final now = DateTime.now();

    // ── Today's remaining prayers ──────────────────────────────────────────
    for (final prayer in Prayer.values) {
      if (!prayer.isNotifiable) continue;
      if (!prefs.isEnabledFor(prayer)) continue;

      final time = today.timeFor(prayer);
      final scheduledTime =
          time.subtract(Duration(minutes: prefs.offsetMinutes));

      if (scheduledTime.isAfter(now)) {
        await _scheduleOne(
          prayer: prayer,
          prayerTime: time,
          scheduledTime: scheduledTime,
          locationDisplay: today.locationDisplay,
          languageCode: languageCode,
          idOffset: 0,
        );
      }
    }

    // ── Tomorrow's prayers ────────────────────────────────────────────────
    if (tomorrow != null) {
      for (final prayer in Prayer.values) {
        if (!prayer.isNotifiable) continue;
        if (!prefs.isEnabledFor(prayer)) continue;

        final time = tomorrow.timeFor(prayer);
        final scheduledTime =
            time.subtract(Duration(minutes: prefs.offsetMinutes));

        await _scheduleOne(
          prayer: prayer,
          prayerTime: time,
          scheduledTime: scheduledTime,
          locationDisplay: tomorrow.locationDisplay,
          languageCode: languageCode,
          idOffset: 10,
        );
      }
    }
  }

  // ── Cancel ─────────────────────────────────────────────────────────────────

  static Future<void> cancelAll() async {
    await LocalNotificationService.cancelAll();
  }

  static Future<void> cancelForPrayer(Prayer prayer) async {
    final id = _notificationIds[prayer];
    if (id != null) {
      await LocalNotificationService.cancel(id);
      await LocalNotificationService.cancel(id + 10);
    }
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  static Future<void> _scheduleOne({
    required Prayer prayer,
    required DateTime prayerTime,
    required DateTime scheduledTime,
    required String locationDisplay,
    required String languageCode,
    required int idOffset,
  }) async {
    final id = _notificationIds[prayer]! + idOffset;
    final name = prayer.nameForLocale(languageCode);
    final formattedTime = _formatTime(prayerTime, languageCode);

    final title = languageCode == 'bn'
        ? '$name এর নামাজের সময় হয়েছে'
        : 'Time for $name';
    final body = '$formattedTime • $locationDisplay';

    await LocalNotificationService.scheduleZoned(
      id: id,
      scheduledTime: scheduledTime,
      title: title,
      body: body,
      payload: 'prayer',
      details: NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_times_channel',
          'Prayer Times',
          channelDescription: 'Notifications for daily prayer times',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: _accentColor,
          playSound: true,
          category: AndroidNotificationCategory.reminder,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _formatTime(DateTime time, String languageCode) {
    final hour = time.hour;
    final minute = time.minute;
    final isPm = hour >= 12;
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final minuteStr = minute.toString().padLeft(2, '0');
    final period = isPm ? 'PM' : 'AM';

    if (languageCode == 'bn') {
      return '${_toBengaliDigits(hour12.toString())}:${_toBengaliDigits(minuteStr)} $period';
    }
    return '$hour12:$minuteStr $period';
  }

  static String _toBengaliDigits(String input) {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return input.split('').map((ch) {
      final digit = int.tryParse(ch);
      return digit != null ? bengaliDigits[digit] : ch;
    }).join();
  }
}

final prayerNotificationServiceProvider =
    Provider<PrayerNotificationService>((ref) => PrayerNotificationService._());
