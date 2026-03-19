// lib/features/holidays/providers/holiday_notification_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/features/holidays/services/holiday_notification_prefs.dart';
import 'package:ekush_ponji/features/holidays/services/holiday_notification_service.dart';

class HolidayNotificationNotifier extends Notifier<HolidayNotificationPrefs> {
  bool _prefsLoaded = false;

  @override
  HolidayNotificationPrefs build() {
    _prefsLoaded = false;
    _loadPersistedPrefs();
    return const HolidayNotificationPrefs();
  }

  // ── Internal ───────────────────────────────────────────────

  Future<void> _loadPersistedPrefs() async {
    final loaded = await HolidayNotificationPrefs.load();
    state = loaded;
    _prefsLoaded = true;
  }

  /// Waits for persisted prefs to finish loading.
  /// Guards against race conditions when methods are called
  /// immediately after provider initialisation.
  Future<HolidayNotificationPrefs> _awaitLoadedPrefs() async {
    if (_prefsLoaded) return state;
    while (!_prefsLoaded) {
      await Future.delayed(const Duration(milliseconds: 20));
    }
    return state;
  }

  // ── Public API ─────────────────────────────────────────────

  /// Toggle the master enabled switch, persist, and reschedule.
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

  /// Re-run scheduling with current prefs.
  /// Call after holidays data syncs from remote.
  Future<void> reschedule({
    required List<Holiday> holidays,
    required String languageCode,
  }) async {
    final prefs = await _awaitLoadedPrefs();
    await HolidayNotificationService.scheduleAll(
      holidays: holidays,
      prefs: prefs,
      languageCode: languageCode,
    );
  }

  /// Called after OS permission is granted globally.
  /// Only reschedules if holiday notifications were already enabled —
  /// never force-enables. Waits for prefs to load first.
  Future<void> rescheduleIfEnabled({
    required List<Holiday> holidays,
    required String languageCode,
  }) async {
    final prefs = await _awaitLoadedPrefs();
    if (!prefs.enabled) return;
    await HolidayNotificationService.scheduleAll(
      holidays: holidays,
      prefs: prefs,
      languageCode: languageCode,
    );
  }
}

final holidayNotificationProvider =
    NotifierProvider<HolidayNotificationNotifier, HolidayNotificationPrefs>(
  HolidayNotificationNotifier.new,
);
