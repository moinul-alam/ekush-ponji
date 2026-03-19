// lib/core/services/local_notification_service.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:ekush_ponji/app/router/app_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // ── Initialization ────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    try {
      final String tzName = _resolveLocalTimezoneName();
      tz.setLocalLocation(tz.getLocation(tzName));
      debugPrint('✅ Timezone set to: $tzName');
    } catch (e) {
      debugPrint(
          '❌ Failed to resolve timezone, falling back to Asia/Dhaka: $e');
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    debugPrint('✅ LocalNotificationService initialized');
  }

  // ── Permission ────────────────────────────────────────────────────────────

  /// Requests all required notification permissions.
  /// Returns true only if ALL permissions are granted.
  static Future<bool> ensurePermission() async {
    await initialize();

    final notifStatus = await Permission.notification.status;
    if (!notifStatus.isGranted) {
      final result = await Permission.notification.request();
      if (!result.isGranted) {
        debugPrint('❌ Notification permission denied');
        return false;
      }
    }

    if (Platform.isAndroid) {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      if (!exactAlarmStatus.isGranted) {
        final result = await Permission.scheduleExactAlarm.request();
        if (!result.isGranted) {
          debugPrint(
              '❌ Exact alarm permission denied — notifications will not fire');
          return false;
        }
      }
    }

    debugPrint('✅ All notification permissions granted');
    return true;
  }

  // ── Cancel ────────────────────────────────────────────────────────────────

  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ── Schedule ──────────────────────────────────────────────────────────────

  /// Schedule a notification at [scheduledTime] in the device's local timezone.
  ///
  /// Payload format — determines navigation on tap:
  ///   'prayer'        → Prayer Times screen
  ///   'holiday'       → Holidays screen
  ///   'quote:INDEX'   → Quotes screen at the given list index
  ///   'word:INDEX'    → Words screen at the given list index
  ///   'event:id'      → Calendar screen
  ///   'reminder:id'   → Reminders screen
  static Future<void> scheduleZoned({
    required int id,
    required DateTime scheduledTime,
    required String title,
    required String body,
    required NotificationDetails details,
    String? payload,
  }) async {
    await initialize();

    final tz.TZDateTime tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    final now = tz.TZDateTime.now(tz.local);
    if (tzTime.isBefore(now)) {
      debugPrint(
        '⚠️ Skipping notification id=$id — scheduled time is in the past '
        '(scheduled: $tzTime, now: $now)',
      );
      return;
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint('✅ Notification scheduled: id=$id at $tzTime — "$title"');
  }

  // ── Tap Handler ───────────────────────────────────────────────────────────

  /// Called when the user taps a notification.
  /// Navigates using AppRouter.router — no BuildContext needed.
  ///
  /// Payload formats:
  ///   'holiday'       → Holidays screen
  ///   'quote:INDEX'   → Quotes screen at INDEX (int)
  ///   'word:INDEX'    → Words screen at INDEX (int)
  ///   'event:ID'      → Calendar screen
  ///   'reminder:ID'   → Reminders screen
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    debugPrint('🔔 Notification tapped: id=${response.id}, payload=$payload');

    if (payload == null || payload.isEmpty) {
      AppRouter.router.go(RouteNames.home);
      return;
    }

    if (payload == 'holiday') {
      AppRouter.router.go(RouteNames.holidays);
      return;
    }

    // 'quote:INDEX' — open quotes screen at the scheduled quote's position
    if (payload.startsWith('quote:')) {
      final indexStr = payload.substring('quote:'.length);
      final index = int.tryParse(indexStr) ?? 0;
      AppRouter.router.go(RouteNames.quotes, extra: index);
      return;
    }

    // 'word:INDEX' — open words screen at the scheduled word's position
    if (payload.startsWith('word:')) {
      final indexStr = payload.substring('word:'.length);
      final index = int.tryParse(indexStr) ?? 0;
      AppRouter.router.go(RouteNames.words, extra: index);
      return;
    }

    // 'event:ID' — open calendar (ID not currently used for navigation)
    if (payload.startsWith('event:')) {
      AppRouter.router.go(RouteNames.calendar);
      return;
    }

    // 'reminder:ID' — open reminders list (ID not currently used for navigation)
    if (payload.startsWith('reminder:')) {
      AppRouter.router.go(RouteNames.reminders);
      return;
    }

    AppRouter.router.go(RouteNames.home);
  }

  // ── Timezone Resolution ───────────────────────────────────────────────────

  static String _resolveLocalTimezoneName() {
    final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;

    const Map<int, String> offsetToTimezone = {
      330: 'Asia/Kolkata',
      345: 'Asia/Kathmandu',
      360: 'Asia/Dhaka',
      390: 'Asia/Yangon',
      420: 'Asia/Bangkok',
      480: 'Asia/Singapore',
      300: 'Asia/Karachi',
      270: 'Asia/Kabul',
      240: 'Asia/Dubai',
      180: 'Asia/Riyadh',
      120: 'Africa/Cairo',
      60: 'Europe/Paris',
      0: 'Europe/London',
      -300: 'America/New_York',
      -360: 'America/Chicago',
      -420: 'America/Denver',
      -480: 'America/Los_Angeles',
    };

    return offsetToTimezone[offsetMinutes] ?? 'Asia/Dhaka';
  }
}
