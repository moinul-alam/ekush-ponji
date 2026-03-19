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

  // ── Internal ───────────────────────────────────────────

  Future<void> _load() async {
    final loaded = await WordNotificationPrefs.load();
    state = loaded;
  }

  // ── Public API ─────────────────────────────────────────

  /// Reload from disk — call after external code modifies prefs.
  Future<void> reload() async {
    final loaded = await WordNotificationPrefs.load();
    state = loaded;
  }

  /// Directly set state without disk read.
  /// Used by NotificationPermissionDialog after it has already
  /// saved to disk — avoids an extra async round-trip.
  void forceState(WordNotificationPrefs prefs) {
    state = prefs;
  }

  /// Toggle enabled and reschedule.
  Future<void> setEnabled(bool value, {required String languageCode}) async {
    final updated = state.copyWith(enabled: value);
    state = updated;
    await updated.save();
    await WordNotificationService.scheduleUpcoming(
      prefs: updated,
      languageCode: languageCode,
    );
  }
}

final wordNotificationPrefsProvider =
    NotifierProvider<WordNotificationPrefsNotifier, WordNotificationPrefs>(
  WordNotificationPrefsNotifier.new,
);
