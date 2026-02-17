import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekush_ponji/features/calendar/data/local/calendar_local_datasource.dart';
import 'package:ekush_ponji/features/calendar/data/remote/calendar_remote_datasource.dart';
import 'package:ekush_ponji/features/calendar/data//repositories/repositories_providers.dart';

/// Enum to track sync result per year
enum _SyncResult { synced, skipped, failed }

/// Service to sync holidays from Firebase to local Hive storage
/// Uses timestamp-based smart sync to avoid unnecessary fetches
class SyncService {
  final CalendarLocalDatasource _localDatasource;
  final CalendarRemoteDatasource _remoteDatasource;

  SyncService({
    CalendarLocalDatasource? localDatasource,
    CalendarRemoteDatasource? remoteDatasource,
  })  : _localDatasource = localDatasource ?? CalendarLocalDatasource(),
        _remoteDatasource = remoteDatasource ?? CalendarRemoteDatasource();

  // ------------------- Constants -------------------

  /// SharedPreferences key prefix for per-year sync timestamps
  static const String _lastSyncPrefix = 'last_sync_';

  /// Number of years to sync (current year + next 2)
  static const int _yearsToSync = 3;

  // ------------------- Main Sync Entry Point -------------------

  /// Main sync method called on app start
  /// Checks Firebase lastUpdated timestamp before syncing each year
  /// Set [force] to true to bypass timestamp check
  Future<bool> syncHolidays({bool force = false}) async {
    try {
      debugPrint('🔄 Starting holiday sync...');

      final yearsToSync = _getYearsToSync();
      debugPrint('📅 Checking years: $yearsToSync');

      int syncedCount = 0;
      int skippedCount = 0;
      int failedCount = 0;

      for (final year in yearsToSync) {
        final result = await _syncYearIfNeeded(year, force: force);

        switch (result) {
          case _SyncResult.synced:
            syncedCount++;
            break;
          case _SyncResult.skipped:
            skippedCount++;
            break;
          case _SyncResult.failed:
            failedCount++;
            break;
        }
      }

      debugPrint(
        '✅ Sync complete → synced: $syncedCount, '
        'skipped: $skippedCount, failed: $failedCount',
      );

      // Return true if at least no complete failure
      return failedCount < yearsToSync.length;
    } catch (e) {
      debugPrint('❌ Critical error during holiday sync: $e');
      return false;
    }
  }

  // ------------------- Per-Year Sync Logic -------------------

  /// Sync a specific year only if Firebase has newer data than local cache
  Future<_SyncResult> _syncYearIfNeeded(int year, {bool force = false}) async {
    try {
      // Step 1: Get Firebase lastUpdated timestamp for this year
      final firebaseTimestamp =
          await _remoteDatasource.getLastUpdatedTimestamp(year);

      // If no document exists in Firebase for this year, skip
      if (firebaseTimestamp == null) {
        debugPrint('ℹ️ No Firebase document found for year $year — skipping');
        return _SyncResult.skipped;
      }

      // Step 2: Get local last sync timestamp for this year
      final localTimestamp = await _getLocalSyncTimestamp(year);

      // Step 3: Compare timestamps (skip if local is up to date)
      if (!force && localTimestamp != null) {
        if (!firebaseTimestamp.isAfter(localTimestamp)) {
          debugPrint('✅ Year $year already up to date — skipping sync');
          return _SyncResult.skipped;
        }
        debugPrint(
          '🔄 Firebase has newer data for $year '
          '(Firebase: $firebaseTimestamp | Local: $localTimestamp) — syncing...',
        );
      } else {
        debugPrint(
          force
              ? '🔄 Force sync requested for $year'
              : '🔄 First time sync for $year — fetching from Firebase...',
        );
      }

      // Step 4: Fetch holidays from Firebase
      final holidays = await _remoteDatasource.fetchGovtHolidays(year);

      if (holidays.isEmpty) {
        debugPrint('ℹ️ Firebase returned 0 holidays for $year — skipping save');
        return _SyncResult.skipped;
      }

      // Step 5: Save holidays to local Hive storage
      await _localDatasource.saveGovtHolidays(year, holidays);

      // Step 6: Save Firebase timestamp as local sync timestamp
      await _saveLocalSyncTimestamp(year, firebaseTimestamp);

      debugPrint(
        '✅ Year $year synced successfully — ${holidays.length} holidays saved',
      );
      return _SyncResult.synced;
    } catch (e) {
      debugPrint('❌ Error syncing year $year: $e');
      return _SyncResult.failed;
    }
  }

  // ------------------- Timestamp Management -------------------

  /// Get the locally stored sync timestamp for a specific year
  Future<DateTime?> _getLocalSyncTimestamp(int year) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_lastSyncPrefix$year';
      final millis = prefs.getInt(key);
      if (millis == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(millis);
    } catch (e) {
      debugPrint('❌ Error reading local sync timestamp for $year: $e');
      return null;
    }
  }

  /// Save the Firebase timestamp as local sync timestamp for a specific year
  Future<void> _saveLocalSyncTimestamp(int year, DateTime timestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_lastSyncPrefix$year';
      await prefs.setInt(key, timestamp.millisecondsSinceEpoch);
      debugPrint('✅ Saved sync timestamp for $year: $timestamp');
    } catch (e) {
      debugPrint('❌ Error saving local sync timestamp for $year: $e');
    }
  }

  // ------------------- Public Utility Methods -------------------

  /// Force sync a specific year regardless of timestamps
  Future<bool> forceSyncYear(int year) async {
    try {
      debugPrint('🔄 Force syncing year $year...');
      final result = await _syncYearIfNeeded(year, force: true);
      return result == _SyncResult.synced;
    } catch (e) {
      debugPrint('❌ Error force syncing year $year: $e');
      return false;
    }
  }

  /// Force sync all years regardless of timestamps
  Future<bool> forceSyncAll() async {
    return syncHolidays(force: true);
  }

  /// Get the last sync time for a specific year
  Future<DateTime?> getLastSyncTime(int year) async {
    return _getLocalSyncTimestamp(year);
  }

  /// Get sync status summary for all years
  Future<Map<int, DateTime?>> getSyncStatus() async {
    final years = _getYearsToSync();
    final Map<int, DateTime?> status = {};

    for (final year in years) {
      status[year] = await _getLocalSyncTimestamp(year);
    }

    return status;
  }

  /// Clear all sync timestamps (forces full re-sync on next app start)
  Future<void> clearSyncData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final years = _getYearsToSync();

      for (final year in years) {
        await prefs.remove('$_lastSyncPrefix$year');
      }

      debugPrint('✅ All sync timestamps cleared');
    } catch (e) {
      debugPrint('❌ Error clearing sync data: $e');
    }
  }

  /// Clear sync data AND local holidays (full reset)
  Future<void> clearAllAndReset() async {
    try {
      await clearSyncData();
      await _localDatasource.clearAllHolidays();
      debugPrint('✅ Full reset complete — all holidays and sync data cleared');
    } catch (e) {
      debugPrint('❌ Error during full reset: $e');
    }
  }

  // ------------------- Private Helpers -------------------

  /// Get list of years to sync (current year + next 2 years)
  List<int> _getYearsToSync() {
    final currentYear = DateTime.now().year;
    return List.generate(_yearsToSync, (i) => currentYear + i);
  }
}

// ------------------- Riverpod Provider -------------------

/// Provider for SyncService
/// Uses datasource providers from repositories_providers.dart
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    localDatasource: ref.watch(calendarLocalDatasourceProvider),
    remoteDatasource: ref.watch(calendarRemoteDatasourceProvider),
  );
});