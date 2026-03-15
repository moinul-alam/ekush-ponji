// lib/features/holidays/services/holiday_notification_service.dart

import 'package:flutter/material.dart' show Color, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/features/holidays/services/holiday_notification_prefs.dart';

/// Schedules a morning notification for every upcoming holiday
/// within the next [_lookaheadDays] days.
///
/// Notification ID range: 600_000_000 – 699_999_999
///   — well clear of prayers (100–114), events (200M+), reminders (400M+).
///
/// Payload: 'holiday' → tap opens the Holidays screen.
class HolidayNotificationService {
  static const String _channelId = 'holidays_channel';
  static const String _channelName = 'Holidays';
  static const int _accentColorValue = 0xFF006B54; // app primary green
  static const int _lookaheadDays = 60;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Cancel all existing holiday notifications then reschedule fresh ones
  /// for every holiday inside the next [_lookaheadDays] days.
  ///
  /// Safe to call on every app launch — duplicate scheduling is prevented
  /// by first cancelling all IDs in our range.
  static Future<void> scheduleAll({
    required List<Holiday> holidays,
    required HolidayNotificationPrefs prefs,
    required String languageCode,
  }) async {
    await LocalNotificationService.initialize();

    if (!prefs.enabled) {
      await _cancelAll(holidays);
      return;
    }

    final ok = await LocalNotificationService.ensurePermission();
    if (!ok) return;

    // Cancel stale holiday notifications before rescheduling
    await _cancelAll(holidays);

    final now = DateTime.now();
    final cutoff = now.add(const Duration(days: _lookaheadDays));

    int scheduled = 0;

    for (final holiday in holidays) {
      final fireTime = DateTime(
        holiday.startDate.year,
        holiday.startDate.month,
        holiday.startDate.day,
        prefs.notifyHour,
        prefs.notifyMinute,
      );

      // Only schedule if the fire time is in the future and within lookahead
      if (fireTime.isAfter(now) && fireTime.isBefore(cutoff)) {
        await _scheduleOne(
          holiday: holiday,
          fireTime: fireTime,
          languageCode: languageCode,
        );
        scheduled++;
      }
    }

    debugPrint('✅ Scheduled $scheduled holiday notifications');
  }

  /// Cancel a single holiday notification by holiday ID.
  static Future<void> cancelOne(String holidayId) async {
    await LocalNotificationService.cancel(_stableId(holidayId));
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  static Future<void> _cancelAll(List<Holiday> holidays) async {
    for (final holiday in holidays) {
      await LocalNotificationService.cancel(_stableId(holiday.id));
    }
  }

  static Future<void> _scheduleOne({
    required Holiday holiday,
    required DateTime fireTime,
    required String languageCode,
  }) async {
    final isBn = languageCode == 'bn';
    final name = isBn ? holiday.namebn : holiday.name;

    // ── Notification copy ──────────────────────────────────────────────────
    //
    // Bengali: আজ শহীদ দিবস ও আন্তর্জাতিক মাতৃভাষা দিবস 🇧🇩
    //          একুশ পঞ্জি • জাতীয়
    //
    // English: Today is International Mother Language Day 🇧🇩
    //          Ekush Ponji • National
    //
    final title = isBn ? 'আজ $name 🇧🇩' : 'Today is $name 🇧🇩';
    final body = isBn
        ? 'একুশ পঞ্জি • ${holiday.category.displayNameBn}'
        : 'Ekush Ponji • ${holiday.category.displayName}';

    final id = _stableId(holiday.id);

    await LocalNotificationService.scheduleZoned(
      id: id,
      scheduledTime: fireTime,
      title: title,
      body: body,
      payload: 'holiday', // tap → Holidays screen
      details: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription:
              'Notifications for national and special holidays',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(_accentColorValue),
          category: AndroidNotificationCategory.event,
          styleInformation: BigTextStyleInformation('$title\n$body'),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Generates a stable, non-negative notification ID in the range
  /// 600_000_000 – 699_999_999 from a holiday's raw string ID.
  ///
  /// Uses djb2-style hash — same approach as CalendarNotificationService.
  static int _stableId(String rawId) {
    int hash = 5381;
    for (final unit in rawId.codeUnits) {
      hash = ((hash << 5) + hash) + unit;
      hash &= 0x7FFFFFFF; // keep positive, 31-bit safe
    }
    return (600000000 + (hash % 100000000)).abs();
  }
}