// lib/features/holidays/holidays_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/services/data_sync_service.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/features/calendar/data/calendar_repository.dart';

enum HolidaysViewMode { gazetteType, monthWise }

class HolidaysViewModel extends BaseViewModel {
  late final CalendarRepository _repository;
  late final DataSyncService _syncService;

  AppLocalizations? _l10n;

  List<Holiday> _holidays = [];
  int _selectedYear = DateTime.now().year;
  HolidaysViewMode _viewMode = HolidaysViewMode.monthWise;
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
  void onSyncSetup() {
    _repository = ref.read(calendarRepositoryProvider);
    _syncService = ref.read(dataSyncServiceProvider);
  }

  @override
  void onInit() {
    super.onInit();
    loadHolidaysForYear(_selectedYear);
  }

  // ── Load ──────────────────────────────────────────────────

  Future<void> loadHolidaysForYear(
    int year, [
    AppLocalizations? l10n,
  ]) async {
    if (l10n != null) _l10n = l10n;

    setLoading(message: 'Loading holidays...');
    try {
      _holidays = await _repository.getHolidaysForYear(year);
      _selectedYear = year;
      setSuccess();
    } catch (e, st) {
      handleError(
        e,
        st,
        customMessage: _l10n?.failedToLoadData ?? 'Failed to load holidays',
      );
      return;
    }

    _backgroundSyncIfNeeded();
  }

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
      debugPrint('⚠️ HolidaysViewModel: background sync failed silently — $e');
    }
  }

  Future<void> goToPreviousYear([AppLocalizations? l10n]) async {
    await loadHolidaysForYear(_selectedYear - 1, l10n ?? _l10n);
  }

  Future<void> goToNextYear([AppLocalizations? l10n]) async {
    await loadHolidaysForYear(_selectedYear + 1, l10n ?? _l10n);
  }

  void toggleViewMode() {
    _viewMode = _viewMode == HolidaysViewMode.gazetteType
        ? HolidaysViewMode.monthWise
        : HolidaysViewMode.gazetteType;
    setSuccess();
  }

  // ── Manual sync ───────────────────────────────────────────

  Future<void> syncHolidays(AppLocalizations l10n) async {
    _l10n = l10n;
    if (_isSyncing) return;
    _isSyncing = true;
    setSuccess();

    try {
      final updated = await _syncService.syncHolidaysOnly().timeout(
            const Duration(seconds: 15),
            onTimeout: () => false,
          );

      if (updated) {
        _holidays = await _repository.getHolidaysForYear(_selectedYear);
      }

      _isSyncing = false;
      setSuccess(
        message: updated ? l10n.syncDatasetHolidays : l10n.syncUpToDate,
      );
    } catch (e, st) {
      _isSyncing = false;
      handleError(
        e,
        st,
        customMessage: l10n.syncFailed,
      );
    }
  }

  // ── Pull-to-refresh ───────────────────────────────────────

  @override
  Future<bool> refresh() async {
    setLoading(isRefreshing: true);
    try {
      _holidays = await _repository.getHolidaysForYear(_selectedYear);
      setSuccess();
      _backgroundSyncIfNeeded();
      return true;
    } catch (e, st) {
      handleError(
        e,
        st,
        customMessage: _l10n?.failedToLoadData ?? 'Failed to refresh holidays',
      );
      return false;
    }
  }
}

final holidaysViewModelProvider =
    NotifierProvider<HolidaysViewModel, ViewState>(
  () => HolidaysViewModel(),
);
