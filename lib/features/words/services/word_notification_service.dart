// lib/features/words/services/word_notification_service.dart
//
// WordNotificationPrefs is defined HERE — the separate
// word_notification_prefs.dart file must be DELETED.
// Having prefs in a separate file caused duplicate import errors because
// both this service and its callers imported the prefs file independently.

import 'dart:convert';

import 'package:flutter/material.dart' show Color, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekush_ponji/core/notifications/notification_id.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_service.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/features/words/data/datasources/local/words_local_datasource.dart';

// ── Prefs ──────────────────────────────────────────────────────────────────────

class WordNotificationPrefs {
  static const String _prefsKey = 'word_notification_prefs';

  final bool enabled;
  final int notifyHour;
  final int notifyMinute;

  const WordNotificationPrefs({
    this.enabled = true,
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

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'notifyHour': notifyHour,
        'notifyMinute': notifyMinute,
      };

  factory WordNotificationPrefs.fromJson(Map<String, dynamic> json) {
    return WordNotificationPrefs(
      enabled: json['enabled'] as bool? ?? true,
      notifyHour: json['notifyHour'] as int? ?? 10,
      notifyMinute: json['notifyMinute'] as int? ?? 0,
    );
  }

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

// ── Service ────────────────────────────────────────────────────────────────────

class WordNotificationService {
  WordNotificationService._();

  static const String _channelId = 'words_channel';
  static const String _channelName = 'Word of the Day';
  static const int _accentColorValue = 0xFF006B54;

  static Future<void> scheduleUpcoming({
    required WordsLocalDatasource datasource,
    required WordNotificationPrefs prefs,
    required String languageCode,
  }) async {
    await LocalNotificationService.initialize();

    if (!prefs.enabled) {
      await cancelAll();
      return;
    }

    final granted = await NotificationPermissionService.isGranted();
    if (!granted) {
      debugPrint('ℹ️ Word notifications skipped — permission not yet granted');
      return;
    }

    final now = DateTime.now();

    // ── Today ──────────────────────────────────────────────────────────────
    final todayFireTime = DateTime(
      now.year,
      now.month,
      now.day,
      prefs.notifyHour,
      prefs.notifyMinute,
    );

    if (todayFireTime.isAfter(now)) {
      final todayWord = datasource.getDailyWord();
      await _scheduleOne(
        id: NotificationId.wordToday,
        fireTime: todayFireTime,
        word: todayWord.word,
        meaning:
            languageCode == 'bn' ? todayWord.meaningBn : todayWord.meaningEn,
        languageCode: languageCode,
      );
    }

    // ── Tomorrow ───────────────────────────────────────────────────────────
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowFireTime = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      prefs.notifyHour,
      prefs.notifyMinute,
    );

    final tomorrowWord = datasource.getDailyWordForDate(tomorrow);
    await _scheduleOne(
      id: NotificationId.wordTomorrow,
      fireTime: tomorrowFireTime,
      word: tomorrowWord.word,
      meaning: languageCode == 'bn'
          ? tomorrowWord.meaningBn
          : tomorrowWord.meaningEn,
      languageCode: languageCode,
    );

    debugPrint('✅ Word notifications scheduled (today + tomorrow)');
  }

  static Future<void> cancelAll() async {
    await LocalNotificationService.cancel(NotificationId.wordToday);
    await LocalNotificationService.cancel(NotificationId.wordTomorrow);
    debugPrint('✅ Word notifications cancelled');
  }

  static Future<void> _scheduleOne({
    required int id,
    required DateTime fireTime,
    required String word,
    required String meaning,
    required String languageCode,
  }) async {
    final isBn = languageCode == 'bn';
    final title = isBn ? 'আজকের শব্দ 📖' : 'Word of the Day 📖';
    final body = '$word — $meaning';

    await LocalNotificationService.scheduleZoned(
      id: id,
      scheduledTime: fireTime,
      title: title,
      body: body,
      payload: 'word',
      details: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Daily word of the day',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          color: const Color(_accentColorValue),
          category: AndroidNotificationCategory.reminder,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  }
}
