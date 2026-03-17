// lib/core/services/background_task_dispatcher.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:ekush_ponji/features/quotes/services/quote_notification_service.dart';
import 'package:ekush_ponji/features/quotes/data/datasources/local/quotes_local_datasource.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';
import 'package:ekush_ponji/features/words/services/word_notification_service.dart';
import 'package:ekush_ponji/features/words/data/datasources/local/words_local_datasource.dart';
import 'package:ekush_ponji/features/words/models/word.dart';

// ── Task name constants ───────────────────────────────────────

const String kRescheduleQuoteTask = 'reschedule_quote_notifications';
const String kRescheduleWordTask = 'reschedule_word_notifications';

// ── SharedPreferences keys ────────────────────────────────────

const String _languageCodeKey = 'languageCode';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint('🔄 Background task started: $taskName');

    try {
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
    } catch (e) {
      debugPrint('❌ Background task failed: $taskName — $e');
      return false;
    }
  });
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

  // Hive must be initialised in background isolate before opening boxes.
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(QuoteModelAdapter());
  }

  final savedBox = await Hive.openBox<QuoteModel>(savedQuotesBoxName);
  final settingsBox = await Hive.openBox('settings');

  final datasource = QuotesLocalDatasource(
    savedBox: savedBox,
    settingsBox: settingsBox,
  );
  await datasource.init();

  await QuoteNotificationService.scheduleUpcoming(
    datasource: datasource,
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

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(11)) {
    Hive.registerAdapter(WordModelAdapter());
  }

  final savedBox = await Hive.openBox<WordModel>(savedWordsBoxName);
  final settingsBox = await Hive.openBox('settings');

  final datasource = WordsLocalDatasource(
    savedBox: savedBox,
    settingsBox: settingsBox,
  );
  await datasource.init();

  await WordNotificationService.scheduleUpcoming(
    datasource: datasource,
    prefs: prefs,
    languageCode: languageCode,
  );

  debugPrint('✅ Word notifications rescheduled from background');
}
