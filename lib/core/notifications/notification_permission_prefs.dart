// lib/core/notifications/notification_permission_prefs.dart

import 'package:shared_preferences/shared_preferences.dart';

class NotificationPermissionPrefs {
  static const String _askedKey = 'notif_permission_asked';
  static const String _deniedAtKey = 'notif_permission_denied_at';
  static const String _denialCountKey = 'notif_permission_denial_count';
  static const int _retryDays = 7;
  static const int _maxDenials = 2;

  // ── Public API ────────────────────────────────────────────────

  /// Returns true if the app should show the permission prompt now.
  ///
  /// Shows if:
  ///   • Never been asked before, OR
  ///   • Was denied fewer than [_maxDenials] times AND
  ///     at least [_retryDays] days have passed since last denial.
  static Future<bool> shouldAsk() async {
    final prefs = await SharedPreferences.getInstance();

    // Check denial count first — hard stop at max denials
    final denialCount = prefs.getInt(_denialCountKey) ?? 0;
    if (denialCount >= _maxDenials) return false;

    final hasBeenAsked = prefs.getBool(_askedKey) ?? false;
    if (!hasBeenAsked) return true;

    // Was asked before — check if denied and retry window has passed
    final deniedAtRaw = prefs.getString(_deniedAtKey);
    if (deniedAtRaw == null) {
      // Was asked and granted (no denial recorded) — never ask again
      return false;
    }

    final deniedAt = DateTime.tryParse(deniedAtRaw);
    if (deniedAt == null) return false;

    final daysSinceDenial = DateTime.now().difference(deniedAt).inDays;
    return daysSinceDenial >= _retryDays;
  }

  /// Call this immediately before showing the permission dialog.
  static Future<void> markAsked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_askedKey, true);
  }

  /// Call this if the user denied the permission.
  /// Increments denial count and records timestamp.
  static Future<void> markDenied() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_denialCountKey) ?? 0;
    await prefs.setInt(_denialCountKey, count + 1);
    await prefs.setString(_deniedAtKey, DateTime.now().toIso8601String());
  }

  /// Call this if the user granted the permission.
  /// Clears denial record — never prompt again via global dialog.
  static Future<void> markGranted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deniedAtKey);
    // Keep _denialCountKey as-is — granted means we stop asking anyway
  }

  /// Returns current denial count (for debugging / analytics).
  static Future<int> denialCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_denialCountKey) ?? 0;
  }
}
