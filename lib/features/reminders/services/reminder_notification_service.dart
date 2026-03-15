// lib/features/reminders/services/reminder_notification_service.dart
//
// Schedules and cancels notifications for user-created reminders.
//
// Notification ID range: 400_000_000 – 499_999_999
// Payload: 'reminder:{id}' → tap navigates to Reminders screen.
//
// Permission: calls NotificationPermissionService.ensurePermission() because
// scheduling is always triggered by an explicit user action (saving a reminder
// with notify enabled). Never called from background or AppInitializer.

import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ekush_ponji/core/notifications/notification_id.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_service.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/features/reminders/models/reminder.dart';

class ReminderNotificationService {
  ReminderNotificationService._();

  static const String _channelId = 'reminders_channel';
  static const String _channelName = 'Reminders';
  static const int _accentColorValue = 0xFF006B54;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Schedule a notification for [reminder] at its date/time.
  ///
  /// Silently cancels and returns if:
  ///   - notificationEnabled is false
  ///   - reminder is completed
  ///   - date/time is in the past
  ///   - OS permission is not granted
  static Future<void> schedule(Reminder reminder) async {
    if (!reminder.notificationEnabled || reminder.isCompleted) {
      await cancel(reminder);
      return;
    }

    final now = DateTime.now();
    if (!reminder.dateTime.isAfter(now)) {
      await cancel(reminder);
      return;
    }

    final ok = await NotificationPermissionService.ensurePermission();
    if (!ok) return;

    // Ensure at least 10 seconds in the future so the plugin doesn't drop it.
    final scheduledTime = reminder.dateTime.difference(now).inSeconds < 10
        ? now.add(const Duration(seconds: 10))
        : reminder.dateTime;

    await LocalNotificationService.scheduleZoned(
      id: NotificationId.forReminder(reminder.id),
      scheduledTime: scheduledTime,
      title: reminder.title,
      body: 'Ekush Ponji • Reminder',
      payload: 'reminder:${reminder.id}',
      details: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(_accentColorValue),
          category: AndroidNotificationCategory.reminder,
          styleInformation: BigTextStyleInformation(reminder.title),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Cancel the notification for [reminder].
  static Future<void> cancel(Reminder reminder) async {
    await LocalNotificationService.cancel(
        NotificationId.forReminder(reminder.id));
  }
}
