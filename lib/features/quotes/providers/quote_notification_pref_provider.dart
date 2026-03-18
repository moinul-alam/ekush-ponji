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

  Future<void> _load() async {
    final loaded = await QuoteNotificationPrefs.load();
    state = loaded;
  }

  Future<void> setEnabled(bool value, {required String languageCode}) async {
    state = state.copyWith(enabled: value);
    await state.save();
    await QuoteNotificationService.scheduleUpcoming(
      prefs: state,
      languageCode: languageCode,
    );
  }
}

final quoteNotificationPrefsProvider =
    NotifierProvider<QuoteNotificationPrefsNotifier, QuoteNotificationPrefs>(
  QuoteNotificationPrefsNotifier.new,
);
