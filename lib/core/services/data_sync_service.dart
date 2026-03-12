// lib/core/services/data_sync_service.dart
//
// Orchestrates syncing for all datasets: holidays, quotes, words.
// Each dataset has its own sync service; this class coordinates them
// and owns the manifest fetch. Screens call this — never individual
// sync services directly.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/models/app_manifest.dart';
import 'package:ekush_ponji/features/holidays/services/holiday_sync_service.dart';
import 'package:ekush_ponji/features/quotes/services/quotes_sync_service.dart';
import 'package:ekush_ponji/features/words/services/words_sync_service.dart';

const String _manifestUrl =
    'https://raw.githubusercontent.com/moinul-alam/ekush_ponji/main/assets/data/manifest.json';

class DataSyncService {
  final Dio _dio;
  final HolidaySyncService _holidaySyncService;
  final QuotesSyncService _quotesSyncService;
  final WordsSyncService _wordsSyncService;

  DataSyncService({
    Dio? dio,
    HolidaySyncService? holidaySyncService,
    QuotesSyncService? quotesSyncService,
    WordsSyncService? wordsSyncService,
  })  : _dio = dio ?? Dio(),
        _holidaySyncService = holidaySyncService ?? HolidaySyncService(),
        _quotesSyncService = quotesSyncService ?? QuotesSyncService(),
        _wordsSyncService = wordsSyncService ?? WordsSyncService();

  // ── Manifest fetch ───────────────────────────────────────

  Future<AppManifest?> _fetchManifest() async {
    try {
      final response = await _dio.get<String>(
        _manifestUrl,
        options: Options(
          headers: {'Accept': 'application/json, text/plain, */*'},
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        final json = jsonDecode(response.data!) as Map<String, dynamic>;
        return AppManifest.fromJson(json);
      }
    } on DioException catch (e) {
      debugPrint('! Failed to fetch manifest: ' + (e.message ?? ''));
    } catch (e) {
      debugPrint('! Manifest parse error: ' + e.toString());
    }
    return null;
  }

  // ── Seeding (called on first launch) ────────────────────

  Future<void> seedAll() async {
    await Future.wait([
      _holidaySyncService.seed(),
      _quotesSyncService.seed(),
      _wordsSyncService.seed(),
    ]);
  }

  // ── Initialize (seed + startup sync) ────────────────────
  // Called by AppInitializer — seeds bundled assets on first
  // launch then checks remote for updates in one call.

  Future<void> initialize() async {
    await seedAll();
    await syncOnStartup();
  }

  // ── Startup sync (respects checkInterval per dataset) ───

  Future<void> syncOnStartup() async {
    final manifest = await _fetchManifest();
    if (manifest == null) return;

    await Future.wait([
      _holidaySyncService.syncWithManifest(manifest),
      _quotesSyncService.syncWithManifest(manifest),
      _wordsSyncService.syncWithManifest(manifest),
    ]);
  }

  // ── Force sync — all datasets (Settings "Data Sync") ────
  //
  // Runs all three in parallel. Returns a [DataSyncResult]
  // describing what actually changed so the UI can be specific.

  Future<DataSyncResult> forceSync() async {
    final manifest = await _fetchManifest();

    // No manifest — remote unreachable. Re-seed from bundled assets
    // so the user gets fresh local data even without a network.
    if (manifest == null) {
      await seedAll();
      return const DataSyncResult(
        success: true,
        localOnly: true,
        holidaysUpdated: false,
        quotesUpdated: false,
        wordsUpdated: false,
      );
    }

    final results = await Future.wait([
      _holidaySyncService.syncWithManifest(manifest, force: true),
      _quotesSyncService.syncWithManifest(manifest, force: true),
      _wordsSyncService.syncWithManifest(manifest, force: true),
    ]);

    return DataSyncResult(
      success: true,
      holidaysUpdated: results[0],
      quotesUpdated: results[1],
      wordsUpdated: results[2],
    );
  }

  // ── Force sync — holidays only (Holidays screen button) ─

  Future<bool> forceHolidaySync() async {
    final manifest = await _fetchManifest();

    // No manifest — re-seed holidays from bundled assets.
    if (manifest == null) {
      await _holidaySyncService.seed();
      return false; // no remote update, but local data refreshed
    }

    return _holidaySyncService.syncWithManifest(manifest, force: true);
  }
}

// ── Result model ─────────────────────────────────────────────

class DataSyncResult {
  final bool success;
  final bool localOnly; // true when manifest unreachable, fell back to seed
  final bool holidaysUpdated;
  final bool quotesUpdated;
  final bool wordsUpdated;

  const DataSyncResult({
    required this.success,
    this.localOnly = false,
    required this.holidaysUpdated,
    required this.quotesUpdated,
    required this.wordsUpdated,
  });

  bool get anyUpdated => holidaysUpdated || quotesUpdated || wordsUpdated;

  /// Human-readable summary of what changed, bilingual.
  String summary({required bool isBn}) {
    if (!success) {
      return isBn
          ? 'সিঙ্ক ব্যর্থ — ইন্টারনেট সংযোগ পরীক্ষা করুন'
          : 'Sync failed — check your connection';
    }
    if (localOnly) {
      return isBn
          ? 'অফলাইন — স্থানীয় ডেটা ব্যবহার করা হচ্ছে'
          : 'Offline — using local data';
    }
    if (!anyUpdated) {
      return isBn ? 'সব কিছু আপডেট আছে' : 'Everything is up to date';
    }

    final updated = <String>[];
    if (holidaysUpdated) updated.add(isBn ? 'ছুটির তালিকা' : 'Holidays');
    if (quotesUpdated) updated.add(isBn ? 'উদ্ধৃতি' : 'Quotes');
    if (wordsUpdated) updated.add(isBn ? 'শব্দ' : 'Words');

    final list = updated.join(', ');
    return isBn ? '$list আপডেট হয়েছে' : '$list updated';
  }
}

// Provider lives in app_providers.dart — not declared here.