// lib/features/events/services/event_notification_service.dart
//
// Notification ID range: 200_000_000 – 299_999_999
// Payload: 'event:{YYYY-MM-DD}' → tap navigates to that day's calendar details.

import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ekush_ponji/core/notifications/notification_id.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_service.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/features/events/models/event.dart';

class EventNotificationService {
  EventNotificationService._();

  static const String _channelId = 'events_channel';
  static const String _channelName = 'Events';
  static const int _accentColorValue = 0xFF006B54;

  static Future<void> schedule(Event event) async {
    if (!event.notifyAtStartTime) {
      await cancel(event);
      return;
    }

    final now = DateTime.now();
    if (!event.startTime.isAfter(now)) {
      await cancel(event);
      return;
    }

    final ok = await NotificationPermissionService.ensurePermission();
    if (!ok) return;

    final scheduledTime = event.startTime.difference(now).inSeconds < 10
        ? now.add(const Duration(seconds: 10))
        : event.startTime;

    // Body: description → location → fallback
    final String body;
    if (event.description != null && event.description!.trim().isNotEmpty) {
      body = event.description!.trim();
    } else if (event.location != null && event.location!.trim().isNotEmpty) {
      body = '📍 ${event.location!.trim()}';
    } else {
      body = 'Ekush Ponji • Event';
    }

    // Payload embeds the event date so tapping opens that exact day
    final dateStr =
        '${event.startTime.year}-${event.startTime.month.toString().padLeft(2, '0')}-${event.startTime.day.toString().padLeft(2, '0')}';

    await LocalNotificationService.scheduleZoned(
      id: NotificationId.forEvent(event.id),
      scheduledTime: scheduledTime,
      title: event.title,
      body: body,
      payload: 'event:$dateStr',
      details: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Event reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(_accentColorValue),
          category: AndroidNotificationCategory.event,
          styleInformation: BigTextStyleInformation(
            body,
            htmlFormatBigText: false,
            contentTitle: event.title,
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

  static Future<void> cancel(Event event) async {
    await LocalNotificationService.cancel(NotificationId.forEvent(event.id));
  }
}
