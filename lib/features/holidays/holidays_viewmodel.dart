// lib/features/holidays/holidays_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/features/calendar/data/calendar_repository.dart';

// ─────────────────────────────────────────────────────────────
// VIEW MODE
// ─────────────────────────────────────────────────────────────

enum HolidaysViewMode { gazetteType, monthWise }

// ─────────────────────────────────────────────────────────────
// VIEWMODEL
// ─────────────────────────────────────────────────────────────

class HolidaysViewModel extends BaseViewModel {
  late final CalendarRepository _repository;

  // Internal state
  List<Holiday> _holidays = [];
  int _selectedYear = DateTime.now().year;
  HolidaysViewMode _viewMode = HolidaysViewMode.gazetteType;

  // ── Getters ──────────────────────────────────────────────

  int get selectedYear => _selectedYear;
  HolidaysViewMode get viewMode => _viewMode;
  List<Holiday> get holidays => _holidays;

  /// Holidays grouped by GazetteType, in official gazette order.
  /// Empty groups are excluded.
  Map<GazetteType, List<Holiday>> get groupedByGazetteType {
    final Map<GazetteType, List<Holiday>> map = {};

    // Maintain official gazette order
    for (final type in GazetteType.values) {
      final group = _holidays.where((h) => h.gazetteType == type).toList();
      group.sort((a, b) => a.startDate.compareTo(b.startDate));
      if (group.isNotEmpty) {
        map[type] = group;
      }
    }

    return map;
  }

  /// Holidays grouped by month (1–12).
  /// Empty months are excluded.
  Map<int, List<Holiday>> get groupedByMonth {
    final Map<int, List<Holiday>> map = {};

    for (final holiday in _holidays) {
      final month = holiday.startDate.month;
      map.putIfAbsent(month, () => []).add(holiday);
    }

    // Sort holidays within each month by date
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
    loadHolidaysForYear(_selectedYear);
  }

  // ── Public Methods ────────────────────────────────────────

  Future<void> loadHolidaysForYear(int year) async {
    await executeAsync(
      operation: () async {
        // Sync from remote if needed, then load from local
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
    // No async operation — just rebuild
    setSuccess();
  }

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

// ─────────────────────────────────────────────────────────────
// PROVIDER
// ─────────────────────────────────────────────────────────────

final holidaysViewModelProvider =
    NotifierProvider<HolidaysViewModel, ViewState>(
  () => HolidaysViewModel(),
);