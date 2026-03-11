// lib/features/words/services/words_sync_service.dart

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

  /// Key under which the synced words JSON string is stored in Hive.
  /// WordsLocalDatasource reads from this key after a sync.
  static const String wordsEnKey = 'words_en_json';

  // ── Config ─────────────────────────────────────────────────
  static const int _checkIntervalDays = 30;

  final Dio _dio;

  WordsSyncService({Dio? dio}) : _dio = dio ?? Dio();

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
    if (!force && !isSyncDue) {
      debugPrint('ℹ️ Words sync not due yet');
      return false;
    }

    await _settingsBox.put(_lastCheckKey, DateTime.now().toIso8601String());

    final remote = manifest.words;
    debugPrint('📋 Words: remote v${remote.version} / local v$localVersion');

    if (!force && remote.version <= localVersion) {
      debugPrint('✅ Words up to date');
      return false;
    }

    final url = remote.urlForLanguage('en');
    if (url == null) {
      debugPrint('⚠️ No words URL found for language: en');
      return false;
    }

    try {
      final response = await _dio.get<String>(url);
      if (response.statusCode == 200 && response.data != null) {
        // Validate JSON before overwriting good data
        jsonDecode(response.data!);
        await _settingsBox.put(wordsEnKey, response.data);
        await _settingsBox.put(_versionKey, remote.version);
        debugPrint('✅ Words synced → v${remote.version}');
        return true;
      }
    } on DioException catch (e) {
      debugPrint('⚠️ Network error syncing words: ${e.message}');
    } catch (e) {
      debugPrint('⚠️ Failed to sync words: $e');
    }

    return false;
  }
}
