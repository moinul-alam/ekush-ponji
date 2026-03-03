// lib/core/services/local_notification_service.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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

    // Step 2: Set device's local timezone — CRITICAL
    // Without this, tz.local defaults to UTC, causing all scheduled
    // notifications to fire at wrong times (or silently drop if in the past)
    try {
      final String deviceTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(deviceTimezone));
      debugPrint('✅ Timezone set to: $deviceTimezone');
    } catch (e) {
      debugPrint('❌ Failed to get device timezone, falling back to Asia/Dhaka: $e');
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
    }

    // Step 3: Configure platform initialization settings
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

  // ── Dev Utilities ─────────────────────────────────────────────────────────

  /// Call this in tests or during hot-restart dev scenarios to force
  /// re-initialization. Do NOT call in production code.
  @visibleForTesting
  static void resetForTesting() {
    _initialized = false;
  }
}