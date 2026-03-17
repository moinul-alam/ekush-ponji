// lib/features/quotes/services/quotes_sync_service.dart
//
// Worker service for quotes dataset.
// Responsible ONLY for: seed, fetch from GitHub, save to Hive.
// Does NOT own scheduling logic — that belongs to DataSyncService.
//
// SYNC BEHAVIOUR:
//   • force=false → skip if interval not due OR remote version <= local
//   • force=true  → skip interval check only; version check always runs
//   • Downloads only if remote version > localVersion (always, no exceptions)

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ekush_ponji/core/models/app_manifest.dart';
import 'package:ekush_ponji/core/services/base_sync_service.dart';

class QuotesSyncService implements BaseSyncService {
  // ── Hive keys ──────────────────────────────────────────────
  static const String _settingsBoxName = 'settings';
  static const String _seededKey = 'quotes_seeded_v1';
  static const String _versionKey = 'quotes_version';
  static const String _lastCheckKey = 'quotes_last_check';

  /// Public key used by QuotesLocalDatasource to read the stored JSON.
  static const String quotesEnKey = 'quotes_en_json';

  // ── Config ─────────────────────────────────────────────────
  /// Quotes change infrequently — check every 30 days is appropriate.
  static const int _checkIntervalDays = 30;

  final Dio _dio;

  QuotesSyncService({Dio? dio}) : _dio = dio ?? Dio();

  Box get _settingsBox => Hive.box(_settingsBoxName);

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
      debugPrint('ℹ️ Quotes already seeded — skipping');
      return;
    }

    debugPrint('🌱 Seeding bundled quotes asset...');
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/quotes/quotes_en.json');

      // Validate before storing
      jsonDecode(jsonString);

      await _settingsBox.put(quotesEnKey, jsonString);
      await _settingsBox.put(_seededKey, true);
      if (localVersion == 0) {
        await _settingsBox.put(_versionKey, 1);
      }
      debugPrint('✅ Quotes seeding complete');
    } catch (e) {
      debugPrint('⚠️ Failed to seed quotes: $e');
    }
  }

  @override
  Future<bool> syncWithManifest(
    AppManifest manifest, {
    bool force = false,
  }) async {
    // Step 1 — Time interval gate (skipped when force=true)
    if (!force && !isSyncDue) {
      debugPrint('ℹ️ Quotes: sync interval not due yet — skipping');
      return false;
    }

    // Step 2 — Always record the check time so the interval resets
    await _settingsBox.put(_lastCheckKey, DateTime.now().toIso8601String());

    // Step 3 — Version gate (ALWAYS checked, even when force=true)
    final remote = manifest.quotes;
    debugPrint('📋 Quotes: remote v${remote.version} / local v$localVersion');

    if (remote.version <= localVersion) {
      debugPrint('✅ Quotes: already at latest version — no download needed');
      return false;
    }

    // Step 4 — Download
    debugPrint(
        '⬇️ Quotes: new version ${remote.version} available — downloading...');

    final url = remote.urlForLanguage('en');
    if (url == null) {
      debugPrint('⚠️ Quotes: no URL found for language "en"');
      return false;
    }

    try {
      final response = await _dio.get<String>(url);
      if (response.statusCode == 200 && response.data != null) {
        // Validate JSON before overwriting good data
        jsonDecode(response.data!);
        await _settingsBox.put(quotesEnKey, response.data);
        await _settingsBox.put(_versionKey, remote.version);
        debugPrint('✅ Quotes synced → v${remote.version}');
        return true;
      }
    } on DioException catch (e) {
      debugPrint('⚠️ Quotes: network error — ${e.message}');
    } catch (e) {
      debugPrint('⚠️ Quotes: failed to sync — $e');
    }

    return false;
  }
}
