// lib/features/holidays/services/holiday_notification_service.dart

import 'package:flutter/material.dart' show Color, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:ekush_ponji/core/notifications/notification_id.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_service.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/features/holidays/services/holiday_notification_prefs.dart';

class HolidayNotificationService {
  HolidayNotificationService._();

  static const String _channelId = 'holidays_channel';
  static const String _channelName = 'Holidays';
  static const int _accentColorValue = 0xFF006B54;
  static const int _lookaheadDays = 60;

  // ── Public API ─────────────────────────────────────────────────────────────

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

    final granted = await NotificationPermissionService.isGranted();
    if (!granted) {
      debugPrint('ℹ️ Holiday notifications skipped — permission not granted');
      return;
    }

    await _cancelAll(holidays);

    final bdZone = tz.getLocation('Asia/Dhaka');
    final now = tz.TZDateTime.now(bdZone);
    final cutoff = now.add(const Duration(days: _lookaheadDays));
    int scheduled = 0;

    for (final holiday in holidays) {
      // Compute the evening before the holiday start date
      final holidayDate = DateTime(
        holiday.startDate.year,
        holiday.startDate.month,
        holiday.startDate.day,
      );
      final dayBefore = holidayDate.subtract(const Duration(days: 1));

      final fireTime = tz.TZDateTime(
        bdZone,
        dayBefore.year,
        dayBefore.month,
        dayBefore.day,
        prefs.notifyHour,
        prefs.notifyMinute,
      );

      if (fireTime.isAfter(now) && fireTime.isBefore(cutoff)) {
        await _scheduleOne(
          holiday: holiday,
          fireTime: fireTime.toLocal(),
          languageCode: languageCode,
        );
        scheduled++;
      }
    }

    debugPrint('✅ Scheduled $scheduled holiday notifications');
  }

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

    // Title: "আগামীকাল ঈদ-উল-ফিতর 🇧🇩"
    final title = isBn ? 'আগামীকাল $name 🇧🇩' : 'Tomorrow is $name 🇧🇩';

    // Body: description if available, otherwise category fallback
    final String body;
    if (isBn) {
      final desc = holiday.descriptionbn ?? holiday.description;
      body = (desc != null && desc.isNotEmpty)
          ? desc
          : '${holiday.category.displayNameBn} • একুশ পঞ্জি';
    } else {
      final desc = holiday.description;
      body = (desc != null && desc.isNotEmpty)
          ? desc
          : '${holiday.category.displayName} • Ekush Ponji';
    }

    // Payload uses the holiday's actual start date in 'event:YYYY-MM-DD' format.
    // This routes the tap to CalendarDayDetails for that specific day,
    // showing holidays, events, and reminders — same as tapping a day on the calendar.
    final startDate = holiday.startDate;
    final dateStr =
        '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final payload = 'event:$dateStr';

    await LocalNotificationService.scheduleZoned(
      id: NotificationId.forHoliday(holiday.id),
      scheduledTime: fireTime,
      title: title,
      body: body,
      payload: payload,
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
          styleInformation: BigTextStyleInformation(
            body,
            htmlFormatBigText: false,
            contentTitle: title,
            htmlFormatContentTitle: false,
          ),
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
