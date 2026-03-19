// lib/features/quotes/providers/quote_notification_prefs_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/quotes/services/quote_notification_prefs.dart';
import 'package:ekush_ponji/features/quotes/services/quote_notification_service.dart';

class QuoteNotificationPrefsNotifier extends Notifier<QuoteNotificationPrefs> {
  @override
  QuoteNotificationPrefs build() {
    _load();
    return const QuoteNotificationPrefs();
  }

  // ── Internal ───────────────────────────────────────────

  Future<void> _load() async {
    final loaded = await QuoteNotificationPrefs.load();
    state = loaded;
  }

  // ── Public API ─────────────────────────────────────────

  /// Reload from disk — call after external code modifies prefs.
  Future<void> reload() async {
    final loaded = await QuoteNotificationPrefs.load();
    state = loaded;
  }

  /// Directly set state without disk read.
  /// Used by NotificationPermissionDialog after it has already
  /// saved to disk — avoids an extra async round-trip.
  void forceState(QuoteNotificationPrefs prefs) {
    state = prefs;
  }

  /// Toggle enabled and reschedule.
  Future<void> setEnabled(bool value, {required String languageCode}) async {
    final updated = state.copyWith(enabled: value);
    state = updated;
    await updated.save();
    await QuoteNotificationService.scheduleUpcoming(
      prefs: updated,
      languageCode: languageCode,
    );
  }
}

final quoteNotificationPrefsProvider =
    NotifierProvider<QuoteNotificationPrefsNotifier, QuoteNotificationPrefs>(
  QuoteNotificationPrefsNotifier.new,
);
