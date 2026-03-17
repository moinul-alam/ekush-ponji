// lib/core/services/base_sync_service.dart

import 'package:ekush_ponji/core/models/app_manifest.dart';

abstract class BaseSyncService {
  Future<void> seed();

  /// Returns true only if data was actually downloaded and saved.
  Future<bool> syncWithManifest(AppManifest manifest, {bool force = false});

  /// Each worker defines its own interval (e.g. 7 days for holidays).
  bool get isSyncDue;

  /// The locally stored data version (0 if never synced).
  int get localVersion;
}
