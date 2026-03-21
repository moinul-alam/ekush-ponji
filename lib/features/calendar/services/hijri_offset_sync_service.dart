// lib/features/calendar/services/hijri_offset_sync_service.dart
//
// Fetches and caches per-year Hijri date correction offsets from GitHub.
//
// SYNC INTERVAL:
//   Fetches at most once every 7 days (same interval as main manifest sync).
//   Always runs on force sync from Settings.
//   Checks current year + next year files each time.
//
// OFFSET RULES:
//   Each entry covers one Hijri month (uq_start → uq_end, inclusive).
//   offset=-1: BD starts month 1 day later than Umm al-Qura (Saudi).
//   offset=-2: BD starts month 2 days later (rare cumulative slip).
//   offset=0 / no match: UQ date used as-is.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HijriOffsetSyncService {
  static const String _settingsBoxName = 'settings';
  static const String _baseUrl =
      'https://raw.githubusercontent.com/moinul-alam/ekush_ponji/main/assets/data';

  // ── Interval (matches main manifest sync) ─────────────────────────────────
  static const int _checkIntervalDays = 7;
  static const String _lastCheckKey = 'hijri_offsets_last_check';

  // ── Hive key helpers ───────────────────────────────────────────────────────

  static String _jsonKey(int year) => 'hijri_offsets_json_$year';
  static String _versionKey(int year) => 'hijri_offsets_version_$year';

  final Dio _dio;

  HijriOffsetSyncService({Dio? dio}) : _dio = dio ?? Dio();

  Box get _box => Hive.box(_settingsBoxName);

  int _localVersion(int year) =>
      _box.get(_versionKey(year), defaultValue: 0) as int;

  // ── Interval check ─────────────────────────────────────────────────────────

  bool get isSyncDue {
    final lastCheckStr = _box.get(_lastCheckKey, defaultValue: null) as String?;
    if (lastCheckStr == null) return true;
    final lastCheck = DateTime.tryParse(lastCheckStr);
    if (lastCheck == null) return true;
    return DateTime.now().difference(lastCheck).inDays >= _checkIntervalDays;
  }

  Future<void> _recordCheck() async {
    await _box.put(_lastCheckKey, DateTime.now().toIso8601String());
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Fetch offsets for current year and next year.
  /// Called during background init on every app launch, but only hits
  /// the network if the 7-day interval has passed.
  /// Pass [force] = true to skip the interval check (Settings force sync).
  Future<void> syncAll({bool force = false}) async {
    if (!force && !isSyncDue) {
      debugPrint('ℹ️ HijriOffsetSync: interval not due — skipping');
      return;
    }

    await _recordCheck();

    final currentYear = DateTime.now().year;
    await Future.wait([
      _syncYear(currentYear),
      _syncYear(currentYear + 1),
    ]);
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<void> _syncYear(int year) async {
    final url = '$_baseUrl/hijri/$year.json';
    try {
      debugPrint('🌙 HijriOffsetSync: fetching $year from $url');

      final response = await _dio.get<dynamic>(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
          responseType: ResponseType.plain,
        ),
      );

      if (response.statusCode != 200 || response.data == null) {
        debugPrint(
            '⚠️ HijriOffsetSync: unexpected status for $year: ${response.statusCode}');
        return;
      }

      final rawString = response.data.toString();
      if (rawString.trim().isEmpty) {
        debugPrint('⚠️ HijriOffsetSync: empty response for $year');
        return;
      }

      // Validate JSON and check version before storing
      final parsed = jsonDecode(rawString) as Map<String, dynamic>;
      final remoteVersion = parsed['version'] as int? ?? 0;
      final localVer = _localVersion(year);

      if (remoteVersion <= localVer) {
        debugPrint(
            'ℹ️ HijriOffsetSync: $year already at v$remoteVersion — skipping');
        return;
      }

      await _box.put(_jsonKey(year), rawString);
      await _box.put(_versionKey(year), remoteVersion);
      debugPrint('✅ HijriOffsetSync: $year updated to v$remoteVersion');
    } on DioException catch (e) {
      // 404 = file not yet created for that year — silent, not an error
      if (e.response?.statusCode == 404) {
        debugPrint('ℹ️ HijriOffsetSync: no file for $year yet (404)');
      } else {
        debugPrint(
            '⚠️ HijriOffsetSync: network error for $year — ${e.message}');
      }
    } catch (e) {
      debugPrint('⚠️ HijriOffsetSync: error for $year — $e');
    }
  }

  // ── Static helper used by HijriCalendarService ─────────────────────────────

  /// Returns the offset (in days) to add to a UQ-computed Hijri date
  /// for the given Gregorian [date]. Returns 0 if no rule matches.
  ///
  /// Reads directly from Hive — synchronous and fast (in-memory after open).
  static int getOffsetForDate(DateTime date) {
    final year = date.year;
    for (final y in [year, year + 1, year - 1]) {
      final offset = _getOffsetFromYear(date, y);
      if (offset != 0) return offset;
    }
    for (final y in [year, year + 1, year - 1]) {
      if (_hasMatchingRule(date, y)) return 0;
    }
    return 0;
  }

  static int _getOffsetFromYear(DateTime date, int year) {
    try {
      final box = Hive.box('settings');
      final raw = box.get(_jsonKey(year)) as String?;
      if (raw == null) return 0;

      final parsed = jsonDecode(raw) as Map<String, dynamic>;
      final months = parsed['months'] as List<dynamic>? ?? [];

      final target = DateTime(date.year, date.month, date.day);

      for (final entry in months) {
        final fromStr = entry['uq_start'] as String?;
        final toStr = entry['uq_end'] as String?;
        final offset = entry['offset'] as int?;
        if (fromStr == null || toStr == null || offset == null) continue;

        final from = DateTime.parse(fromStr);
        final to = DateTime.parse(toStr);

        if (!target.isBefore(from) && !target.isAfter(to)) {
          if (offset != 0) {
            debugPrint(
                '🌙 HijriOffset: applying $offset for ${target.toIso8601String()} '
                '(${entry['hijri_month']} ${entry['hijri_month_name']})');
          }
          return offset;
        }
      }
    } catch (e) {
      debugPrint('⚠️ HijriOffsetSync.getOffsetForDate error (year=$year): $e');
    }
    return 0;
  }

  static bool _hasMatchingRule(DateTime date, int year) {
    try {
      final box = Hive.box('settings');
      final raw = box.get(_jsonKey(year)) as String?;
      if (raw == null) return false;

      final parsed = jsonDecode(raw) as Map<String, dynamic>;
      final months = parsed['months'] as List<dynamic>? ?? [];

      final target = DateTime(date.year, date.month, date.day);

      for (final entry in months) {
        final fromStr = entry['uq_start'] as String?;
        final toStr = entry['uq_end'] as String?;
        if (fromStr == null || toStr == null) continue;
        final from = DateTime.parse(fromStr);
        final to = DateTime.parse(toStr);
        if (!target.isBefore(from) && !target.isAfter(to)) return true;
      }
    } catch (_) {}
    return false;
  }
}
