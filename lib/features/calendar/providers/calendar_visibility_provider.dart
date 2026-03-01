// lib/features/calendar/providers/calendar_visibility_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Holds visibility state for date types shown in each calendar day cell.
class CalendarVisibilityState {
  final bool showBengaliDate;
  final bool showHijriDate;

  const CalendarVisibilityState({
    this.showBengaliDate = true,
    this.showHijriDate = true,
  });

  CalendarVisibilityState copyWith({
    bool? showBengaliDate,
    bool? showHijriDate,
  }) {
    return CalendarVisibilityState(
      showBengaliDate: showBengaliDate ?? this.showBengaliDate,
      showHijriDate: showHijriDate ?? this.showHijriDate,
    );
  }
}

class CalendarVisibilityNotifier
    extends Notifier<CalendarVisibilityState> {
  static const String _bengaliKey = 'calendar_show_bengali_date';
  static const String _hijriKey = 'calendar_show_hijri_date';

  @override
  CalendarVisibilityState build() {
    // Load persisted state asynchronously after initial build
    _loadFromPrefs();
    return const CalendarVisibilityState(); // default: both visible
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final showBengali = prefs.getBool(_bengaliKey) ?? true;
      final showHijri = prefs.getBool(_hijriKey) ?? true;

      // Only update if different from defaults to avoid unnecessary rebuilds
      if (!showBengali || !showHijri) {
        state = CalendarVisibilityState(
          showBengaliDate: showBengali,
          showHijriDate: showHijri,
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading calendar visibility: $e');
    }
  }

  Future<void> toggleBengaliDate() async {
    final newValue = !state.showBengaliDate;
    state = state.copyWith(showBengaliDate: newValue);
    await _persist(_bengaliKey, newValue);
  }

  Future<void> toggleHijriDate() async {
    final newValue = !state.showHijriDate;
    state = state.copyWith(showHijriDate: newValue);
    await _persist(_hijriKey, newValue);
  }

  Future<void> _persist(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
      debugPrint('✅ Calendar visibility saved: $key = $value');
    } catch (e) {
      debugPrint('❌ Error saving calendar visibility: $e');
    }
  }
}

final calendarVisibilityProvider =
    NotifierProvider<CalendarVisibilityNotifier, CalendarVisibilityState>(
  CalendarVisibilityNotifier.new,
);