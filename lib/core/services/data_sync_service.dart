// lib/core/services/data_sync_service.dart

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:ekush_ponji/core/models/app_manifest.dart';
import 'package:ekush_ponji/core/services/base_sync_service.dart';
import 'package:ekush_ponji/features/holidays/services/holiday_sync_service.dart';
import 'package:ekush_ponji/features/quotes/services/quotes_sync_service.dart';
import 'package:ekush_ponji/features/words/services/words_sync_service.dart';

/// Pure orchestrator. Owns the manifest URL and delegates
/// all dataset logic to individual sync services.
///
/// To add a new dataset in the future:
///   1. Create NewDataSyncService implementing BaseSyncService
///   2. Add it to the _services list below
///   3. Optionally expose a forceNewDataSync() method
///   That's it — nothing else changes here.
class DataSyncService {
  static const String _manifestUrl =
      'https://raw.githubusercontent.com/moinul-alam/ekush_ponji/refs/heads/main/assets/data/manifest.json';

  final HolidaySyncService holidays;
  final QuotesSyncService quotes;
  final WordsSyncService words;

  /// All registered services — used for bulk seed/sync operations.
  late final List<BaseSyncService> _services;

  final Dio _dio;

  DataSyncService({
    HolidaySyncService? holidaySyncService,
    QuotesSyncService? quotesSyncService,
    WordsSyncService? wordsSyncService,
    Dio? dio,
  })  : holidays = holidaySyncService ?? HolidaySyncService(),
        quotes = quotesSyncService ?? QuotesSyncService(),
        words = wordsSyncService ?? WordsSyncService(),
        _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
            )) {
    _services = [holidays, quotes, words];
  }

  // ── Public API ─────────────────────────────────────────────

  /// Call once at app startup.
  /// Seeds all bundled assets, then syncs any that are due.
  Future<void> initialize() async {
    await _seedAll();
    await _syncDue();
  }

  /// Force re-sync all datasets regardless of interval.
  Future<void> forceSync() async {
    final manifest = await _fetchManifest();
    if (manifest == null) return;
    for (final service in _services) {
      await service.syncWithManifest(manifest, force: true);
    }
  }

  /// Force re-sync holidays only (for manual refresh in settings UI).
  Future<bool> forceHolidaySync() async {
    final manifest = await _fetchManifest();
    if (manifest == null) return false;
    return await holidays.syncWithManifest(manifest, force: true);
  }

  // ── Internal ───────────────────────────────────────────────

  Future<void> _seedAll() async {
    for (final service in _services) {
      await service.seed();
    }
  }

  Future<void> _syncDue() async {
    // Check before fetching manifest — if nothing is due, skip network call
    final anyDue = _services.any((s) => s.isSyncDue);
    if (!anyDue) {
      debugPrint('ℹ️ All datasets up to date — skipping manifest fetch');
      return;
    }

    final manifest = await _fetchManifest();
    if (manifest == null) return;

    for (final service in _services) {
      await service.syncWithManifest(manifest);
    }
  }

  Future<AppManifest?> _fetchManifest() async {
    try {
      final response = await _dio.get<String>(_manifestUrl);
      if (response.statusCode != 200 || response.data == null) return null;
      final json = jsonDecode(response.data!) as Map<String, dynamic>;
      return AppManifest.fromJson(json);
    } on DioException catch (e) {
      debugPrint('⚠️ Network error fetching manifest: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('⚠️ Failed to parse manifest: $e');
      return null;
    }
  }
}
