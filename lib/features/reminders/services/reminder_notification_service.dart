// lib/features/reminders/services/reminder_notification_service.dart
//
// Notification ID range: 400_000_000 – 499_999_999
// Payload: 'reminder:{YYYY-MM-DD}' → tap navigates to that day's calendar details.

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

    final scheduledTime = reminder.dateTime.difference(now).inSeconds < 10
        ? now.add(const Duration(seconds: 10))
        : reminder.dateTime;

    // Body: description → priority label → fallback
    final String body;
    if (reminder.description != null &&
        reminder.description!.trim().isNotEmpty) {
      body = reminder.description!.trim();
    } else {
      body = '${_priorityLabel(reminder.priority)} • Ekush Ponji';
    }

    // Payload embeds the reminder date so tapping opens that exact day
    final dateStr =
        '${reminder.dateTime.year}-${reminder.dateTime.month.toString().padLeft(2, '0')}-${reminder.dateTime.day.toString().padLeft(2, '0')}';

    await LocalNotificationService.scheduleZoned(
      id: NotificationId.forReminder(reminder.id),
      scheduledTime: scheduledTime,
      title: reminder.title,
      body: body,
      payload: 'reminder:$dateStr',
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
          styleInformation: BigTextStyleInformation(
            body,
            htmlFormatBigText: false,
            contentTitle: reminder.title,
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

  static Future<void> cancel(Reminder reminder) async {
    await LocalNotificationService.cancel(
        NotificationId.forReminder(reminder.id));
  }

  static String _priorityLabel(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.urgent:
        return '🔴 Urgent';
      case ReminderPriority.high:
        return '🟠 High Priority';
      case ReminderPriority.medium:
        return '🔵 Reminder';
      case ReminderPriority.low:
        return '⚪ Low Priority';
    }
  }
}
