// lib/core/services/app_version_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionInfo {
  final String version;
  final String buildNumber;

  const AppVersionInfo({
    required this.version,
    required this.buildNumber,
  });

  /// e.g. "1.0.0 (1)"
  String get full => '$version ($buildNumber)';

  /// e.g. "Version 1.0.0"
  String get displayEn => 'Version $version';

  /// e.g. "সংস্করণ ১.০.০" — Bengali numerals converted
  String get displayBn {
    final bnVersion = _toBengali(version);
    return 'সংস্করণ $bnVersion';
  }

  String _toBengali(String input) {
    const map = {
      '0': '০', '1': '১', '2': '২', '3': '৩', '4': '৪',
      '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯',
    };
    return input.split('').map((c) => map[c] ?? c).join();
  }
}

class AppVersionNotifier extends AsyncNotifier<AppVersionInfo> {
  @override
  Future<AppVersionInfo> build() async {
    final info = await PackageInfo.fromPlatform();
    return AppVersionInfo(
      version: info.version,
      buildNumber: info.buildNumber,
    );
  }
}

final appVersionProvider =
    AsyncNotifierProvider<AppVersionNotifier, AppVersionInfo>(
  AppVersionNotifier.new,
);