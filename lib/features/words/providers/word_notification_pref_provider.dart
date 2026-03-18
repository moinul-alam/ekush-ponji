// lib/features/words/providers/word_notification_prefs_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/words/services/word_notification_prefs.dart';
import 'package:ekush_ponji/features/words/services/word_notification_service.dart';

class WordNotificationPrefsNotifier extends Notifier<WordNotificationPrefs> {
  @override
  WordNotificationPrefs build() {
    _load();
    return const WordNotificationPrefs();
  }

  Future<void> _load() async {
    final loaded = await WordNotificationPrefs.load();
    state = loaded;
  }

  Future<void> setEnabled(bool value, {required String languageCode}) async {
    state = state.copyWith(enabled: value);
    await state.save();
    await WordNotificationService.scheduleUpcoming(
      prefs: state,
      languageCode: languageCode,
    );
  }
}

final wordNotificationPrefsProvider =
    NotifierProvider<WordNotificationPrefsNotifier, WordNotificationPrefs>(
  WordNotificationPrefsNotifier.new,
);
