// lib/core/services/data_sync_service.dart
//
// SINGLE COORDINATOR for all dataset syncing: holidays, quotes, words.
//
// ── Architecture ─────────────────────────────────────────────────────────────
//
//   DataSyncService  ←── only entry point for all sync operations
//       │
//       ├── HolidaySyncService   (holidays worker)
//       ├── QuotesSyncService    (quotes worker)
//       └── WordsSyncService     (words worker)
//
// No screen, repository, or viewmodel should call a worker directly.
// All callers go through DataSyncService.
//
// ── Sync Rules ───────────────────────────────────────────────────────────────
//
//   VERSION CHECK: Always runs. No call ever downloads if remote version
//                  is same as or older than local. This is non-negotiable.
//
//   INTERVAL:      Each dataset tracks its own last-check timestamp.
//                  Auto-sync only runs if the interval has passed.
//
//   force=true:    Skips the interval check ONLY. Version check still runs.
//                  Used by: Settings "Sync All", pull-to-refresh.
//
// ── Sync Triggers ────────────────────────────────────────────────────────────
//
//   1. App startup (AppInitializer)
//      → seedAll() on first launch
//      → backgroundSyncOnStartup() — non-blocking, respects weekly interval
//        controlled by [enableWeeklyAutoSync]
//
//   2. New version detected
//      → Always syncs that dataset, regardless of interval or auto-sync flag
//      → This cannot be disabled — it is the safety net
//
//   3. Settings "Sync All Data" button
//      → forceSync() — skips interval, respects version
//
//   4. Holidays screen pull-to-refresh / manual sync button
//      → syncHolidaysInBackground() — non-blocking, skips interval,
//        respects version, reloads viewmodel if updated

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ekush_ponji/core/models/app_manifest.dart';
import 'package:ekush_ponji/features/holidays/services/holiday_sync_service.dart';
import 'package:ekush_ponji/features/quotes/services/quotes_sync_service.dart';
import 'package:ekush_ponji/features/words/services/words_sync_service.dart';

// ── Configuration ─────────────────────────────────────────────────────────────

/// Set to false to disable the weekly background auto-sync entirely.
/// Manual syncs (Settings, pull-to-refresh) are NOT affected by this flag.
/// Version-triggered syncs are NOT affected — they always run.
const bool enableWeeklyAutoSync = true;

/// How often the background auto-sync is allowed to run.
/// Must match HolidaySyncService._checkIntervalDays.
const int autoSyncIntervalDays = 7;

// ── Manifest URL ──────────────────────────────────────────────────────────────

const String _manifestUrl =
    'https://raw.githubusercontent.com/moinul-alam/ekush_ponji/main/assets/data/manifest.json';

// ── Hive keys (coordinator-level) ────────────────────────────────────────────

const String _settingsBoxName = 'settings';
const String _lastAutoSyncKey = 'data_sync_last_auto';

