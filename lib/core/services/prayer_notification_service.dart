// lib/features/prayer_times/services/prayer_notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/features/prayer_times/models/prayer_times_model.dart';

class PrayerNotificationService {
  // Notification ID offsets per prayer (spread across 100s to avoid collisions)
  static const Map<Prayer, int> _notificationIds = {
    Prayer.fajr:    100,
    Prayer.dhuhr:   101,
    Prayer.asr:     102,
    Prayer.maghrib: 103,
    Prayer.isha:    104,
  };

  // ── Initialization ─────────────────────────────────────

  static Future<void> initialize() async {
    await LocalNotificationService.initialize();
  }

  // ── Permission ─────────────────────────────────────────

  static Future<bool> requestPermission() async {
    return LocalNotificationService.ensurePermission();
  }

  // ── Schedule ───────────────────────────────────────────

  /// Cancel all existing prayer notifications then schedule new ones
  /// for [today] and optionally [tomorrow].
  static Future<void> scheduleAll({
    required PrayerTimesModel today,
    PrayerTimesModel? tomorrow,
    required PrayerNotificationPrefs prefs,
    required String languageCode,
  }) async {
    await initialize();
    if (!prefs.masterEnabled) return;

    final ok = await LocalNotificationService.ensurePermission();
    if (!ok) return;

    await cancelAll();

    final now = DateTime.now();

    // Schedule today's remaining prayers
    for (final prayer in Prayer.values) {
      if (!prayer.isNotifiable) continue;
      if (!prefs.isEnabledFor(prayer)) continue;

      final time = today.timeFor(prayer);
      final scheduledTime =
          time.subtract(Duration(minutes: prefs.offsetMinutes));

      if (scheduledTime.isAfter(now)) {
        await _scheduleOne(
          prayer: prayer,
          scheduledTime: scheduledTime,
          locationDisplay: today.locationDisplay,
          languageCode: languageCode,
          idOffset: 0,
        );
      }
    }

    // Schedule tomorrow's prayers so user wakes up to Fajr notification
    if (tomorrow != null) {
      for (final prayer in Prayer.values) {
        if (!prayer.isNotifiable) continue;
        if (!prefs.isEnabledFor(prayer)) continue;

        final time = tomorrow.timeFor(prayer);
        final scheduledTime =
            time.subtract(Duration(minutes: prefs.offsetMinutes));

        await _scheduleOne(
          prayer: prayer,
          scheduledTime: scheduledTime,
          locationDisplay: tomorrow.locationDisplay,
          languageCode: languageCode,
          idOffset: 10, // tomorrow uses IDs 110–114
        );
      }
    }
  }

  // ── Cancel ─────────────────────────────────────────────

  static Future<void> cancelAll() async {
    await initialize();
    await LocalNotificationService.cancelAll();
  }

  static Future<void> cancelForPrayer(Prayer prayer) async {
    await initialize();
    final id = _notificationIds[prayer];
    if (id != null) {
      await LocalNotificationService.cancel(id);
      await LocalNotificationService.cancel(id + 10); // tomorrow's slot
    }
  }

  // ── Internal ───────────────────────────────────────────

  static Future<void> _scheduleOne({
    required Prayer prayer,
    required DateTime scheduledTime,
    required String locationDisplay,
    required String languageCode,
    required int idOffset,
  }) async {
    final id = _notificationIds[prayer]! + idOffset;
    final name = prayer.nameForLocale(languageCode);

    final title = languageCode == 'bn'
        ? '$name-এর সময় হয়েছে'
        : 'Time for $name';

    final body = languageCode == 'bn'
        ? '$locationDisplay — $name'
        : '$name • $locationDisplay';

    await LocalNotificationService.scheduleZoned(
      id: id,
      scheduledTime: scheduledTime,
      title: title,
      body: body,
      details: NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_times_channel',
          'Prayer Times',
          channelDescription: 'Notifications for daily prayer times',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}

final prayerNotificationServiceProvider =
    Provider<PrayerNotificationService>((ref) {
  return PrayerNotificationService();
});