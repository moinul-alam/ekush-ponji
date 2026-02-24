// lib/features/prayer_times/prayer_settings_viewmodel.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekush_ponji/features/prayer_times/models/prayer_times_model.dart';

class PrayerSettingsState {
  final PrayerCalculationSettings calculationSettings;
  final PrayerNotificationPrefs notificationPrefs;

  const PrayerSettingsState({
    this.calculationSettings = const PrayerCalculationSettings(),
    this.notificationPrefs = const PrayerNotificationPrefs(),
  });

  PrayerSettingsState copyWith({
    PrayerCalculationSettings? calculationSettings,
    PrayerNotificationPrefs? notificationPrefs,
  }) {
    return PrayerSettingsState(
      calculationSettings: calculationSettings ?? this.calculationSettings,
      notificationPrefs: notificationPrefs ?? this.notificationPrefs,
    );
  }
}

class PrayerSettingsViewModel extends Notifier<PrayerSettingsState> {
  static const _calcKey = 'prayer_calculation_settings';
  static const _notifKey = 'prayer_notification_prefs';

  @override
  PrayerSettingsState build() {
    _load();
    return const PrayerSettingsState();
  }

  // ── Load ───────────────────────────────────────────────

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    PrayerCalculationSettings calcSettings = const PrayerCalculationSettings();
    PrayerNotificationPrefs notifPrefs = const PrayerNotificationPrefs();

    final calcJson = prefs.getString(_calcKey);
    if (calcJson != null) {
      try {
        calcSettings = PrayerCalculationSettings.fromJson(
            jsonDecode(calcJson) as Map<String, dynamic>);
      } catch (_) {}
    }

    final notifJson = prefs.getString(_notifKey);
    if (notifJson != null) {
      try {
        notifPrefs = PrayerNotificationPrefs.fromJson(
            jsonDecode(notifJson) as Map<String, dynamic>);
      } catch (_) {}
    }

    state = PrayerSettingsState(
      calculationSettings: calcSettings,
      notificationPrefs: notifPrefs,
    );
  }

  // ── Calculation method ─────────────────────────────────

  Future<void> setMethodKey(String methodKey) async {
    state = state.copyWith(
      calculationSettings: state.calculationSettings.copyWith(
        methodKey: methodKey,
      ),
    );
    await _saveCalc();
  }

  Future<void> setHanafi(bool isHanafi) async {
    state = state.copyWith(
      calculationSettings: state.calculationSettings.copyWith(
        isHanafi: isHanafi,
      ),
    );
    await _saveCalc();
  }

  // ── Notification prefs ─────────────────────────────────

  Future<void> setMasterEnabled(bool enabled) async {
    state = state.copyWith(
      notificationPrefs:
          state.notificationPrefs.copyWith(masterEnabled: enabled),
    );
    await _saveNotif();
  }

  Future<void> setPrayerEnabled(Prayer prayer, bool enabled) async {
    PrayerNotificationPrefs updated;
    switch (prayer) {
      case Prayer.fajr:
        updated =
            state.notificationPrefs.copyWith(fajrEnabled: enabled);
        break;
      case Prayer.dhuhr:
        updated =
            state.notificationPrefs.copyWith(dhuhrEnabled: enabled);
        break;
      case Prayer.asr:
        updated =
            state.notificationPrefs.copyWith(asrEnabled: enabled);
        break;
      case Prayer.maghrib:
        updated =
            state.notificationPrefs.copyWith(maghribEnabled: enabled);
        break;
      case Prayer.isha:
        updated =
            state.notificationPrefs.copyWith(ishaEnabled: enabled);
        break;
      default:
        return;
    }
    state = state.copyWith(notificationPrefs: updated);
    await _saveNotif();
  }

  Future<void> setOffsetMinutes(int minutes) async {
    state = state.copyWith(
      notificationPrefs:
          state.notificationPrefs.copyWith(offsetMinutes: minutes),
    );
    await _saveNotif();
  }

  // ── Persistence ────────────────────────────────────────

  Future<void> _saveCalc() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _calcKey, jsonEncode(state.calculationSettings.toJson()));
  }

  Future<void> _saveNotif() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _notifKey, jsonEncode(state.notificationPrefs.toJson()));
  }
}

final prayerSettingsViewModelProvider =
    NotifierProvider<PrayerSettingsViewModel, PrayerSettingsState>(
  PrayerSettingsViewModel.new,
);