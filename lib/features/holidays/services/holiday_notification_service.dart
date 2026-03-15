// lib/features/holidays/services/holiday_notification_service.dart
//
// CHANGED:
//   • Replaced private _isPermissionGranted() with
//     NotificationPermissionService.isGranted() — single source of truth.
//   • Replaced private _stableId() with NotificationId.forHoliday() —
//     no more duplication.
//   • scheduleAll() still never requests permission — silent check only.

import 'package:flutter/material.dart' show Color, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ekush_ponji/core/notifications/notification_id.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_service.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/features/holidays/services/holiday_notification_prefs.dart';

/// Schedules a morning notification for every upcoming holiday
/// within the next [_lookaheadDays] days.
///
/// Notification ID range: 600_000_000 – 699_999_999
/// Payload: 'holiday' → tap opens the Holidays screen.
class HolidayNotificationService {
  HolidayNotificationService._();

  static const String _channelId = 'holidays_channel';
  static const String _channelName = 'Holidays';
  static const int _accentColorValue = 0xFF006B54;
  static const int _lookaheadDays = 60;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Cancel all existing holiday notifications then reschedule fresh ones.
  ///
  /// Safe to call on every app launch — cancels stale IDs before rescheduling.
  ///
  /// Uses a SILENT permission check — called from AppInitializer during splash.
  /// Never triggers a permission dialog.
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

    // Silent check — never prompt the user.
    final granted = await NotificationPermissionService.isGranted();
    if (!granted) {
      debugPrint(
          'ℹ️ Holiday notifications skipped — permission not yet granted');
      return;
    }

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
    await LocalNotificationService.cancel(NotificationId.forHoliday(holidayId));
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  static Future<void> _cancelAll(List<Holiday> holidays) async {
    for (final holiday in holidays) {
      await LocalNotificationService.cancel(
          NotificationId.forHoliday(holiday.id));
    }
  }

  static Future<void> _scheduleOne({
    required Holiday holiday,
    required DateTime fireTime,
    required String languageCode,
  }) async {
    final isBn = languageCode == 'bn';
    final name = isBn ? holiday.namebn : holiday.name;
    final title = isBn ? 'আজ $name 🇧🇩' : 'Today is $name 🇧🇩';
    final body = isBn
        ? 'একুশ পঞ্জি • ${holiday.category.displayNameBn}'
        : 'Ekush Ponji • ${holiday.category.displayName}';

    await LocalNotificationService.scheduleZoned(
      id: NotificationId.forHoliday(holiday.id),
      scheduledTime: fireTime,
      title: title,
      body: body,
      payload: 'holiday',
      details: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Notifications for national and special holidays',
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
}
