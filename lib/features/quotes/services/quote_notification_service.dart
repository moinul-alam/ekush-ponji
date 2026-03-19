// lib/features/quotes/services/quote_notification_service.dart

import 'package:flutter/material.dart' show Color, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ekush_ponji/core/notifications/notification_id.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_service.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/features/quotes/data/repositories/quotes_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekush_ponji/features/quotes/data/datasources/local/quotes_local_datasource.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';
import 'package:ekush_ponji/features/quotes/services/quote_notification_prefs.dart';

class QuoteNotificationService {
  QuoteNotificationService._();

  static const String _channelId = 'quotes_channel';
  static const String _channelName = 'Daily Quote';
  static const int _accentColorValue = 0xFF006B54;

  static Future<void> scheduleUpcoming({
    QuotesRepository? repository,
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

    final repo = repository ??
        QuotesRepository(
          localDatasource: QuotesLocalDatasource(
            savedBox: Hive.box<QuoteModel>(savedQuotesBoxName),
            settingsBox: Hive.box('settings'),
          ),
        );
    await repo.init();

    // Load full list once so we can find the correct index for each quote
    final allQuotes = repo.getAllQuotes();

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
      final todayQuote = repo.getDailyQuoteForDate(now);
      // Find index so tap navigates to the correct quote
      final todayIndex = allQuotes.indexWhere(
        (q) => q.month == todayQuote.month && q.day == todayQuote.day,
      );
      await _scheduleOne(
        id: NotificationId.quoteToday,
        fireTime: todayFireTime,
        quoteText: todayQuote.text,
        author: todayQuote.author,
        languageCode: languageCode,
        index: todayIndex < 0 ? 0 : todayIndex,
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

    final tomorrowQuote = repo.getDailyQuoteForDate(tomorrow);
    final tomorrowIndex = allQuotes.indexWhere(
      (q) => q.month == tomorrowQuote.month && q.day == tomorrowQuote.day,
    );
    await _scheduleOne(
      id: NotificationId.quoteTomorrow,
      fireTime: tomorrowFireTime,
      quoteText: tomorrowQuote.text,
      author: tomorrowQuote.author,
      languageCode: languageCode,
      index: tomorrowIndex < 0 ? 0 : tomorrowIndex,
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
    required int index,
  }) async {
    final isBn = languageCode == 'bn';
    final title = isBn ? 'আজকের উদ্ধৃতি 💬' : 'Quote of the Day 💬';
    final body = '"$quoteText"\n— $author';

    // Payload format: 'quote:INDEX' — parsed by LocalNotificationService
    // to open the quotes screen at the correct position.
    await LocalNotificationService.scheduleZoned(
      id: id,
      scheduledTime: fireTime,
      title: title,
      body: body,
      payload: 'quote:$index',
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
