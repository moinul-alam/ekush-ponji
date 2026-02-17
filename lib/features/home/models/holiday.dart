import 'package:hive/hive.dart';

part 'holiday.g.dart'; 

/// Enum for holiday types
@HiveType(typeId: 1)  // ← Add Hive annotation
enum HolidayType {
  @HiveField(0)
  national,
  
  @HiveField(1)
  religious,
  
  @HiveField(2)
  cultural,
  
  @HiveField(3)
  optional;

  String get displayName {
    switch (this) {
      case HolidayType.national:
        return 'National';
      case HolidayType.religious:
        return 'Religious';
      case HolidayType.cultural:
        return 'Cultural';
      case HolidayType.optional:
        return 'Optional';
    }
  }
}

/// Model class for Holiday
/// Represents a holiday in the calendar
@HiveType(typeId: 0)  // ← Add Hive annotation
class Holiday {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String namebn;
  
  @HiveField(3)
  final DateTime date;
  
  @HiveField(4)
  final HolidayType type;
  
  @HiveField(5)
  final String? description;
  
  @HiveField(6)
  final String? descriptionbn;
  
  @HiveField(7)
  final bool isGovtHoliday;

  Holiday({
    String? id,
    required this.name,
    required this.namebn,
    required this.date,
    required this.type,
    this.description,
    this.descriptionbn,
    this.isGovtHoliday = true,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  /// Check if holiday is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if holiday is upcoming (within next 30 days)
  bool get isUpcoming {
    final now = DateTime.now();
    final difference = date.difference(now);
    return difference.inDays >= 0 && difference.inDays <= 30;
  }

  /// Get days until this holiday
  int get daysUntil {
    final now = DateTime.now();
    return date.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  /// Get display text for days until
  String getDaysUntilText() {
    if (daysUntil == 0) return 'Today';
    if (daysUntil == 1) return 'Tomorrow';
    if (daysUntil > 0) return 'In $daysUntil days';
    return 'Passed';
  }

  /// Copy with method
  Holiday copyWith({
    String? id,
    String? name,
    String? namebn,
    DateTime? date,
    HolidayType? type,
    String? description,
    String? descriptionbn,
    bool? isGovtHoliday,
  }) {
    return Holiday(
      id: id ?? this.id,
      name: name ?? this.name,
      namebn: namebn ?? this.namebn,
      date: date ?? this.date,
      type: type ?? this.type,
      description: description ?? this.description,
      descriptionbn: descriptionbn ?? this.descriptionbn,
      isGovtHoliday: isGovtHoliday ?? this.isGovtHoliday,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'namebn': namebn,
      'date': date.toIso8601String(),
      'type': type.name,
      'description': description,
      'descriptionbn': descriptionbn,
      'isGovtHoliday': isGovtHoliday,
    };
  }

  /// Create from JSON
  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'] as String?,
      name: json['name'] as String,
      namebn: json['namebn'] as String,
      date: DateTime.parse(json['date'] as String),
      type: HolidayType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HolidayType.national,
      ),
      description: json['description'] as String?,
      descriptionbn: json['descriptionbn'] as String?,
      isGovtHoliday: _parseBool(json['isGovtHoliday']),
    );
  }

  /// Helper method to parse boolean from various types
  static bool _parseBool(dynamic value) {
    if (value == null) return true;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value == 1;
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Holiday && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Holiday(id: $id, name: $name, date: $date, type: ${type.name})';
  }
}