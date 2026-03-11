// lib/features/holidays/services/holiday_sync_service.dart

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ekush_ponji/core/models/app_manifest.dart';
import 'package:ekush_ponji/core/services/base_sync_service.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';

class HolidaySyncService implements BaseSyncService {
  // ── Hive keys ──────────────────────────────────────────────
  static const String _settingsBoxName = 'settings';
  static const String _holidaysBoxName = 'holidays';
  static const String _seededKey = 'holidays_seeded_v1';
  static const String _versionKey = 'holidays_version';
  static const String _lastCheckKey = 'holidays_last_check';
  static const String _govtHolidaysPrefix = 'govt_holidays_';

  // ── Config ─────────────────────────────────────────────────
  static const int _checkIntervalDays = 3;
  static const List<int> _bundledYears = [2022, 2023, 2024, 2025, 2026];

  final Dio _dio;

  HolidaySyncService({Dio? dio}) : _dio = dio ?? Dio();

  Box get _settingsBox => Hive.box(_settingsBoxName);
  Box get _holidaysBox => Hive.box(_holidaysBoxName);

  // ── BaseSyncService contract ───────────────────────────────

  @override
  int get localVersion => _settingsBox.get(_versionKey, defaultValue: 0) as int;

  @override
  bool get isSyncDue {
    final lastCheckStr =
        _settingsBox.get(_lastCheckKey, defaultValue: null) as String?;
    if (lastCheckStr == null) return true;
    final lastCheck = DateTime.tryParse(lastCheckStr);
    if (lastCheck == null) return true;
    return DateTime.now().difference(lastCheck).inDays >= _checkIntervalDays;
  }

  @override
  Future<void> seed() async {
    final seeded = _settingsBox.get(_seededKey, defaultValue: false) as bool;
    if (seeded) {
      debugPrint('ℹ️ Holidays already seeded — skipping');
      return;
    }

    debugPrint('🌱 Seeding bundled holiday assets...');
    int count = 0;

    for (final year in _bundledYears) {
      try {
        final jsonString = await rootBundle
            .loadString('assets/data/holidays/holidays_$year.json');
        final holidays = _parseHolidayJson(jsonString);
        if (holidays.isNotEmpty) {
          await _saveToHive(year, holidays);
          count++;
          debugPrint('✅ Seeded holidays $year: ${holidays.length} entries');
        }
      } catch (e) {
        debugPrint('⚠️ Failed to seed holidays $year: $e');
      }
    }

    if (count > 0) {
      await _settingsBox.put(_seededKey, true);
      if (localVersion == 0) {
        await _settingsBox.put(_versionKey, 1);
      }
      debugPrint('✅ Holiday seeding complete: $count years loaded');
    } else {
      debugPrint('⚠️ Holiday seeding failed — no years loaded');
    }
  }

  @override
  Future<bool> syncWithManifest(
    AppManifest manifest, {
    bool force = false,
  }) async {
    if (!force && !isSyncDue) {
      debugPrint('ℹ️ Holiday sync not due yet');
      return false;
    }

    await _settingsBox.put(_lastCheckKey, DateTime.now().toIso8601String());

    final remote = manifest.holidays;
    debugPrint('📋 Holidays: remote v${remote.version} / local v$localVersion');

    if (!force && remote.version <= localVersion) {
      debugPrint('✅ Holidays up to date');
      return false;
    }

    int updatedCount = 0;
    for (final year in remote.availableYears) {
      final url = remote.urlForYear(year);
      if (url == null) continue;

      try {
        final response = await _dio.get<String>(url);
        if (response.statusCode == 200 && response.data != null) {
          final holidays = _parseHolidayJson(response.data!);
          if (holidays.isNotEmpty) {
            await _saveToHive(year, holidays);
            updatedCount++;
            debugPrint('✅ Updated holidays $year: ${holidays.length} entries');
          }
        }
      } on DioException catch (e) {
        debugPrint('⚠️ Network error for holidays $year: ${e.message}');
      } catch (e) {
        debugPrint('⚠️ Failed to update holidays $year: $e');
      }
    }

    if (updatedCount > 0) {
      await _settingsBox.put(_versionKey, remote.version);
      debugPrint(
          '✅ Holidays sync complete: $updatedCount years → v${remote.version}');
      return true;
    }

    return false;
  }

  // ── Private helpers ────────────────────────────────────────

  List<Holiday> _parseHolidayJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final list = data['holidays'] as List<dynamic>;
    return list
        .map((h) => Holiday.fromJson(h as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveToHive(int year, List<Holiday> holidays) async {
    final key = '$_govtHolidaysPrefix$year';
    final jsonList = holidays.map((h) => h.toJson()).toList();
    await _holidaysBox.put(key, jsonList);
  }
}
