/// Enum for holiday types
enum HolidayType {
  national,
  religious,
  cultural,
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
class Holiday {
  final String id;
  final String name;
  final String namebn;
  final DateTime date;
  final HolidayType type;
  final String? description;
  final String? descriptionbn;
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
      isGovtHoliday: json['isGovtHoliday'] as bool? ?? true,
    );
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