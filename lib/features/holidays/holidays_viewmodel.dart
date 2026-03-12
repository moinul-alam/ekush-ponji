// lib/features/holidays/holidays_viewmodel.dart

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
  HolidaysViewMode _viewMode = HolidaysViewMode.gazetteType;
  bool _isSyncing = false;

  // ── Getters ──────────────────────────────────────────────

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

  // ── Lifecycle ─────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _repository = ref.read(calendarRepositoryProvider);
    _syncService = ref.read(dataSyncServiceProvider);
    loadHolidaysForYear(_selectedYear);
  }

  // ── Load ──────────────────────────────────────────────────

  Future<void> loadHolidaysForYear(int year) async {
    await executeAsync(
      operation: () async {
        await _repository.syncHolidaysIfNeeded(year);
        _holidays = await _repository.getHolidaysForYear(year);
        _selectedYear = year;
      },
      loadingMessage: 'Loading holidays...',
      errorMessage: 'Failed to load holidays',
    );
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

  // ── Sync ──────────────────────────────────────────────────

  /// Force-syncs holidays only, then reloads the current year.
  /// Uses a separate [_isSyncing] flag so the list stays visible
  /// while the spinner shows — doesn't replace the whole screen state.
  Future<void> syncHolidays() async {
    if (_isSyncing) return;
    _isSyncing = true;
    setSuccess(); // rebuild to show spinner without wiping list

    try {
      final updated = await _syncService.forceHolidaySync().timeout(
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

  // ── Refresh ───────────────────────────────────────────────

  @override
  Future<bool> refresh() async {
    setLoading(isRefreshing: true);
    try {
      await _repository.syncHolidaysIfNeeded(_selectedYear);
      _holidays = await _repository.getHolidaysForYear(_selectedYear);
      setSuccess();
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