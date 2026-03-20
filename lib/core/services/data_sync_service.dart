// lib/core/services/data_sync_service.dart

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ekush_ponji/core/models/app_manifest.dart';
import 'package:ekush_ponji/features/holidays/services/holiday_sync_service.dart';
import 'package:ekush_ponji/features/quotes/services/quotes_sync_service.dart';
import 'package:ekush_ponji/features/words/services/words_sync_service.dart';
import 'package:ekush_ponji/features/calendar/services/hijri_offset_sync_service.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

// ── Configuration ─────────────────────────────────────────────────────────────

const bool enableWeeklyAutoSync = true;

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
  final HijriOffsetSyncService _hijriOffsetSyncService;

  DataSyncService({
    Dio? dio,
    HolidaySyncService? holidaySyncService,
    QuotesSyncService? quotesSyncService,
    WordsSyncService? wordsSyncService,
    HijriOffsetSyncService? hijriOffsetSyncService,
  })  : _dio = dio ?? Dio(),
        _holidaySyncService = holidaySyncService ?? HolidaySyncService(),
        _quotesSyncService = quotesSyncService ?? QuotesSyncService(),
        _wordsSyncService = wordsSyncService ?? WordsSyncService(),
        _hijriOffsetSyncService =
            hijriOffsetSyncService ?? HijriOffsetSyncService();

  // ── Coordinator-level interval ────────────────────────────────────────────

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

  /// Background sync on every app launch.
  ///
  /// Hijri offsets are fetched independently — tiny, time-sensitive, and
  /// must not be blocked by main manifest availability or weekly interval.
  ///
  /// Main manifest (holidays/quotes/words) only syncs on weekly interval.
  Future<void> backgroundSyncOnStartup() async {
    // ── Step 1: Hijri offsets — always, independent of manifest ──────────────
    // Constructs URL from year directly (no manifest needed).
    // Fetches current year + next year. 404 = file not yet created, silent.
    await _hijriOffsetSyncService.syncAll();

    // ── Step 2: Main manifest — holidays / quotes / words ────────────────────
    if (!enableWeeklyAutoSync || !_isAutoSyncDue) {
      debugPrint(
          'ℹ️ DataSync: weekly auto-sync not due or disabled — skipping');
      return;
    }

    final manifest = await _fetchManifest();
    if (manifest == null) {
      debugPrint('⚠️ DataSync: manifest unreachable — background sync skipped');
      return;
    }

    debugPrint('🔄 DataSync: weekly auto-sync due — syncing datasets...');
    await _recordAutoSync();

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

  Future<DataSyncResult> forceSync() async {
    debugPrint('🔄 DataSync: force sync all — fetching manifest...');

    // Always re-fetch Hijri offsets on force sync
    await _hijriOffsetSyncService.syncAll();

    final manifest = await _fetchManifest();

    if (manifest == null) {
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

    debugPrint('✅ DataSync: force sync complete — '
        'holidays=${result.holidaysUpdated} '
        'quotes=${result.quotesUpdated} '
        'words=${result.wordsUpdated}');

    return result;
  }

  // ── Holidays-only sync (holidays screen) ─────────────────────────────────

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

  String summary(AppLocalizations l10n) {
    if (!success) return l10n.syncFailed;
    if (localOnly) return l10n.syncOffline;
    if (!anyUpdated) return l10n.syncUpToDate;

    final updated = [
      if (holidaysUpdated) l10n.syncDatasetHolidays,
      if (quotesUpdated) l10n.syncDatasetQuotes,
      if (wordsUpdated) l10n.syncDatasetWords,
    ];

    return l10n.syncUpdated(updated.join(', '));
  }
}
