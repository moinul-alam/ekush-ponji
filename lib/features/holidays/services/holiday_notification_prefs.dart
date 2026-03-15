// lib/features/holidays/services/holiday_notification_prefs.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores and loads holiday notification preferences.
///
/// Persisted as a single JSON blob under [_prefsKey] in SharedPreferences.
///
/// Fields:
///   [enabled]      — master switch (default: true)
///   [notifyHour]   — hour of day to fire (default: 8, i.e. 8:00 AM)
///   [notifyMinute] — minute of hour to fire (default: 0)
class HolidayNotificationPrefs {
  static const String _prefsKey = 'holiday_notification_prefs';

  final bool enabled;
  final int notifyHour;
  final int notifyMinute;

  const HolidayNotificationPrefs({
    this.enabled = true,
    this.notifyHour = 8,
    this.notifyMinute = 0,
  });

  HolidayNotificationPrefs copyWith({
    bool? enabled,
    int? notifyHour,
    int? notifyMinute,
  }) {
    return HolidayNotificationPrefs(
      enabled: enabled ?? this.enabled,
      notifyHour: notifyHour ?? this.notifyHour,
      notifyMinute: notifyMinute ?? this.notifyMinute,
    );
  }

  // ── Serialisation ──────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'notifyHour': notifyHour,
        'notifyMinute': notifyMinute,
      };

  factory HolidayNotificationPrefs.fromJson(Map<String, dynamic> json) {
    return HolidayNotificationPrefs(
      enabled: json['enabled'] as bool? ?? true,
      notifyHour: json['notifyHour'] as int? ?? 8,
      notifyMinute: json['notifyMinute'] as int? ?? 0,
    );
  }

  // ── SharedPreferences persistence ─────────────────────────────────────────

  /// Load from SharedPreferences. Returns defaults if nothing saved yet.
  static Future<HolidayNotificationPrefs> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return const HolidayNotificationPrefs();
      return HolidayNotificationPrefs.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️ HolidayNotificationPrefs.load error: $e');
      return const HolidayNotificationPrefs();
    }
  }

  /// Persist to SharedPreferences.
  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(toJson()));
      debugPrint('✅ HolidayNotificationPrefs saved');
    } catch (e) {
      debugPrint('❌ HolidayNotificationPrefs.save error: $e');
    }
  }

  @override
  String toString() =>
      'HolidayNotificationPrefs(enabled=$enabled, '
      'time=$notifyHour:${notifyMinute.toString().padLeft(2, "0")})';
}