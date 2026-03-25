// lib/features/holidays/services/holiday_sync_service.dart
//
// Worker service for holidays dataset.
// Responsible ONLY for: seed, fetch from GitHub, save to Hive.
// Does NOT own scheduling logic — that belongs to DataSyncService.
//
// SYNC BEHAVIOUR:
//   • force=false → skip if interval not due AND manifest unchanged
//   • force=true  → skip interval check only
//   • Downloads if remote dataset version increased OR manifest "stamp" changed.
//     Stamp = manifestVersion + lastUpdated + holidays.version + sorted file URLs.
//     So bumping root manifestVersion/lastUpdated in manifest.json (without
//     changing datasets.holidays.version) still triggers a refresh.

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
  static const String _manifestStampKey = 'holidays_manifest_stamp';
  static const String _govtHolidaysPrefix = 'govt_holidays_';

  // ── Config ─────────────────────────────────────────────────
  /// Background auto-sync interval. Matches DataSyncService.autoSyncIntervalDays.
  static const int _checkIntervalDays = 7;

  static const List<int> _bundledYears = [2022, 2023, 2024, 2025, 2026];

  final Dio _dio;

  HolidaySyncService({Dio? dio}) : _dio = dio ?? Dio();

  Box get _settingsBox => Hive.box(_settingsBoxName);
  Box get _holidaysBox => Hive.box(_holidaysBoxName);

  /// Fingerprint of remote manifest slice that affects holidays (not only
  /// datasets.holidays.version — includes root metadata and file set).
  static String manifestStamp(AppManifest manifest) {
    final years = manifest.holidays.files.keys.map((k) => k.toString()).toList()
      ..sort();
    final pathSig =
        years.map((y) => manifest.holidays.files[y] ?? '').join('|');
    return '${manifest.manifestVersion}|${manifest.lastUpdated}|'
        '${manifest.holidays.version}|$pathSig';
  }

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
    // Step 1 — Time interval gate (skipped when force=true)
    if (!force && !isSyncDue) {
      debugPrint('ℹ️ Holidays: sync interval not due yet — skipping');
      return false;
    }

    // Step 2 — Always record the check time so the interval resets
    await _settingsBox.put(_lastCheckKey, DateTime.now().toIso8601String());

    // Step 3 — Version + manifest stamp (checked even when force=true)
    final remote = manifest.holidays;
    final newStamp = manifestStamp(manifest);
    final oldStamp =
        _settingsBox.get(_manifestStampKey, defaultValue: '') as String;
    final versionHigher = remote.version > localVersion;
    final stampChanged = newStamp != oldStamp;

    debugPrint(
        '📋 Holidays: remote v${remote.version} / local v$localVersion '
        '| stampChanged=$stampChanged');

    if (!versionHigher && !stampChanged) {
      debugPrint(
          '✅ Holidays: version and manifest stamp unchanged — no download');
      return false;
    }

    // Step 4 — Download updated years
    if (versionHigher) {
      debugPrint(
          '⬇️ Holidays: dataset version ${remote.version} > local — downloading...');
    } else {
      debugPrint(
          '⬇️ Holidays: manifest stamp changed (e.g. lastUpdated / manifestVersion '
          '/ file list) — re-downloading...');
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
            debugPrint(
                '✅ Holidays: updated $year — ${holidays.length} entries');
          }
        }
      } on DioException catch (e) {
        debugPrint('⚠️ Holidays: network error for $year — ${e.message}');
      } catch (e) {
        debugPrint('⚠️ Holidays: failed to update $year — $e');
      }
    }

    if (updatedCount > 0) {
      await _settingsBox.put(_versionKey, remote.version);
      await _settingsBox.put(_manifestStampKey, newStamp);
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
