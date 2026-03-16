// lib/features/quotes/services/quote_notification_prefs.dart
//
// Stores and loads quote notification preferences.
// Persisted as a single JSON blob in SharedPreferences.
//
// Defaults: enabled=false (user must opt-in), notifyHour=9, notifyMinute=0 (9:00 AM)
// Chosen to not interfere with holiday notifications (8:00 AM).

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuoteNotificationPrefs {
  static const String _prefsKey = 'quote_notification_prefs';

  final bool enabled;
  final int notifyHour;
  final int notifyMinute;

  const QuoteNotificationPrefs({
    this.enabled = false, // off by default — user must opt-in
    this.notifyHour = 9,
    this.notifyMinute = 0,
  });

  QuoteNotificationPrefs copyWith({
    bool? enabled,
    int? notifyHour,
    int? notifyMinute,
  }) {
    return QuoteNotificationPrefs(
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

  factory QuoteNotificationPrefs.fromJson(Map<String, dynamic> json) {
    return QuoteNotificationPrefs(
      enabled: json['enabled'] as bool? ?? false,
      notifyHour: json['notifyHour'] as int? ?? 9,
      notifyMinute: json['notifyMinute'] as int? ?? 0,
    );
  }

  // ── SharedPreferences persistence ─────────────────────────────────────────

  static Future<QuoteNotificationPrefs> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return const QuoteNotificationPrefs();
      return QuoteNotificationPrefs.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️ QuoteNotificationPrefs.load error: $e');
      return const QuoteNotificationPrefs();
    }
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(toJson()));
      debugPrint('✅ QuoteNotificationPrefs saved');
    } catch (e) {
      debugPrint('❌ QuoteNotificationPrefs.save error: $e');
    }
  }

  @override
  String toString() => 'QuoteNotificationPrefs(enabled=$enabled, '
      'time=$notifyHour:${notifyMinute.toString().padLeft(2, "0")})';
}