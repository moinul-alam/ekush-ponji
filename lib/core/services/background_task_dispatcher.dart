// lib/core/services/background_task_dispatcher.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'package:ekush_ponji/features/quotes/models/quote.dart';
import 'package:ekush_ponji/features/quotes/data/datasources/local/quotes_local_datasource.dart';
import 'package:ekush_ponji/features/quotes/data/repositories/quotes_repository.dart';

import 'package:ekush_ponji/features/words/models/word.dart';
import 'package:ekush_ponji/features/words/data/datasources/local/words_local_datasource.dart';
import 'package:ekush_ponji/features/words/data/repositories/words_repository.dart';
import 'package:ekush_ponji/features/quotes/services/quote_notification_service.dart';
import 'package:ekush_ponji/features/quotes/services/quote_notification_prefs.dart';
import 'package:ekush_ponji/features/words/services/word_notification_service.dart';
import 'package:ekush_ponji/features/words/services/word_notification_prefs.dart';
// ── Task name constants ───────────────────────────────────────

const String kRescheduleQuoteTask = 'reschedule_quote_notifications';
const String kRescheduleWordTask = 'reschedule_word_notifications';

// ── SharedPreferences keys ────────────────────────────────────

const String _languageCodeKey = 'languageCode';

// ── Entry point ───────────────────────────────────────────────

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint('🔄 Background task started: $taskName');

    try {
      await _initHive();

      switch (taskName) {
        case kRescheduleQuoteTask:
          await _rescheduleQuoteNotifications();
          break;
        case kRescheduleWordTask:
          await _rescheduleWordNotifications();
          break;
        default:
          debugPrint('⚠️ Unknown background task: $taskName');
      }

      debugPrint('✅ Background task completed: $taskName');
      return true;
    } catch (e, stack) {
      debugPrint('❌ Background task failed: $taskName — $e');
      debugPrintStack(stackTrace: stack);
      return false;
    }
  });
}

// ── Hive initialization ───────────────────────────────────────

Future<void> _initHive() async {
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(QuoteModelAdapter().typeId)) {
    Hive.registerAdapter(QuoteModelAdapter());
  }
  if (!Hive.isAdapterRegistered(WordModelAdapter().typeId)) {
    Hive.registerAdapter(WordModelAdapter());
  }

  await Future.wait([
    Hive.openBox<QuoteModel>(savedQuotesBoxName),
    Hive.openBox<WordModel>(savedWordsBoxName),
    Hive.openBox('settings'),
  ]);
}

// ── Quote reschedule ──────────────────────────────────────────

Future<void> _rescheduleQuoteNotifications() async {
  final prefs = await QuoteNotificationPrefs.load();

  if (!prefs.enabled) {
    debugPrint('ℹ️ Quote reschedule: disabled — skipping');
    return;
  }

  final sp = await SharedPreferences.getInstance();
  final languageCode = sp.getString(_languageCodeKey) ?? 'bn';

  final repository = QuotesRepository(
    localDatasource: QuotesLocalDatasource(
      savedBox: Hive.box<QuoteModel>(savedQuotesBoxName),
      settingsBox: Hive.box('settings'),
    ),
  );
  await repository.init();

  await QuoteNotificationService.scheduleUpcoming(
    repository: repository,
    prefs: prefs,
    languageCode: languageCode,
  );

  debugPrint('✅ Quote notifications rescheduled from background');
}

// ── Word reschedule ───────────────────────────────────────────

Future<void> _rescheduleWordNotifications() async {
  final prefs = await WordNotificationPrefs.load();

  if (!prefs.enabled) {
    debugPrint('ℹ️ Word reschedule: disabled — skipping');
    return;
  }

  final sp = await SharedPreferences.getInstance();
  final languageCode = sp.getString(_languageCodeKey) ?? 'bn';

  final repository = WordsRepository(
    localDatasource: WordsLocalDatasource(
      savedBox: Hive.box<WordModel>(savedWordsBoxName),
      settingsBox: Hive.box('settings'),
    ),
  );
  await repository.init();

  await WordNotificationService.scheduleUpcoming(
    repository: repository,
    prefs: prefs,
    languageCode: languageCode,
  );

  debugPrint('✅ Word notifications rescheduled from background');
}
