// lib/core/notifications/notification_permission_service.dart
//
// Single source of truth for notification permission across the entire app.
//
// Two distinct operations:
//   isGranted()       — silent status check. Never shows a dialog.
//                       Use in background tasks, AppInitializer, and any
//                       scheduling service called outside of a user action.
//
//   ensurePermission()— requests permission if not yet granted. Shows the
//                       system dialog on first ask. Use only when triggered
//                       by an explicit user action (toggling a switch, etc.).
//
// All feature notification services import this file.
// local_notification_service.dart retains its own ensurePermission() for
// internal use — feature services must go through this class.

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';

class NotificationPermissionService {
  NotificationPermissionService._();

  // ── Silent check ──────────────────────────────────────────────────────────

  /// Returns true if ALL required notification permissions are already granted.
  ///
  /// Never triggers a system dialog — purely reads current OS permission state.
  ///
  /// Use this in:
  ///   - AppInitializer (splash / background phase)
  ///   - Any scheduleAll() called on app launch or reboot
  ///   - Toggle display logic (is permission currently granted?)
  static Future<bool> isGranted() async {
    final notifStatus = await Permission.notification.status;
    if (!notifStatus.isGranted) return false;

    if (Platform.isAndroid) {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      if (!exactAlarmStatus.isGranted) return false;
    }

    debugPrint('✅ NotificationPermissionService.isGranted() → true');
    return true;
  }

  // ── Request (user-triggered only) ─────────────────────────────────────────

  /// Requests all required notification permissions.
  ///
  /// Shows the system permission dialog if not yet granted.
  /// Returns true only if ALL required permissions are granted after the call.
  ///
  /// Use this ONLY when triggered by an explicit user action:
  ///   - Flipping a notification toggle ON in any screen
  ///   - The contextual prompt after prayer times first load
  ///
  /// Never call this from background tasks or AppInitializer.
  static Future<bool> ensurePermission() async {
    return LocalNotificationService.ensurePermission();
  }
}
