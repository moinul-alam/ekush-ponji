// lib/features/holidays/providers/holiday_notification_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/features/holidays/services/holiday_notification_prefs.dart';
import 'package:ekush_ponji/features/holidays/services/holiday_notification_service.dart';

/// Synchronous Notifier that owns [HolidayNotificationPrefs] state.
///
/// We use a plain [Notifier] (not AsyncNotifier) so consumers can read
/// [state] directly — no .when() / .value / .valueOrNull needed anywhere.
///
/// Prefs are loaded once at provider build time via [HolidayNotificationPrefs.load].
/// The initial state is the default (enabled=true) and is replaced by the
/// real persisted value as soon as the async load completes.
///
/// Usage:
///   final prefs = ref.watch(holidayNotificationProvider);
///   prefs.enabled  // ← plain bool, always safe
///
///   ref.read(holidayNotificationProvider.notifier).setEnabled(true, ...);
class HolidayNotificationNotifier extends Notifier<HolidayNotificationPrefs> {
  @override
  HolidayNotificationPrefs build() {
    // Return defaults immediately so widgets don't need to handle null.
    // Then kick off the async load and update state once complete.
    _loadPersistedPrefs();
    return const HolidayNotificationPrefs();
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<void> _loadPersistedPrefs() async {
    final loaded = await HolidayNotificationPrefs.load();
    state = loaded;
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Toggle the master enabled switch, persist the change, and reschedule.
  Future<void> setEnabled(
    bool value, {
    required List<Holiday> holidays,
    required String languageCode,
  }) async {
    final updated = state.copyWith(enabled: value);
    state = updated;
    await updated.save();

    await HolidayNotificationService.scheduleAll(
      holidays: holidays,
      prefs: updated,
      languageCode: languageCode,
    );
  }

  /// Re-run scheduling with the current prefs (call after holidays sync).
  Future<void> reschedule({
    required List<Holiday> holidays,
    required String languageCode,
  }) async {
    await HolidayNotificationService.scheduleAll(
      holidays: holidays,
      prefs: state,
      languageCode: languageCode,
    );
  }
}

final holidayNotificationProvider =
    NotifierProvider<HolidayNotificationNotifier, HolidayNotificationPrefs>(
  HolidayNotificationNotifier.new,
);