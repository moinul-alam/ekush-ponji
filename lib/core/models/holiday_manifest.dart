// lib/core/models/holiday_manifest.dart

/// Represents the manifest.json hosted on GitHub
/// Used to check if a newer holiday dataset is available
class HolidayManifest {
  final int holidaysVersion;
  final String lastUpdated;
  final Map<String, String> files; // year → raw GitHub URL

  const HolidayManifest({
    required this.holidaysVersion,
    required this.lastUpdated,
    required this.files,
  });

  factory HolidayManifest.fromJson(Map<String, dynamic> json) {
    return HolidayManifest(
      holidaysVersion: json['holidaysVersion'] as int,
      lastUpdated: json['lastUpdated'] as String,
      files: Map<String, String>.from(json['files'] as Map),
    );
  }

  /// Get the download URL for a specific year, if available
  String? urlForYear(int year) => files[year.toString()];

  /// All years available in this manifest
  List<int> get availableYears =>
      files.keys.map(int.parse).toList()..sort();
}