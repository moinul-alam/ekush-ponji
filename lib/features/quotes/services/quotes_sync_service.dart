// lib/features/quotes/services/quotes_sync_service.dart
//
// Worker service for quotes dataset.
// Responsible ONLY for: seed, fetch from GitHub, save to Hive.
// Does NOT own scheduling logic — that belongs to DataSyncService.
//
// SYNC BEHAVIOUR:
//   • force=false → skip if interval not due AND manifest unchanged
//   • force=true  → skip interval check only
//   • Downloads if dataset version increased OR manifest stamp changed
//     (root manifestVersion / lastUpdated / file URLs / quotes.version).

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
  static const String _manifestStampKey = 'quotes_manifest_stamp';

  /// Public key used by QuotesLocalDatasource to read the stored JSON.
  static const String quotesEnKey = 'quotes_en_json';

  // ── Config ─────────────────────────────────────────────────
  /// Quotes change infrequently — check every 30 days is appropriate.
  static const int _checkIntervalDays = 30;

  final Dio _dio;

  QuotesSyncService({Dio? dio}) : _dio = dio ?? Dio();

  Box get _settingsBox => Hive.box(_settingsBoxName);

  static String manifestStamp(AppManifest manifest) {
    final langs = manifest.quotes.files.keys.map((k) => k.toString()).toList()
      ..sort();
    final pathSig =
        langs.map((lang) => manifest.quotes.files[lang] ?? '').join('|');
    return '${manifest.manifestVersion}|${manifest.lastUpdated}|'
        '${manifest.quotes.version}|$pathSig';
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

    // Step 3 — Version + manifest stamp
    final remote = manifest.quotes;
    final newStamp = manifestStamp(manifest);
    final oldStamp =
        _settingsBox.get(_manifestStampKey, defaultValue: '') as String;
    final versionHigher = remote.version > localVersion;
    final stampChanged = newStamp != oldStamp;

    debugPrint(
        '📋 Quotes: remote v${remote.version} / local v$localVersion '
        '| stampChanged=$stampChanged');

    if (!versionHigher && !stampChanged) {
      debugPrint('✅ Quotes: version and manifest stamp unchanged — skip');
      return false;
    }

    // Step 4 — Download
    debugPrint(versionHigher
        ? '⬇️ Quotes: new version ${remote.version} — downloading...'
        : '⬇️ Quotes: manifest stamp changed — re-downloading...');

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
        await _settingsBox.put(_manifestStampKey, newStamp);
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
