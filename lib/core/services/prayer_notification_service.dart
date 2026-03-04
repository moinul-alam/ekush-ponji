// lib/core/services/prayer_notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/features/prayer_times/models/prayer_times_model.dart';

class PrayerNotificationService {
  // Notification ID base per prayer (today: 100–104, tomorrow: 110–114)
  static const Map<Prayer, int> _notificationIds = {
    Prayer.fajr:    100,
    Prayer.dhuhr:   101,
    Prayer.asr:     102,
    Prayer.maghrib: 103,
    Prayer.isha:    104,
  };

  // App primary green — used to tint the notification icon on Android
  static const _accentColor = Color(0xFF006B54);

  // ── Initialization ─────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    await LocalNotificationService.initialize();
  }

  // ── Permission ─────────────────────────────────────────────────────────────

  static Future<bool> requestPermission() async {
    return LocalNotificationService.ensurePermission();
  }

  // ── Schedule ───────────────────────────────────────────────────────────────

  /// Cancel all existing prayer notifications then schedule fresh ones
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
    // Scheduled so the user gets Fajr alert even if they don't open the app.
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
          idOffset: 10, // tomorrow uses IDs 110–114
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
      await LocalNotificationService.cancel(id + 10); // tomorrow's slot
    }
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  static Future<void> _scheduleOne({
    required Prayer prayer,
    required DateTime prayerTime,   // actual prayer time (for display in body)
    required DateTime scheduledTime, // when to fire (may be offset earlier)
    required String locationDisplay,
    required String languageCode,
    required int idOffset,
  }) async {
    final id = _notificationIds[prayer]! + idOffset;
    final name = prayer.nameForLocale(languageCode);
    final formattedTime = _formatTime(prayerTime, languageCode);

    // ── Notification text ──────────────────────────────────────────────────
    //
    // Bengali example:
    //   Title: ফজরের সময় হয়েছে
    //   Body:  ৫:১২ AM • ঢাকা, বাংলাদেশ
    //
    // English example:
    //   Title: Time for Fajr
    //   Body:  5:12 AM • Dhaka, Bangladesh
    //
    final title = languageCode == 'bn'
        ? '${name}ের সময় হয়েছে'
        : 'Time for $name';

    final body = languageCode == 'bn'
        ? '$formattedTime • $locationDisplay'
        : '$formattedTime • $locationDisplay';

    await LocalNotificationService.scheduleZoned(
      id: id,
      scheduledTime: scheduledTime,
      title: title,
      body: body,
      payload: 'prayer', // tapping opens Prayer Times screen
      details: NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_times_channel',
          'Prayer Times',
          channelDescription: 'Notifications for daily prayer times',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          // Tints the small notification icon with the app's primary green
          color: _accentColor,
          playSound: true,
          // Category hint tells Android this is a time-sensitive alert,
          // which can bypass Do Not Disturb on some devices
          category: AndroidNotificationCategory.reminder,
          // Show the full body text in the expanded notification drawer
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

  /// Formats a [DateTime] as a time string in the given locale.
  ///
  /// Bengali (languageCode == 'bn'): converts digits to Bengali numerals.
  ///   e.g. 5:07 AM → ৫:০৭ AM
  ///
  /// English: standard 12-hour format.
  ///   e.g. 5:07 AM
  static String _formatTime(DateTime time, String languageCode) {
    final hour = time.hour;
    final minute = time.minute;
    final isPm = hour >= 12;
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final minuteStr = minute.toString().padLeft(2, '0');
    final period = isPm ? 'PM' : 'AM';

    if (languageCode == 'bn') {
      final bnHour = _toBengaliDigits(hour12.toString());
      final bnMinute = _toBengaliDigits(minuteStr);
      return '$bnHour:$bnMinute $period';
    }

    return '$hour12:$minuteStr $period';
  }

  /// Converts ASCII digit characters to Bengali numeral characters.
  /// e.g. '507' → '৫০৭'
  static String _toBengaliDigits(String input) {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return input.split('').map((ch) {
      final digit = int.tryParse(ch);
      return digit != null ? bengaliDigits[digit] : ch;
    }).join();
  }
}

final prayerNotificationServiceProvider =
    Provider<PrayerNotificationService>((ref) {
  return PrayerNotificationService();
});