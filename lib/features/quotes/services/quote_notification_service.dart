// lib/features/quotes/services/quote_notification_service.dart
//
// QuoteNotificationPrefs is defined HERE — the separate
// quote_notification_prefs.dart file must be DELETED.
// Having prefs in a separate file caused duplicate import errors because
// both this service and its callers imported the prefs file independently.

import 'dart:convert';

import 'package:flutter/material.dart' show Color, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekush_ponji/core/notifications/notification_id.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_service.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/features/quotes/data/datasources/local/quotes_local_datasource.dart';

// ── Prefs ──────────────────────────────────────────────────────────────────────

class QuoteNotificationPrefs {
  static const String _prefsKey = 'quote_notification_prefs';

  final bool enabled;
  final int notifyHour;
  final int notifyMinute;

  const QuoteNotificationPrefs({
    this.enabled = true,
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

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'notifyHour': notifyHour,
        'notifyMinute': notifyMinute,
      };

  factory QuoteNotificationPrefs.fromJson(Map<String, dynamic> json) {
    return QuoteNotificationPrefs(
      enabled: json['enabled'] as bool? ?? true,
      notifyHour: json['notifyHour'] as int? ?? 9,
      notifyMinute: json['notifyMinute'] as int? ?? 0,
    );
  }

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

// ── Service ────────────────────────────────────────────────────────────────────

class QuoteNotificationService {
  QuoteNotificationService._();

  static const String _channelId = 'quotes_channel';
  static const String _channelName = 'Daily Quote';
  static const int _accentColorValue = 0xFF006B54;

  static Future<void> scheduleUpcoming({
    required QuotesLocalDatasource datasource,
    required QuoteNotificationPrefs prefs,
    required String languageCode,
  }) async {
    await LocalNotificationService.initialize();

    if (!prefs.enabled) {
      await cancelAll();
      return;
    }

    final granted = await NotificationPermissionService.isGranted();
    if (!granted) {
      debugPrint('ℹ️ Quote notifications skipped — permission not yet granted');
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
      final todayQuote = datasource.getDailyQuote();
      await _scheduleOne(
        id: NotificationId.quoteToday,
        fireTime: todayFireTime,
        quoteText: todayQuote.text,
        author: todayQuote.author,
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

    final tomorrowQuote = datasource.getDailyQuoteForDate(tomorrow);
    await _scheduleOne(
      id: NotificationId.quoteTomorrow,
      fireTime: tomorrowFireTime,
      quoteText: tomorrowQuote.text,
      author: tomorrowQuote.author,
      languageCode: languageCode,
    );

    debugPrint('✅ Quote notifications scheduled (today + tomorrow)');
  }

  static Future<void> cancelAll() async {
    await LocalNotificationService.cancel(NotificationId.quoteToday);
    await LocalNotificationService.cancel(NotificationId.quoteTomorrow);
    debugPrint('✅ Quote notifications cancelled');
  }

  static Future<void> _scheduleOne({
    required int id,
    required DateTime fireTime,
    required String quoteText,
    required String author,
    required String languageCode,
  }) async {
    final isBn = languageCode == 'bn';
    final title = isBn ? 'আজকের উদ্ধৃতি 💬' : 'Quote of the Day 💬';
    final body = '"$quoteText"\n— $author';

    await LocalNotificationService.scheduleZoned(
      id: id,
      scheduledTime: fireTime,
      title: title,
      body: body,
      payload: 'quote',
      details: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Daily inspirational quote',
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
