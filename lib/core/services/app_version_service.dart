// lib/core/services/app_version_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Filled during [AppInitializer.initializeCore] via [warmFromPlatform].
class AppVersionCache {
  AppVersionCache._();

  static AppVersionInfo? _value;

  static AppVersionInfo? get current => _value;

  /// Reads [PackageInfo] from the OS (pubspec `version`/`+build` at last build).
  static Future<void> warmFromPlatform() async {
    if (_value != null) return;
    try {
      final info = await PackageInfo.fromPlatform();
      _value = AppVersionInfo(
        version: info.version,
        buildNumber: info.buildNumber,
      );
      debugPrint(
        '[AppVersion] ${info.version}+${info.buildNumber} (${info.packageName})',
      );
    } catch (e, st) {
      debugPrint('⚠️ PackageInfo.fromPlatform failed: $e');
      debugPrintStack(stackTrace: st);
      _value = const AppVersionInfo(version: '0.0.0', buildNumber: '?');
    }
  }

  @visibleForTesting
  static void clearForTest() => _value = null;
}

class AppVersionInfo {
  final String version;
  final String buildNumber;

  const AppVersionInfo({
    required this.version,
    required this.buildNumber,
  });

  /// Marketing version + build — for support / logs only (not shown in UI).
  String get compact => '$version ($buildNumber)';

  /// User-facing (e.g. Settings / About). Build stays in [compact] for stores.
  String get displayEn => 'Version $version';

  /// User-facing Bangla — marketing version only.
  String get displayBn => 'সংস্করণ ${_toBengali(version)}';

  String _toBengali(String input) {
    const map = {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
    };
    return input.split('').map((c) => map[c] ?? c).join();
  }
}

/// Sync provider — call [AppVersionCache.warmFromPlatform] before first read
/// (done in [AppInitializer.initializeCore]).
final appVersionProvider = Provider<AppVersionInfo>((ref) {
  final v = AppVersionCache.current;
  if (v != null) return v;
  throw StateError(
    'App version not loaded. Call AppVersionCache.warmFromPlatform() '
    'from AppInitializer.initializeCore() before runApp.',
  );
});
