// lib/features/events/services/event_notification_service.dart
//
// Schedules and cancels notifications for user-created events.
//
// Notification ID range: 200_000_000 – 299_999_999
// Payload: 'event:{id}' → tap navigates to Calendar screen.
//
// Permission: calls NotificationPermissionService.ensurePermission() because
// scheduling is always triggered by an explicit user action (saving an event
// with notify enabled). Never called from background or AppInitializer.

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

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Schedule a notification for [event] at its start time.
  ///
  /// Silently cancels and returns if:
  ///   - notifyAtStartTime is false
  ///   - start time is in the past
  ///   - OS permission is not granted
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

    // Ensure at least 10 seconds in the future so the plugin doesn't drop it.
    final scheduledTime = event.startTime.difference(now).inSeconds < 10
        ? now.add(const Duration(seconds: 10))
        : event.startTime;

    await LocalNotificationService.scheduleZoned(
      id: NotificationId.forEvent(event.id),
      scheduledTime: scheduledTime,
      title: event.title,
      body: 'Ekush Ponji • Event',
      payload: 'event:${event.id}',
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
          styleInformation: BigTextStyleInformation(event.title),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Cancel the notification for [event].
  static Future<void> cancel(Event event) async {
    await LocalNotificationService.cancel(NotificationId.forEvent(event.id));
  }
}
