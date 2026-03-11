import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/core/models/holiday_manifest.dart';

class HolidaySyncService {
  static const String _manifestUrl =
      'https://raw.githubusercontent.com/moinul-alam/ekush-ponji-data/main/manifest.json';

  static const String _boxName = 'settings';
  static const String _seededKey = 'holidays_seeded_v1';
  static const String _localVersionKey = 'holidays_version';
  static const String _lastCheckKey = 'holidays_last_check';
  static const String _holidaysBoxName = 'holidays';
  static const String _govtHolidaysPrefix = 'govt_holidays_';
  static const int _checkIntervalDays = 3;
  static const List<int> _bundledYears = [2022, 2023, 2024, 2025, 2026];

  final Dio _dio;

  HolidaySyncService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
            ));

  Box get _settingsBox => Hive.box(_boxName);
  Box get _holidaysBox => Hive.box(_holidaysBoxName);

  int get localVersion =>
      _settingsBox.get(_localVersionKey, defaultValue: 0) as int;

  bool get isSeeded =>
      _settingsBox.get(_seededKey, defaultValue: false) as bool;

  Future<void> initialize() async {
    await _seedBundledAssetsIfNeeded();
    await _syncFromGitHubIfDue();
  }

  Future<bool> forceSync() async {
    return await _syncFromGitHub(force: true);
  }

  Future<void> _seedBundledAssetsIfNeeded() async {
    if (isSeeded) {
      debugPrint('ℹ️ Holiday seed already done — skipping');
      return;
    }

    debugPrint('🌱 Seeding bundled holiday assets...');
    int seededCount = 0;

    for (final year in _bundledYears) {
      try {
        final holidays = await _loadFromAsset(year);
        if (holidays.isNotEmpty) {
          await _saveHolidaysToHive(year, holidays);
          seededCount++;
          debugPrint('✅ Seeded $year: ${holidays.length} holidays');
        }
      } catch (e) {
        debugPrint('⚠️ Failed to seed $year from asset: $e');
      }
    }

    if (seededCount > 0) {
      await _settingsBox.put(_seededKey, true);
      if (localVersion == 0) {
        await _settingsBox.put(_localVersionKey, 1);
      }
      debugPrint('✅ Seeding complete: $seededCount years loaded');
    } else {
      debugPrint('⚠️ No years could be seeded — app may have no holiday data');
    }
  }

  Future<void> _syncFromGitHubIfDue() async {
    if (!_isSyncDue()) {
      debugPrint('ℹ️ Holiday sync not due yet — skipping');
      return;
    }
    await _syncFromGitHub();
  }

  bool _isSyncDue() {
    final lastCheckStr =
        _settingsBox.get(_lastCheckKey, defaultValue: null) as String?;
    if (lastCheckStr == null) return true;
    final lastCheck = DateTime.tryParse(lastCheckStr);
    if (lastCheck == null) return true;
    return DateTime.now().difference(lastCheck).inDays >= _checkIntervalDays;
  }

  Future<bool> _syncFromGitHub({bool force = false}) async {
    debugPrint('🔄 Checking GitHub for holiday updates...');

    await _settingsBox.put(_lastCheckKey, DateTime.now().toIso8601String());

    try {
      final manifest = await _fetchManifest();
      if (manifest == null) return false;

      debugPrint(
          '📋 Manifest: remote v${manifest.holidaysVersion} / local v$localVersion');

      if (!force && manifest.holidaysVersion <= localVersion) {
        debugPrint('✅ Holiday data is up to date');
        return false;
      }

      debugPrint(
          '🆕 Fetching holiday data (v${manifest.holidaysVersion})...');

      int updatedCount = 0;
      for (final year in manifest.availableYears) {
        final url = manifest.urlForYear(year);
        if (url == null) continue;

        try {
          final holidays = await _fetchHolidaysFromUrl(url);
          if (holidays.isNotEmpty) {
            await _saveHolidaysToHive(year, holidays);
            updatedCount++;
            debugPrint('✅ Updated $year: ${holidays.length} holidays');
          }
        } catch (e) {
          debugPrint('⚠️ Failed to update year $year: $e');
        }
      }

      if (updatedCount > 0) {
        await _settingsBox.put(_localVersionKey, manifest.holidaysVersion);
        debugPrint(
            '✅ Sync complete: $updatedCount years updated to v${manifest.holidaysVersion}');
        return true;
      }

      return false;
    } on DioException catch (e) {
      debugPrint('⚠️ GitHub sync failed (network): ${e.message}');
      return false;
    } catch (e) {
      debugPrint('⚠️ GitHub sync failed: $e');
      return false;
    }
  }

  Future<HolidayManifest?> _fetchManifest() async {
    try {
      final response = await _dio.get<String>(_manifestUrl);
      if (response.statusCode != 200 || response.data == null) return null;
      final json = jsonDecode(response.data!) as Map<String, dynamic>;
      return HolidayManifest.fromJson(json);
    } catch (e) {
      debugPrint('⚠️ Failed to fetch manifest: $e');
      return null;
    }
  }

  Future<List<Holiday>> _fetchHolidaysFromUrl(String url) async {
    final response = await _dio.get<String>(url);
    if (response.statusCode != 200 || response.data == null) return [];
    return _parseHolidayJson(response.data!);
  }

  Future<List<Holiday>> _loadFromAsset(int year) async {
    final jsonString =
        await rootBundle.loadString('assets/data/holidays_$year.json');
    return _parseHolidayJson(jsonString);
  }

  List<Holiday> _parseHolidayJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final list = data['holidays'] as List<dynamic>;
    return list
        .map((h) => Holiday.fromJson(h as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveHolidaysToHive(int year, List<Holiday> holidays) async {
    final key = '$_govtHolidaysPrefix$year';
    final jsonList = holidays.map((h) => h.toJson()).toList();
    await _holidaysBox.put(key, jsonList);
  }
}