// lib/features/words/services/word_notification_prefs.dart
//
// Stores and loads word-of-the-day notification preferences.
// Persisted as a single JSON blob in SharedPreferences.
//
// Defaults: enabled=false (user must opt-in), notifyHour=10, notifyMinute=0 (10:00 AM)
// Chosen to not interfere with holiday (8:00 AM) or quote (9:00 AM) notifications.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordNotificationPrefs {
  static const String _prefsKey = 'word_notification_prefs';

  final bool enabled;
  final int notifyHour;
  final int notifyMinute;

  const WordNotificationPrefs({
    this.enabled = false, // off by default — user must opt-in
    this.notifyHour = 10,
    this.notifyMinute = 0,
  });

  WordNotificationPrefs copyWith({
    bool? enabled,
    int? notifyHour,
    int? notifyMinute,
  }) {
    return WordNotificationPrefs(
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

  factory WordNotificationPrefs.fromJson(Map<String, dynamic> json) {
    return WordNotificationPrefs(
      enabled: json['enabled'] as bool? ?? false,
      notifyHour: json['notifyHour'] as int? ?? 10,
      notifyMinute: json['notifyMinute'] as int? ?? 0,
    );
  }

  // ── SharedPreferences persistence ─────────────────────────────────────────

  static Future<WordNotificationPrefs> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return const WordNotificationPrefs();
      return WordNotificationPrefs.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️ WordNotificationPrefs.load error: $e');
      return const WordNotificationPrefs();
    }
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(toJson()));
      debugPrint('✅ WordNotificationPrefs saved');
    } catch (e) {
      debugPrint('❌ WordNotificationPrefs.save error: $e');
    }
  }

  @override
  String toString() => 'WordNotificationPrefs(enabled=$enabled, '
      'time=$notifyHour:${notifyMinute.toString().padLeft(2, "0")})';
}