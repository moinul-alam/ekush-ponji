import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekush_ponji/data/datasources/local/calendar_local_datasource.dart';
import 'package:ekush_ponji/data/datasources/remote/calendar_remote_datasource.dart';

/// Service to sync holidays from Firebase to local storage
/// Handles background syncing and cache management
class SyncService {
  final CalendarLocalDatasource _localDatasource;
  final CalendarRemoteDatasource _remoteDatasource;

  SyncService({
    CalendarLocalDatasource? localDatasource,
    CalendarRemoteDatasource? remoteDatasource,
  })  : _localDatasource = localDatasource ?? CalendarLocalDatasource(),
        _remoteDatasource = remoteDatasource ?? CalendarRemoteDatasource();

  // SharedPreferences keys
  static const String _lastSyncKey = 'last_holiday_sync';
  static const String _syncYearsKey = 'synced_years';

  // Sync configuration
  static const Duration _syncInterval = Duration(days: 7); // Sync weekly
  static const int _yearsToSync = 3; // Sync current year + 2 future years

  // ------------------- Main Sync Method -------------------

  /// Sync holidays from Firebase to local storage
  /// Returns true if sync was successful
  Future<bool> syncHolidays({bool force = false}) async {
    try {
      debugPrint('🔄 Starting holiday sync...');

      // Check if sync is needed
      if (!force && !await _shouldSync()) {
        debugPrint('ℹ️ Sync not needed yet');
        return true;
      }

      // Determine which years to sync
      final yearsToSync = _getYearsToSync();
      debugPrint('📅 Syncing holidays for years: $yearsToSync');

      int successCount = 0;
      int failCount = 0;

      // Sync each year
      for (final year in yearsToSync) {
        try {
          await _syncYearHolidays(year);
          successCount++;
        } catch (e) {
          debugPrint('❌ Failed to sync year $year: $e');
          failCount++;
        }
      }

      // Update sync metadata
      if (successCount > 0) {
        await _updateSyncMetadata(yearsToSync);
        debugPrint('✅ Holiday sync completed: $successCount succeeded, $failCount failed');
        return true;
      } else {
        debugPrint('❌ Holiday sync failed for all years');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error during holiday sync: $e');
      return false;
    }
  }

  /// Sync holidays for a specific year
  Future<void> _syncYearHolidays(int year) async {
    // Fetch from Firebase
    final remoteHolidays = await _remoteDatasource.fetchGovtHolidays(year);

    if (remoteHolidays.isEmpty) {
      debugPrint('ℹ️ No holidays found in Firebase for $year');
      return;
    }

    // Save to local storage
    await _localDatasource.saveGovtHolidays(year, remoteHolidays);
    debugPrint('✅ Synced ${remoteHolidays.length} holidays for $year');
  }

  // ------------------- Sync Logic Helpers -------------------

  /// Check if sync should run
  Future<bool> _shouldSync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncMillis = prefs.getInt(_lastSyncKey);

    if (lastSyncMillis == null) {
      debugPrint('ℹ️ No previous sync found');
      return true; // First time sync
    }

    final lastSync = DateTime.fromMillisecondsSinceEpoch(lastSyncMillis);
    final timeSinceSync = DateTime.now().difference(lastSync);

    debugPrint('ℹ️ Last sync was ${timeSinceSync.inDays} days ago');
    return timeSinceSync > _syncInterval;
  }

  /// Get list of years to sync
  List<int> _getYearsToSync() {
    final currentYear = DateTime.now().year;
    return List.generate(_yearsToSync, (i) => currentYear + i);
  }

  /// Update sync metadata after successful sync
  Future<void> _updateSyncMetadata(List<int> syncedYears) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save last sync timestamp
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    
    // Save synced years
    await prefs.setStringList(
      _syncYearsKey,
      syncedYears.map((y) => y.toString()).toList(),
    );

    debugPrint('✅ Sync metadata updated');
  }

  // ------------------- Public Helper Methods -------------------

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncMillis = prefs.getInt(_lastSyncKey);
    
    if (lastSyncMillis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(lastSyncMillis);
  }

  /// Get synced years
  Future<List<int>> getSyncedYears() async {
    final prefs = await SharedPreferences.getInstance();
    final yearStrings = prefs.getStringList(_syncYearsKey);
    
    if (yearStrings == null) return [];
    return yearStrings.map((s) => int.parse(s)).toList();
  }

  /// Force sync specific years
  Future<bool> syncSpecificYears(List<int> years) async {
    try {
      for (final year in years) {
        await _syncYearHolidays(year);
      }
      await _updateSyncMetadata(years);
      return true;
    } catch (e) {
      debugPrint('❌ Error syncing specific years: $e');
      return false;
    }
  }

  /// Clear sync data (for testing/reset)
  Future<void> clearSyncData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSyncKey);
    await prefs.remove(_syncYearsKey);
    debugPrint('✅ Sync data cleared');
  }
}