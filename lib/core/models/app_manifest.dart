// lib/core/models/app_manifest.dart

class AppManifest {
  final int manifestVersion;
  final String lastUpdated;
  final String baseUrl;
  final HolidaysManifestData holidays;
  final SingleFileManifestData quotes;
  final SingleFileManifestData words;

  const AppManifest({
    required this.manifestVersion,
    required this.lastUpdated,
    required this.baseUrl,
    required this.holidays,
    required this.quotes,
    required this.words,
  });

  factory AppManifest.fromJson(Map<String, dynamic> json) {
    final baseUrl = json['baseUrl'] as String;
    final datasets = json['datasets'] as Map<String, dynamic>;

    return AppManifest(
      manifestVersion: json['manifestVersion'] as int,
      lastUpdated: json['lastUpdated'] as String,
      baseUrl: baseUrl,
      holidays: HolidaysManifestData.fromJson(
        datasets['holidays'] as Map<String, dynamic>,
        baseUrl,
      ),
      quotes: SingleFileManifestData.fromJson(
        datasets['quotes'] as Map<String, dynamic>,
        baseUrl,
      ),
      words: SingleFileManifestData.fromJson(
        datasets['words'] as Map<String, dynamic>,
        baseUrl,
      ),
    );
  }
}

/// Holidays dataset — versioned, split by year.
class HolidaysManifestData {
  final int version;
  final Map<String, String> files; // year → full URL

  const HolidaysManifestData({
    required this.version,
    required this.files,
  });

  factory HolidaysManifestData.fromJson(
    Map<String, dynamic> json,
    String baseUrl,
  ) {
    final rawFiles = json['files'] as Map<String, dynamic>;
    final resolvedFiles = rawFiles.map(
      (year, path) => MapEntry(year, '$baseUrl/$path'),
    );
    return HolidaysManifestData(
      version: json['version'] as int,
      files: Map<String, String>.from(resolvedFiles),
    );
  }

  String? urlForYear(int year) => files[year.toString()];

  List<int> get availableYears => files.keys.map(int.parse).toList()..sort();
}

/// Quotes / Words dataset — versioned, single file per language.
class SingleFileManifestData {
  final int version;
  final Map<String, String> files; // language code → full URL

  const SingleFileManifestData({
    required this.version,
    required this.files,
  });

  factory SingleFileManifestData.fromJson(
    Map<String, dynamic> json,
    String baseUrl,
  ) {
    final rawFiles = json['files'] as Map<String, dynamic>;
    final resolvedFiles = rawFiles.map(
      (lang, path) => MapEntry(lang, '$baseUrl/$path'),
    );
    return SingleFileManifestData(
      version: json['version'] as int,
      files: Map<String, String>.from(resolvedFiles),
    );
  }

  String? urlForLanguage(String langCode) => files[langCode];
}
