// lib/core/services/notification_permission_prefs.dart
//
// Tracks whether the app has already asked the user for notification
// permission, and when to re-ask after a denial.
//
// Rules:
//   • Ask on first successful prayer times load (never on cold launch).
//   • If the user denies, wait 3 days before asking again.
//   • If the user grants, never ask again (permission_handler handles the rest).

import 'package:shared_preferences/shared_preferences.dart';

class NotificationPermissionPrefs {
  static const String _askedKey = 'notif_permission_asked';
  static const String _deniedAtKey = 'notif_permission_denied_at';
  static const int _retryDays = 3;

  // ── Public API ────────────────────────────────────────────────

  /// Returns true if the app should show the permission prompt now.
  ///
  /// Shows if:
  ///   • Never been asked before, OR
  ///   • Was denied and at least [_retryDays] days have passed.
  static Future<bool> shouldAsk() async {
    final prefs = await SharedPreferences.getInstance();

    final hasBeenAsked = prefs.getBool(_askedKey) ?? false;
    if (!hasBeenAsked) return true;

    // Was asked before — check if it was denied and retry window has passed.
    final deniedAtRaw = prefs.getString(_deniedAtKey);
    if (deniedAtRaw == null) {
      // Was asked and granted (no denial recorded) — never ask again.
      return false;
    }

    final deniedAt = DateTime.tryParse(deniedAtRaw);
    if (deniedAt == null) return false;

    final daysSinceDenial = DateTime.now().difference(deniedAt).inDays;
    return daysSinceDenial >= _retryDays;
  }

  /// Call this immediately before showing the system permission dialog.
  static Future<void> markAsked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_askedKey, true);
  }

  /// Call this if the user denied the permission.
  /// Records the denial timestamp so [shouldAsk] can enforce the retry window.
  static Future<void> markDenied() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deniedAtKey, DateTime.now().toIso8601String());
  }

  /// Call this if the user granted the permission.
  /// Clears any denial record so we never prompt again.
  static Future<void> markGranted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deniedAtKey);
  }
}
