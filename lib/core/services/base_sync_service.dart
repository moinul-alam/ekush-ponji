// lib/core/services/base_sync_service.dart

import 'package:ekush_ponji/core/models/app_manifest.dart';

/// Contract that every dataset sync service must implement.
/// DataSyncService depends only on this interface — never on
/// concrete implementations — so adding new datasets requires
/// zero changes to DataSyncService internals.
abstract class BaseSyncService {
  /// Loads bundled asset data into Hive on first launch.
  /// Must be idempotent — safe to call on every startup.
  Future<void> seed();

  /// Compares remote manifest version against local version
  /// and fetches updated data if needed.
  /// Returns true if data was actually updated.
  Future<bool> syncWithManifest(AppManifest manifest, {bool force = false});

  /// Whether enough time has passed since the last sync check.
  bool get isSyncDue;

  /// The locally stored data version (0 if never synced).
  int get localVersion;
}
