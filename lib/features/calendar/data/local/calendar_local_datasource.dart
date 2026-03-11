import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';

/// Local datasource for calendar data using Hive
/// Handles all local storage operations for holidays
class CalendarLocalDatasource {
  static const String _holidaysBoxName = 'holidays';

  // Box keys
  static const String _govtHolidaysPrefix = 'govt_holidays_';
  static const String _customHolidaysKey = 'custom_holidays';
  static const String _modifiedHolidaysKey = 'modified_holidays';
  static const String _hiddenHolidayIdsKey = 'hidden_holiday_ids';
  static const String _lastUpdatedPrefix = 'last_updated_';

  /// Get Hive box
  Box get _box => Hive.box(_holidaysBoxName);

  // ------------------- Government Holidays (from Firebase) -------------------

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

  Future<bool> hasGovtHolidays(int year) async {
    final key = '$_govtHolidaysPrefix$year';
    return _box.containsKey(key);
  }

  Future<void> deleteGovtHolidays(int year) async {
    final key = '$_govtHolidaysPrefix$year';
    await _box.delete(key);
    debugPrint('✅ Deleted govt holidays for $year');
  }

  // ------------------- Last Updated (for sync) -------------------

  /// Save Firestore lastUpdated timestamp locally for a year
  Future<void> saveLastUpdated(int year, DateTime timestamp) async {
    final key = '$_lastUpdatedPrefix$year';
    await _box.put(key, timestamp.toIso8601String());
    debugPrint('✅ Saved lastUpdated for $year: $timestamp');
  }

  /// Get locally stored lastUpdated timestamp for a year
  /// Returns null if never synced
  Future<DateTime?> getLastUpdated(int year) async {
    final key = '$_lastUpdatedPrefix$year';
    final value = _box.get(key) as String?;
    if (value == null) return null;
    return DateTime.parse(value);
  }

  // ------------------- Custom Holidays -------------------

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

  Future<void> addCustomHoliday(Holiday holiday) async {
    final existing = await getCustomHolidays();
    existing.add(holiday);
    await saveCustomHolidays(existing);
    debugPrint('✅ Added custom holiday: ${holiday.name}');
  }

  Future<void> deleteCustomHoliday(String id) async {
    final existing = await getCustomHolidays();
    existing.removeWhere((h) => h.id == id);
    await saveCustomHolidays(existing);
    debugPrint('✅ Deleted custom holiday: $id');
  }

  // ------------------- Modified Holidays -------------------

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

  Future<void> saveModifiedHoliday(Holiday holiday) async {
    final existing = await getModifiedHolidays();
    existing.removeWhere((h) => h.id == holiday.id);
    existing.add(holiday);
    await saveModifiedHolidays(existing);
    debugPrint('✅ Saved modified holiday: ${holiday.name}');
  }

  // ------------------- Hidden Holidays -------------------

  Future<void> saveHiddenHolidayIds(List<String> ids) async {
    await _box.put(_hiddenHolidayIdsKey, ids);
    debugPrint('✅ Saved ${ids.length} hidden holiday IDs');
  }

  Future<List<String>> getHiddenHolidayIds() async {
    final ids = _box.get(_hiddenHolidayIdsKey) as List<dynamic>?;
    return ids?.cast<String>() ?? [];
  }

  Future<void> hideHoliday(String id) async {
    final existing = await getHiddenHolidayIds();
    if (!existing.contains(id)) {
      existing.add(id);
      await saveHiddenHolidayIds(existing);
      debugPrint('✅ Hidden holiday: $id');
    }
  }

  Future<void> unhideHoliday(String id) async {
    final existing = await getHiddenHolidayIds();
    existing.remove(id);
    await saveHiddenHolidayIds(existing);
    debugPrint('✅ Unhidden holiday: $id');
  }

  // ------------------- Utility -------------------

  Future<void> clearAllHolidays() async {
    await _box.clear();
    debugPrint('✅ Cleared all holiday data');
  }

  /// Get all holidays for a year — merged: govt + custom + modified
  Future<List<Holiday>> getAllHolidaysForYear(int year) async {
    final govtHolidays = await getGovtHolidays(year);
    final customHolidays = await getCustomHolidays();
    final modifiedHolidays = await getModifiedHolidays();
    final hiddenIds = await getHiddenHolidayIds();

    final customForYear = customHolidays
        .where((h) =>
            h.startDate.year == year ||
            (h.endDate != null && h.endDate!.year == year))
        .toList();

    final modifiedMap = {for (var h in modifiedHolidays) h.id: h};

    final mergedHolidays = <Holiday>[];

    for (final holiday in govtHolidays) {
      if (hiddenIds.contains(holiday.id)) continue;
      final finalHoliday = modifiedMap[holiday.id] ?? holiday;
      mergedHolidays.add(finalHoliday);
    }

    for (final holiday in customForYear) {
      if (!hiddenIds.contains(holiday.id)) {
        mergedHolidays.add(holiday);
      }
    }

    mergedHolidays.sort((a, b) => a.startDate.compareTo(b.startDate));
    return mergedHolidays;
  }
}
