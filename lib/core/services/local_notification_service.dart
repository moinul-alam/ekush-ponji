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

  /// Payload formats:
  ///   'holiday'              → Holidays screen
  ///   'quote:INDEX'          → Quotes screen at today's quote position
  ///   'word:INDEX'           → Words screen at today's word position
  ///   'event:YYYY-MM-DD'     → Calendar → day details for that date
  ///   'reminder:YYYY-MM-DD'  → Calendar → day details for that date
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    debugPrint('🔔 Notification tapped: id=${response.id}, payload=$payload');

    if (payload == null || payload.isEmpty) {
      AppRouter.router.go(RouteNames.home);
      return;
    }

    if (payload == 'holiday') {
      AppRouter.router.push(RouteNames.holidays);
      return;
    }

    // 'quote:INDEX' — push quotes screen at today's quote position
    if (payload.startsWith('quote:')) {
      final index = int.tryParse(payload.substring('quote:'.length)) ?? 0;
      AppRouter.router.push(RouteNames.quotes, extra: index);
      return;
    }

    // 'word:INDEX' — push words screen at today's word position
    if (payload.startsWith('word:')) {
      final index = int.tryParse(payload.substring('word:'.length)) ?? 0;
      AppRouter.router.push(RouteNames.words, extra: index);
      return;
    }

    // 'event:YYYY-MM-DD' — navigate to that day's calendar details
    if (payload.startsWith('event:')) {
      _navigateToCalendarDay(payload.substring('event:'.length));
      return;
    }

    // 'reminder:YYYY-MM-DD' — navigate to that day's calendar details
    if (payload.startsWith('reminder:')) {
      _navigateToCalendarDay(payload.substring('reminder:'.length));
      return;
    }

    AppRouter.router.go(RouteNames.home);
  }

  /// Navigates to the calendar tab then pushes the day-details screen
  /// with [dateStr] (YYYY-MM-DD) as extra so [DayDetailsScreen] can
  /// jump to and select the correct day.
  static void _navigateToCalendarDay(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);

      // Go to the calendar shell branch first
      AppRouter.router.go(RouteNames.calendar);

      // Wait one frame for the shell to settle, then push day details
      Future.delayed(const Duration(milliseconds: 300), () {
        AppRouter.router.push(
          RouteNames.calendarDayDetails,
          extra: date,
        );
      });
    } catch (e) {
      debugPrint('⚠️ _navigateToCalendarDay error: $e');
      AppRouter.router.go(RouteNames.calendar);
    }
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
