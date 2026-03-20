// lib/features/calendar/services/hijri_offset_sync_service.dart
//
// Fetches and caches Hijri date correction offsets from GitHub.
//
// WHY THIS EXISTS:
//   The Hijri lookup table uses Umm al-Qura (Saudi Arabia) dates.
//   Bangladesh determines Hijri dates by actual moon sighting, which can
//   differ by ±1 day. This service fetches a tiny override file from GitHub
//   so corrections can be pushed without an app update.
//
// SYNC STRATEGY:
//   Always fetches on every app launch (no interval gate) because:
//   - The file is tiny (~200 bytes)
//   - Hijri corrections are time-sensitive (same-day or next-day urgency)
//   - Fetch is non-blocking (background phase after first frame)
//
// OFFSET RULES:
//   Each rule has a date range [from, to] and an integer offset (±days).
//   Example: offset=-1 means "subtract 1 day from the computed Hijri date"
//   for all Gregorian dates in [from, to].
//
// HIVE STORAGE:
//   Stored in the 'settings' box under key 'hijri_offsets_json'.
//   HijriCalendarService reads from this key on every getHijriDate() call.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HijriOffsetSyncService {
  static const String _settingsBoxName = 'settings';
  static const String _offsetsKey = 'hijri_offsets_json';
  static const String _versionKey = 'hijri_offsets_version';

  /// Public key — read by HijriCalendarService to apply offsets.
  static const String offsetsStorageKey = _offsetsKey;

  final Dio _dio;

  HijriOffsetSyncService({Dio? dio}) : _dio = dio ?? Dio();

  Box get _box => Hive.box(_settingsBoxName);

  int get _localVersion => _box.get(_versionKey, defaultValue: 0) as int;

  // ── Public API ─────────────────────────────────────────

  /// Fetch the latest Hijri offsets from [url] and store them in Hive.
  ///
  /// Always called on app launch regardless of any interval.
  /// Silently no-ops if offline or server returns an error.
  /// Only overwrites local data if remote version > local version.
  Future<void> syncFromUrl(String url) async {
    try {
      debugPrint('🌙 HijriOffsetSync: fetching from $url');

      final response = await _dio.get<String>(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );

      if (response.statusCode != 200 || response.data == null) {
        debugPrint(
            '⚠️ HijriOffsetSync: unexpected status ${response.statusCode}');
        return;
      }

      // Validate JSON before storing
      final parsed = jsonDecode(response.data!) as Map<String, dynamic>;
      final remoteVersion = parsed['version'] as int? ?? 0;

      if (remoteVersion <= _localVersion) {
        debugPrint(
          'ℹ️ HijriOffsetSync: already at v$remoteVersion (local v$_localVersion) — skipping',
        );
        return;
      }

      await _box.put(_offsetsKey, response.data);
      await _box.put(_versionKey, remoteVersion);
      debugPrint('✅ HijriOffsetSync: updated to v$remoteVersion');
    } on DioException catch (e) {
      debugPrint('⚠️ HijriOffsetSync: network error — ${e.message}');
    } catch (e) {
      debugPrint('⚠️ HijriOffsetSync: error — $e');
    }
  }

  // ── Static helper used by HijriCalendarService ─────────

  /// Returns the offset (in days) to apply to a computed Hijri date
  /// for the given Gregorian [date]. Returns 0 if no rule matches.
  ///
  /// Reads directly from Hive — synchronous, safe to call on every
  /// getHijriDate() call because Hive reads are in-memory after open.
  static int getOffsetForDate(DateTime date) {
    try {
      final box = Hive.box('settings');
      final raw = box.get(offsetsStorageKey) as String?;
      if (raw == null) return 0;

      final parsed = jsonDecode(raw) as Map<String, dynamic>;
      final offsets = parsed['offsets'] as List<dynamic>? ?? [];

      final target = DateTime(date.year, date.month, date.day);

      for (final rule in offsets) {
        final from = DateTime.parse(rule['from'] as String);
        final to = DateTime.parse(rule['to'] as String);
        final offset = rule['offset'] as int? ?? 0;

        if (!target.isBefore(from) && !target.isAfter(to)) {
          debugPrint(
            '🌙 HijriOffset: applying $offset for ${target.toIso8601String()}',
          );
          return offset;
        }
      }
    } catch (e) {
      debugPrint('⚠️ HijriOffsetSync.getOffsetForDate error: $e');
    }
    return 0;
  }
}
