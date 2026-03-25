// lib/features/words/services/words_sync_service.dart
//
// Worker service for words dataset.
// Responsible ONLY for: seed, fetch from GitHub, save to Hive.
// Does NOT own scheduling logic — that belongs to DataSyncService.
//
// SYNC BEHAVIOUR:
//   • force=false → skip if interval not due AND manifest unchanged
//   • force=true  → skip interval check only
//   • Downloads if dataset version increased OR manifest stamp changed.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ekush_ponji/core/models/app_manifest.dart';
import 'package:ekush_ponji/core/services/base_sync_service.dart';

class WordsSyncService implements BaseSyncService {
  // ── Hive keys ──────────────────────────────────────────────
  static const String _settingsBoxName = 'settings';
  static const String _seededKey = 'words_seeded_v1';
  static const String _versionKey = 'words_version';
  static const String _lastCheckKey = 'words_last_check';
  static const String _manifestStampKey = 'words_manifest_stamp';

  /// Public key used by WordsLocalDatasource to read the stored JSON.
  static const String wordsEnKey = 'words_en_json';

  // ── Config ─────────────────────────────────────────────────
  /// Words change infrequently — check every 30 days is appropriate.
  static const int _checkIntervalDays = 30;

  final Dio _dio;

  WordsSyncService({Dio? dio}) : _dio = dio ?? Dio();

  Box get _settingsBox => Hive.box(_settingsBoxName);

  static String manifestStamp(AppManifest manifest) {
    final langs = manifest.words.files.keys.map((k) => k.toString()).toList()
      ..sort();
    final pathSig =
        langs.map((lang) => manifest.words.files[lang] ?? '').join('|');
    return '${manifest.manifestVersion}|${manifest.lastUpdated}|'
        '${manifest.words.version}|$pathSig';
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
      debugPrint('ℹ️ Words already seeded — skipping');
      return;
    }

    debugPrint('🌱 Seeding bundled words asset...');
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/words/words_en.json');

      // Validate before storing
      jsonDecode(jsonString);

      await _settingsBox.put(wordsEnKey, jsonString);
      await _settingsBox.put(_seededKey, true);
      if (localVersion == 0) {
        await _settingsBox.put(_versionKey, 1);
      }
      debugPrint('✅ Words seeding complete');
    } catch (e) {
      debugPrint('⚠️ Failed to seed words: $e');
    }
  }

  @override
  Future<bool> syncWithManifest(
    AppManifest manifest, {
    bool force = false,
  }) async {
    // Step 1 — Time interval gate (skipped when force=true)
    if (!force && !isSyncDue) {
      debugPrint('ℹ️ Words: sync interval not due yet — skipping');
      return false;
    }

    // Step 2 — Always record the check time so the interval resets
    await _settingsBox.put(_lastCheckKey, DateTime.now().toIso8601String());

    // Step 3 — Version + manifest stamp
    final remote = manifest.words;
    final newStamp = manifestStamp(manifest);
    final oldStamp =
        _settingsBox.get(_manifestStampKey, defaultValue: '') as String;
    final versionHigher = remote.version > localVersion;
    final stampChanged = newStamp != oldStamp;

    debugPrint(
        '📋 Words: remote v${remote.version} / local v$localVersion '
        '| stampChanged=$stampChanged');

    if (!versionHigher && !stampChanged) {
      debugPrint('✅ Words: version and manifest stamp unchanged — skip');
      return false;
    }

    // Step 4 — Download
    debugPrint(versionHigher
        ? '⬇️ Words: new version ${remote.version} — downloading...'
        : '⬇️ Words: manifest stamp changed — re-downloading...');

    final url = remote.urlForLanguage('en');
    if (url == null) {
      debugPrint('⚠️ Words: no URL found for language "en"');
      return false;
    }

    try {
      final response = await _dio.get<String>(url);
      if (response.statusCode == 200 && response.data != null) {
        // Validate JSON before overwriting good data
        jsonDecode(response.data!);
        await _settingsBox.put(wordsEnKey, response.data);
        await _settingsBox.put(_versionKey, remote.version);
        await _settingsBox.put(_manifestStampKey, newStamp);
        debugPrint('✅ Words synced → v${remote.version}');
        return true;
      }
    } on DioException catch (e) {
      debugPrint('⚠️ Words: network error — ${e.message}');
    } catch (e) {
      debugPrint('⚠️ Words: failed to sync — $e');
    }

    return false;
  }
}
