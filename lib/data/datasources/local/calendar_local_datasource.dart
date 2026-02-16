import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';

/// Local datasource for calendar data using Hive
/// Handles all local storage operations for holidays
class CalendarLocalDatasource {
  static const String _holidaysBoxName = 'holidays';
  
  // Box keys
  static const String _govtHolidaysPrefix = 'govt_holidays_';
  static const String _customHolidaysKey = 'custom_holidays';
  static const String _modifiedHolidaysKey = 'modified_holidays';
  static const String _hiddenHolidayIdsKey = 'hidden_holiday_ids';

  /// Get Hive box
  Box get _box => Hive.box(_holidaysBoxName);

  // ------------------- Government Holidays (from Firebase) -------------------

  /// Save government holidays for a specific year
  Future<void> saveGovtHolidays(int year, List<Holiday> holidays) async {
    try {
      final key = '$_govtHolidaysPrefix$year';
      final jsonList = holidays.map((h) => h.toJson()).toList();
      await _box.put(key, jsonList);
      debugPrint('✅ Saved ${holidays.length} govt holidays for $year');
    } catch (e) {
      debugPrint('❌ Error saving govt holidays: $e');
      rethrow;
    }
  }

  /// Get government holidays for a specific year
  Future<List<Holiday>> getGovtHolidays(int year) async {
    try {
      final key = '$_govtHolidaysPrefix$year';
      final jsonList = _box.get(key) as List<dynamic>?;
      
      if (jsonList == null) {
        debugPrint('ℹ️ No govt holidays found for $year');
        return [];
      }

      final holidays = jsonList
          .map((json) => Holiday.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      
      debugPrint('✅ Retrieved ${holidays.length} govt holidays for $year');
      return holidays;
    } catch (e) {
      debugPrint('❌ Error getting govt holidays: $e');
      return [];
    }
  }

  /// Check if government holidays exist for a year
  Future<bool> hasGovtHolidays(int year) async {
    final key = '$_govtHolidaysPrefix$year';
    return _box.containsKey(key);
  }

  /// Delete government holidays for a year (for re-sync)
  Future<void> deleteGovtHolidays(int year) async {
    final key = '$_govtHolidaysPrefix$year';
    await _box.delete(key);
    debugPrint('✅ Deleted govt holidays for $year');
  }

  // ------------------- Custom Holidays (user-added) -------------------

  /// Save custom holidays (user-created)
  Future<void> saveCustomHolidays(List<Holiday> holidays) async {
    try {
      final jsonList = holidays.map((h) => h.toJson()).toList();
      await _box.put(_customHolidaysKey, jsonList);
      debugPrint('✅ Saved ${holidays.length} custom holidays');
    } catch (e) {
      debugPrint('❌ Error saving custom holidays: $e');
      rethrow;
    }
  }

  /// Get all custom holidays
  Future<List<Holiday>> getCustomHolidays() async {
    try {
      final jsonList = _box.get(_customHolidaysKey) as List<dynamic>?;
      
      if (jsonList == null) return [];

      return jsonList
          .map((json) => Holiday.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting custom holidays: $e');
      return [];
    }
  }

  /// Add a single custom holiday
  Future<void> addCustomHoliday(Holiday holiday) async {
    final existing = await getCustomHolidays();
    existing.add(holiday);
    await saveCustomHolidays(existing);
    debugPrint('✅ Added custom holiday: ${holiday.name}');
  }

  /// Delete a custom holiday by ID
  Future<void> deleteCustomHoliday(String id) async {
    final existing = await getCustomHolidays();
    existing.removeWhere((h) => h.id == id);
    await saveCustomHolidays(existing);
    debugPrint('✅ Deleted custom holiday: $id');
  }

  // ------------------- Modified Holidays (user-edited govt holidays) -------------------

  /// Save modified holidays (user edits of govt holidays)
  Future<void> saveModifiedHolidays(List<Holiday> holidays) async {
    try {
      final jsonList = holidays.map((h) => h.toJson()).toList();
      await _box.put(_modifiedHolidaysKey, jsonList);
      debugPrint('✅ Saved ${holidays.length} modified holidays');
    } catch (e) {
      debugPrint('❌ Error saving modified holidays: $e');
      rethrow;
    }
  }

  /// Get modified holidays
  Future<List<Holiday>> getModifiedHolidays() async {
    try {
      final jsonList = _box.get(_modifiedHolidaysKey) as List<dynamic>?;
      
      if (jsonList == null) return [];

      return jsonList
          .map((json) => Holiday.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting modified holidays: $e');
      return [];
    }
  }

  /// Add/update a modified holiday
  Future<void> saveModifiedHoliday(Holiday holiday) async {
    final existing = await getModifiedHolidays();
    existing.removeWhere((h) => h.id == holiday.id);
    existing.add(holiday);
    await saveModifiedHolidays(existing);
    debugPrint('✅ Saved modified holiday: ${holiday.name}');
  }

  // ------------------- Hidden Holidays -------------------

  /// Save list of hidden holiday IDs
  Future<void> saveHiddenHolidayIds(List<String> ids) async {
    await _box.put(_hiddenHolidayIdsKey, ids);
    debugPrint('✅ Saved ${ids.length} hidden holiday IDs');
  }

  /// Get hidden holiday IDs
  Future<List<String>> getHiddenHolidayIds() async {
    final ids = _box.get(_hiddenHolidayIdsKey) as List<dynamic>?;
    return ids?.cast<String>() ?? [];
  }

  /// Hide a holiday
  Future<void> hideHoliday(String id) async {
    final existing = await getHiddenHolidayIds();
    if (!existing.contains(id)) {
      existing.add(id);
      await saveHiddenHolidayIds(existing);
      debugPrint('✅ Hidden holiday: $id');
    }
  }

  /// Unhide a holiday
  Future<void> unhideHoliday(String id) async {
    final existing = await getHiddenHolidayIds();
    existing.remove(id);
    await saveHiddenHolidayIds(existing);
    debugPrint('✅ Unhidden holiday: $id');
  }

  // ------------------- Utility Methods -------------------

  /// Clear all holiday data (for testing/reset)
  Future<void> clearAllHolidays() async {
    await _box.clear();
    debugPrint('✅ Cleared all holiday data');
  }

  /// Get all holidays for a specific year (merged: govt + custom + modified)
  Future<List<Holiday>> getAllHolidaysForYear(int year) async {
    final govtHolidays = await getGovtHolidays(year);
    final customHolidays = await getCustomHolidays();
    final modifiedHolidays = await getModifiedHolidays();
    final hiddenIds = await getHiddenHolidayIds();

    // Filter custom holidays for this year
    final customForYear = customHolidays
        .where((h) => h.date.year == year)
        .toList();

    // Create a map of modified holidays by ID for quick lookup
    final modifiedMap = {for (var h in modifiedHolidays) h.id: h};

    // Merge: govt holidays (replace with modified if exists) + custom
    final mergedHolidays = <Holiday>[];

    // Add govt holidays (or their modified versions)
    for (final holiday in govtHolidays) {
      if (hiddenIds.contains(holiday.id)) continue; // Skip hidden
      
      // Use modified version if exists, otherwise use original
      final finalHoliday = modifiedMap[holiday.id] ?? holiday;
      mergedHolidays.add(finalHoliday);
    }

    // Add custom holidays
    for (final holiday in customForYear) {
      if (!hiddenIds.contains(holiday.id)) {
        mergedHolidays.add(holiday);
      }
    }

    // Sort by date
    mergedHolidays.sort((a, b) => a.date.compareTo(b.date));

    return mergedHolidays;
  }
}