// ─────────────────────────────────────────────────────────────────────────────

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

  // ── Coordinator-level interval ───────────────────────────────────────────

  /// Whether the global weekly auto-sync interval has elapsed.
  bool get _isAutoSyncDue {
    if (!enableWeeklyAutoSync) return false;
    try {
      final box = Hive.box(_settingsBoxName);
      final lastStr = box.get(_lastAutoSyncKey, defaultValue: null) as String?;
      if (lastStr == null) return true;
      final last = DateTime.tryParse(lastStr);
      if (last == null) return true;
      return DateTime.now().difference(last).inDays >= autoSyncIntervalDays;
    } catch (_) {
      return true;
    }
  }

  Future<void> _recordAutoSync() async {
    try {
      final box = Hive.box(_settingsBoxName);
      await box.put(_lastAutoSyncKey, DateTime.now().toIso8601String());
    } catch (_) {}
  }

  // ── Manifest fetch ────────────────────────────────────────────────────────

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
      debugPrint('⚠️ DataSync: failed to fetch manifest — ${e.message}');
    } catch (e) {
      debugPrint('⚠️ DataSync: manifest parse error — $e');
    }
    return null;
  }

  // ── Seeding (first launch only) ───────────────────────────────────────────

  /// Seeds all datasets from bundled assets into Hive.
  /// Each worker is idempotent — safe to call on every startup.
  Future<void> seedAll() async {
    await Future.wait([
      _holidaySyncService.seed(),
      _quotesSyncService.seed(),
      _wordsSyncService.seed(),
    ]);
  }

  // ── App startup ───────────────────────────────────────────────────────────

  /// Called by AppInitializer during the background phase.
  /// Seeds bundled data on first launch, then runs background sync.
  Future<void> initialize() async {
    await seedAll();
    await backgroundSyncOnStartup();
  }

  /// Non-blocking background sync on app startup.
  ///
  /// Respects [enableWeeklyAutoSync] and the 7-day interval.
  /// Even if auto-sync is disabled or interval not due, version-triggered
  /// syncs still run (remote version > local always triggers download).
  ///
  /// This method fetches the manifest once and:
  ///   a) If [enableWeeklyAutoSync] is true and interval is due →
  ///      passes force=false to all workers (they check their own intervals too)
  ///   b) Always checks version and downloads if a newer version exists,
  ///      even outside the weekly window
  Future<void> backgroundSyncOnStartup() async {
    final shouldRunAutoSync = enableWeeklyAutoSync && _isAutoSyncDue;

    if (!shouldRunAutoSync) {
      debugPrint(
          'ℹ️ DataSync: weekly auto-sync not due or disabled — skipping background sync');
      return;
    }

    debugPrint('🔄 DataSync: weekly auto-sync due — fetching manifest...');

    final manifest = await _fetchManifest();
    if (manifest == null) {
      debugPrint('⚠️ DataSync: manifest unreachable — background sync skipped');
      return;
    }

    await _recordAutoSync();

    // Run all workers concurrently. Each will skip if their version is current.
    final results = await Future.wait([
      _holidaySyncService.syncWithManifest(manifest, force: false),
      _quotesSyncService.syncWithManifest(manifest, force: false),
      _wordsSyncService.syncWithManifest(manifest, force: false),
    ]);

    final updated = results.where((r) => r).length;
    debugPrint(
        '✅ DataSync: background sync complete — $updated dataset(s) updated');
  }

  // ── Force sync — all datasets (Settings button) ───────────────────────────

  /// Bypasses the weekly interval but still respects version check.
  /// Only downloads datasets where remote version > local version.
  /// Returns [DataSyncResult] for the UI to display what changed.
  Future<DataSyncResult> forceSync() async {
    debugPrint('🔄 DataSync: force sync all — fetching manifest...');

    final manifest = await _fetchManifest();

    if (manifest == null) {
      // No network — re-seed from bundled assets as a fallback
      debugPrint('⚠️ DataSync: manifest unreachable — re-seeding from assets');
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

    final result = DataSyncResult(
      success: true,
      holidaysUpdated: results[0],
      quotesUpdated: results[1],
      wordsUpdated: results[2],
    );

    debugPrint(
        '✅ DataSync: force sync complete — ${result.summary(isBn: false)}');
    return result;
  }

  // ── Holidays-only sync (holidays screen) ─────────────────────────────────

  /// Syncs holidays only, skipping the interval but respecting version.
  /// Returns true if holidays were actually updated.
  ///
  /// Used by:
  ///   • HolidaysViewModel.syncHolidays() — manual sync button (awaited, shows spinner)
  ///   • HolidaysViewModel._backgroundSyncIfNeeded() — non-blocking background check
  Future<bool> syncHolidaysOnly() async {
    debugPrint('🔄 DataSync: holidays-only sync — fetching manifest...');

    final manifest = await _fetchManifest();

    if (manifest == null) {
      debugPrint(
          '⚠️ DataSync: manifest unreachable — re-seeding holidays from assets');
      await _holidaySyncService.seed();
      return false;
    }

    final updated =
        await _holidaySyncService.syncWithManifest(manifest, force: true);
    debugPrint('✅ DataSync: holidays-only sync complete — updated=$updated');
    return updated;
  }
}

// ── Result model ──────────────────────────────────────────────────────────────

class DataSyncResult {
  final bool success;

  /// True when manifest was unreachable and we fell back to bundled assets.
  final bool localOnly;

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

  /// Human-readable summary, bilingual.
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
