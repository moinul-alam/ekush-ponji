// lib/core/services/local_notification_service.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // ── Initialization ────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    if (_initialized) return;

    // Step 1: Initialize timezone database
    tz.initializeTimeZones();

    // Step 2: Resolve device timezone using Dart's built-in DateTime —
    try {
      final String tzName = _resolveLocalTimezoneName();
      tz.setLocalLocation(tz.getLocation(tzName));
      debugPrint('✅ Timezone set to: $tzName');
    } catch (e) {
      debugPrint('❌ Failed to resolve timezone, falling back to Asia/Dhaka: $e');
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
    }

    // Step 3: Configure platform initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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

  /// Request all permissions required for scheduled notifications.
  /// Returns true only if all required permissions are granted.
  static Future<bool> ensurePermission() async {
    await initialize();

    // 1. Notification permission (Android 13+ / API 33+)
    final notifStatus = await Permission.notification.status;
    if (!notifStatus.isGranted) {
      final result = await Permission.notification.request();
      if (!result.isGranted) {
        debugPrint('❌ Notification permission denied');
        return false;
      }
    }

    // 2. Exact alarm permission (Android 12+ / API 31+)
    // SCHEDULE_EXACT_ALARM can be revoked by the user in Settings,
    // so we must check at runtime — not just at install time.
    if (Platform.isAndroid) {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      if (!exactAlarmStatus.isGranted) {
        final result = await Permission.scheduleExactAlarm.request();
        if (!result.isGranted) {
          debugPrint('❌ Exact alarm permission denied — notifications will not fire');
          return false;
        }
      }
    }

    debugPrint('✅ All notification permissions granted');
    return true;
  }

  // ── Cancel ────────────────────────────────────────────────────────────────

  static Future<void> cancel(int id) async {
    await initialize();
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  // ── Schedule ──────────────────────────────────────────────────────────────

  static Future<void> scheduleZoned({
    required int id,
    required DateTime scheduledTime,
    required String title,
    required String body,
    required NotificationDetails details,
  }) async {
    await initialize();

    // Convert to TZDateTime using the device's local timezone (set during init)
    final tz.TZDateTime tzTime =
        tz.TZDateTime.from(scheduledTime, tz.local);

    // Guard: don't schedule notifications in the past
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint('✅ Notification scheduled: id=$id at $tzTime — "$title"');
  }

  // ── Tap Handler ───────────────────────────────────────────────────────────

  static void _onNotificationTapped(NotificationResponse response) {
    // TODO: handle navigation on notification tap using go_router
    debugPrint('🔔 Notification tapped: id=${response.id}, payload=${response.payload}');
  }

  // ── Timezone Resolution ───────────────────────────────────────────────────

  /// Resolves the device's IANA timezone name without any native plugin.
  ///
  /// Strategy: Dart's [DateTime.now()] always uses the host OS local timezone.
  /// We read its UTC offset and match it against known IANA timezone names
  /// from the tz database. For devices in Bangladesh (UTC+6) this will always
  /// return 'Asia/Dhaka'. For other offsets a best-effort match is returned.
  ///
  /// Limitation: UTC offset alone cannot distinguish between timezones that
  /// share the same offset (e.g. UTC+6 covers Asia/Dhaka and Asia/Almaty).
  /// For a prayer-times app where users are overwhelmingly in Bangladesh,
  /// this is acceptable and avoids a broken native dependency entirely.
  static String _resolveLocalTimezoneName() {
    final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;

    // Common UTC offset → IANA timezone map
    // Covers South Asia and neighbouring regions
    const Map<int, String> offsetToTimezone = {
      330:  'Asia/Kolkata',    // UTC+5:30 — India
      345:  'Asia/Kathmandu',  // UTC+5:45 — Nepal
      360:  'Asia/Dhaka',      // UTC+6    — Bangladesh ✓
      390:  'Asia/Yangon',     // UTC+6:30 — Myanmar
      420:  'Asia/Bangkok',    // UTC+7    — Thailand/Vietnam
      480:  'Asia/Singapore',  // UTC+8    — Singapore/Malaysia
      300:  'Asia/Karachi',    // UTC+5    — Pakistan
      270:  'Asia/Kabul',      // UTC+4:30 — Afghanistan
      240:  'Asia/Dubai',      // UTC+4    — UAE
      180:  'Asia/Riyadh',     // UTC+3    — Saudi Arabia
      120:  'Africa/Cairo',    // UTC+2    — Egypt
      60:   'Europe/Paris',    // UTC+1    — Central Europe
      0:    'Europe/London',   // UTC+0    — UK
      -300: 'America/New_York',// UTC-5    — US Eastern
      -360: 'America/Chicago', // UTC-6    — US Central
      -420: 'America/Denver',  // UTC-7    — US Mountain
      -480: 'America/Los_Angeles', // UTC-8 — US Pacific
    };

    return offsetToTimezone[offsetMinutes] ?? 'Asia/Dhaka';
  }

}