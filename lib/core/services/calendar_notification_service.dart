import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/features/home/models/event.dart';
import 'package:ekush_ponji/features/home/models/reminder.dart';

class CalendarNotificationService {
  static const _eventChannelId = 'events_channel';
  static const _eventChannelName = 'Events';

  static const _reminderChannelId = 'reminders_channel';
  static const _reminderChannelName = 'Reminders';

  static int _stableId(String rawId, {required int base}) {
    final trimmed = rawId.trim();
    final digits = trimmed.length > 9 ? trimmed.substring(trimmed.length - 9) : trimmed;
    final parsed = int.tryParse(digits) ?? trimmed.hashCode.abs();
    return base + (parsed % 999999999);
  }

  static int eventNotificationId(Event event) =>
      _stableId(event.id, base: 200000000);

  static int reminderNotificationId(Reminder reminder) =>
      _stableId(reminder.id, base: 400000000);

  static Future<void> scheduleEvent(Event event) async {
    final ok = await LocalNotificationService.ensurePermission();
    if (!ok) return;

    if (!event.notifyAtStartTime) {
      await cancelEvent(event);
      return;
    }

    final now = DateTime.now();
    // If the time is already passed, don't schedule
    if (!event.startTime.isAfter(now)) {
      await cancelEvent(event);
      return;
    }

    // For very near-future tests, make sure we have a few seconds buffer
    final scheduledTime = event.startTime.difference(now).inSeconds < 10
        ? now.add(const Duration(seconds: 10))
        : event.startTime;

    final id = eventNotificationId(event);

    final details = NotificationDetails(
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
    );

    await LocalNotificationService.scheduleZoned(
      id: id,
      scheduledTime: scheduledTime,
      title: event.title,
      body: 'Ekush Ponji • Event',
      details: details,
    );
  }

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

    final details = NotificationDetails(
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
    );

    await LocalNotificationService.scheduleZoned(
      id: id,
      scheduledTime: scheduledTime,
      title: reminder.title,
      body: 'Ekush Ponji • Reminder',
      details: details,
    );
  }

  static Future<void> cancelEvent(Event event) async {
    await LocalNotificationService.cancel(eventNotificationId(event));
  }

  static Future<void> cancelReminder(Reminder reminder) async {
    await LocalNotificationService.cancel(reminderNotificationId(reminder));
  }
}

