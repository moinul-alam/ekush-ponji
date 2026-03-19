// lib/features/words/services/word_notification_service.dart

import 'package:flutter/material.dart' show Color, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ekush_ponji/core/notifications/notification_id.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_service.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:ekush_ponji/features/words/data/repositories/words_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekush_ponji/features/words/data/datasources/local/words_local_datasource.dart';
import 'package:ekush_ponji/features/words/models/word.dart';
import 'package:ekush_ponji/features/words/services/word_notification_prefs.dart';

class WordNotificationService {
  WordNotificationService._();

  static const String _channelId = 'words_channel';
  static const String _channelName = 'Word of the Day';
  static const int _accentColorValue = 0xFF006B54;

  static Future<void> scheduleUpcoming({
    WordsRepository? repository,
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

    final repo = repository ??
        WordsRepository(
          localDatasource: WordsLocalDatasource(
            savedBox: Hive.box<WordModel>(savedWordsBoxName),
            settingsBox: Hive.box('settings'),
          ),
        );
    await repo.init();

    // Load full list once so we can find the correct index for each word
    final allWords = repo.getAllWords();

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
      final todayWord = repo.getDailyWordForDate(now);
      // Find index so tap navigates to the correct word
      final todayIndex = allWords.indexWhere(
        (w) => w.month == todayWord.month && w.day == todayWord.day,
      );
      await _scheduleOne(
        id: NotificationId.wordToday,
        fireTime: todayFireTime,
        word: todayWord.word,
        meaning:
            languageCode == 'bn' ? todayWord.meaningBn : todayWord.meaningEn,
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

    final tomorrowWord = repo.getDailyWordForDate(tomorrow);
    final tomorrowIndex = allWords.indexWhere(
      (w) => w.month == tomorrowWord.month && w.day == tomorrowWord.day,
    );
    await _scheduleOne(
      id: NotificationId.wordTomorrow,
      fireTime: tomorrowFireTime,
      word: tomorrowWord.word,
      meaning: languageCode == 'bn'
          ? tomorrowWord.meaningBn
          : tomorrowWord.meaningEn,
      languageCode: languageCode,
      index: tomorrowIndex < 0 ? 0 : tomorrowIndex,
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
    required int index,
  }) async {
    final isBn = languageCode == 'bn';
    final title = isBn ? 'আজকের শব্দ 📖' : 'Word of the Day 📖';
    final body = '$word — $meaning';

    // Payload format: 'word:INDEX' — parsed by LocalNotificationService
    // to open the words screen at the correct position.
    await LocalNotificationService.scheduleZoned(
      id: id,
      scheduledTime: fireTime,
      title: title,
      body: body,
      payload: 'word:$index',
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
