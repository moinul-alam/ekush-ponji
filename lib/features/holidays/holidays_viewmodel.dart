// lib/features/holidays/holidays_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/services/data_sync_service.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/features/calendar/data/calendar_repository.dart';

enum HolidaysViewMode { gazetteType, monthWise }

class HolidaysViewModel extends BaseViewModel {
  late final CalendarRepository _repository;
  late final DataSyncService _syncService;

  List<Holiday> _holidays = [];
  int _selectedYear = DateTime.now().year;

  /// Default is monthWise — more natural for users landing on the screen.
  HolidaysViewMode _viewMode = HolidaysViewMode.monthWise;

  bool _isSyncing = false;

  // ── Getters ──────────────────────────────────────────────────────────────

  int get selectedYear => _selectedYear;
  HolidaysViewMode get viewMode => _viewMode;
  List<Holiday> get holidays => _holidays;
  bool get isSyncing => _isSyncing;

  Map<GazetteType, List<Holiday>> get groupedByGazetteType {
    final Map<GazetteType, List<Holiday>> map = {};
    for (final type in GazetteType.values) {
      final group = _holidays.where((h) => h.gazetteType == type).toList();
      group.sort((a, b) => a.startDate.compareTo(b.startDate));
      if (group.isNotEmpty) map[type] = group;
    }
    return map;
  }

  Map<int, List<Holiday>> get groupedByMonth {
    final Map<int, List<Holiday>> map = {};
    for (final holiday in _holidays) {
      map.putIfAbsent(holiday.startDate.month, () => []).add(holiday);
    }
    for (final key in map.keys) {
      map[key]!.sort((a, b) => a.startDate.compareTo(b.startDate));
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _repository = ref.read(calendarRepositoryProvider);
    _syncService = ref.read(dataSyncServiceProvider);
    loadHolidaysForYear(_selectedYear);
  }

  // ── Load ─────────────────────────────────────────────────────────────────

  /// Step 1: Instantly read from Hive and show the UI.
  /// Step 2: Fire background sync — non-blocking, no spinner.
  ///         If sync updates holidays, reload silently.
  Future<void> loadHolidaysForYear(int year) async {
    // ── Instant load from Hive ──────────────────────────────
    setLoading(message: 'Loading holidays...');
    try {
      _holidays = await _repository.getHolidaysForYear(year);
      _selectedYear = year;
      setSuccess();
    } catch (e, st) {
      handleError(e, st, customMessage: 'Failed to load holidays');
      return;
    }

    // ── Background sync (non-blocking, fire and forget) ─────
    _backgroundSyncIfNeeded();
  }

  /// Background sync — does not show a loading state on the screen.
  /// If new data arrives, silently reloads the holiday list.
  Future<void> _backgroundSyncIfNeeded() async {
    try {
      final updated = await _syncService.syncHolidaysOnly().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          debugPrint('⏱️ HolidaysViewModel: background sync timed out');
          return false;
        },
      );

      if (updated) {
        _holidays = await _repository.getHolidaysForYear(_selectedYear);
        setSuccess();
        debugPrint('✅ HolidaysViewModel: UI updated after background sync');
      }
    } catch (e) {
      // Background sync failures are silent — the user already sees cached data
      debugPrint('⚠️ HolidaysViewModel: background sync failed silently — $e');
    }
  }

  Future<void> goToPreviousYear() async {
    await loadHolidaysForYear(_selectedYear - 1);
  }

  Future<void> goToNextYear() async {
    await loadHolidaysForYear(_selectedYear + 1);
  }

  void toggleViewMode() {
    _viewMode = _viewMode == HolidaysViewMode.gazetteType
        ? HolidaysViewMode.monthWise
        : HolidaysViewMode.gazetteType;
    setSuccess();
  }

  // ── Manual sync (sync button in AppBar) ──────────────────────────────────

  /// Explicitly triggered by the user. Shows a spinner, awaits result.
  Future<void> syncHolidays() async {
    if (_isSyncing) return;
    _isSyncing = true;
    setSuccess(); // rebuild to show spinner without wiping list

    try {
      final updated = await _syncService.syncHolidaysOnly().timeout(
            const Duration(seconds: 15),
            onTimeout: () => false,
          );

      if (updated) {
        _holidays = await _repository.getHolidaysForYear(_selectedYear);
      }

      _isSyncing = false;
      setSuccess(message: updated ? 'Holidays updated!' : 'Already up to date');
    } catch (e, st) {
      _isSyncing = false;
      handleError(e, st, customMessage: 'Sync failed — check your connection');
    }
  }

  // ── Pull-to-refresh ───────────────────────────────────────────────────────

  @override
  Future<bool> refresh() async {
    // Show pull-to-refresh indicator
    setLoading(isRefreshing: true);

    try {
      // Always reload from Hive first so UI updates instantly
      _holidays = await _repository.getHolidaysForYear(_selectedYear);
      setSuccess();

      // Then background-sync (non-blocking)
      _backgroundSyncIfNeeded();

      return true;
    } catch (e, st) {
      handleError(e, st, customMessage: 'Failed to refresh holidays');
      return false;
    }
  }
}

final holidaysViewModelProvider =
    NotifierProvider<HolidaysViewModel, ViewState>(
  () => HolidaysViewModel(),
);
