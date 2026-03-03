// lib/features/calendar/services/calendar_notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/features/home/models/event.dart';
import 'package:ekush_ponji/features/home/models/reminder.dart';

class CalendarNotificationService {
  static const _eventChannelId = 'events_channel';
  static const _eventChannelName = 'Events';
  static const _reminderChannelId = 'reminders_channel';
  static const _reminderChannelName = 'Reminders';

  // ── Stable ID Generation ──────────────────────────────────────────────────

  /// Generates a stable, non-negative notification ID from a raw string ID.
  ///
  /// Problem with the previous implementation: Dart's [hashCode] can return
  /// negative values (including [int.minValue] on 64-bit), where .abs() is
  /// still negative — causing the notification plugin to reject the ID.
  ///
  /// This version uses a simple djb2-style hash that always produces a
  /// non-negative integer within Android's safe notification ID range.
  static int _stableId(String rawId, {required int base}) {
    // djb2 hash — always non-negative via bitmask
    int hash = 5381;
    for (final unit in rawId.codeUnits) {
      hash = ((hash << 5) + hash) + unit;
      hash &= 0x7FFFFFFF; // keep positive, 31-bit safe
    }
    // Combine with base, stay within safe int range
    return (base + (hash % 100000000)).abs();
  }

  static int eventNotificationId(Event event) =>
      _stableId(event.id, base: 200000000);

  static int reminderNotificationId(Reminder reminder) =>
      _stableId(reminder.id, base: 400000000);

  // ── Event Scheduling ──────────────────────────────────────────────────────

  static Future<void> scheduleEvent(Event event) async {
    final ok = await LocalNotificationService.ensurePermission();
    if (!ok) return;

    if (!event.notifyAtStartTime) {
      await cancelEvent(event);
      return;
    }

    final now = DateTime.now();

    if (!event.startTime.isAfter(now)) {
      await cancelEvent(event);
      return;
    }

    // Ensure at least 10 seconds in the future so the plugin doesn't drop it
    final scheduledTime = event.startTime.difference(now).inSeconds < 10
        ? now.add(const Duration(seconds: 10))
        : event.startTime;

    final id = eventNotificationId(event);

    await LocalNotificationService.scheduleZoned(
      id: id,
      scheduledTime: scheduledTime,
      title: event.title,
      body: 'Ekush Ponji • Event',
      details: NotificationDetails(
        android: AndroidNotificationDetails(
          _eventChannelId,
          _eventChannelName,
          channelDescription: 'Event reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ── Reminder Scheduling ───────────────────────────────────────────────────

  static Future<void> scheduleReminder(Reminder reminder) async {
    final ok = await LocalNotificationService.ensurePermission();
    if (!ok) return;

    if (!reminder.notificationEnabled || reminder.isCompleted) {
      await cancelReminder(reminder);
      return;
    }

    final now = DateTime.now();

    if (!reminder.dateTime.isAfter(now)) {
      await cancelReminder(reminder);
      return;
    }

    final scheduledTime = reminder.dateTime.difference(now).inSeconds < 10
        ? now.add(const Duration(seconds: 10))
        : reminder.dateTime;

    final id = reminderNotificationId(reminder);

    await LocalNotificationService.scheduleZoned(
      id: id,
      scheduledTime: scheduledTime,
      title: reminder.title,
      body: 'Ekush Ponji • Reminder',
      details: NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannelId,
          _reminderChannelName,
          channelDescription: 'Reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ── Cancel ────────────────────────────────────────────────────────────────

  static Future<void> cancelEvent(Event event) async {
    await LocalNotificationService.cancel(eventNotificationId(event));
  }

  static Future<void> cancelReminder(Reminder reminder) async {
    await LocalNotificationService.cancel(reminderNotificationId(reminder));
  }
}