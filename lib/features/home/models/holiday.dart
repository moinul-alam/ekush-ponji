import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

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
/// Supports both single-day and multi-day holidays via optional endDate
class Holiday {
  final String id;
  final String name;
  final String namebn;
  final DateTime date;       // startDate
  final DateTime? endDate;   // null for single-day holidays
  final HolidayType type;
  final String? description;
  final String? descriptionbn;
  final bool isGovtHoliday;

  Holiday({
    String? id,
    required this.name,
    required this.namebn,
    required this.date,
    this.endDate,
    required this.type,
    this.description,
    this.descriptionbn,
    this.isGovtHoliday = true,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // ------------------- Computed Properties -------------------

  /// Whether this holiday spans multiple days
  bool get isMultiDay => endDate != null;

  /// Check if a given date falls within this holiday's range
  bool containsDate(DateTime target) {
    final targetDay = DateTime(target.year, target.month, target.day);
    final startDay = DateTime(date.year, date.month, date.day);

    if (endDate == null) return targetDay == startDay;

    final endDay = DateTime(endDate!.year, endDate!.month, endDate!.day);
    return !targetDay.isBefore(startDay) && !targetDay.isAfter(endDay);
  }

  /// Check if holiday is today
  bool get isToday => containsDate(DateTime.now());

  /// Check if holiday is upcoming (within next 30 days)
  bool get isUpcoming {
    final now = DateTime.now();
    final difference = date.difference(now);
    return difference.inDays >= 0 && difference.inDays <= 30;
  }

  /// Days until this holiday (based on startDate)
  int get daysUntil {
    final now = DateTime.now();
    return date.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  /// Display text for days until
  String getDaysUntilText() {
    if (daysUntil == 0) return 'Today';
    if (daysUntil == 1) return 'Tomorrow';
    if (daysUntil > 0) return 'In $daysUntil days';
    return 'Passed';
  }

  // ------------------- Serialization -------------------

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'] as String?,
      name: json['name'] as String,
      namebn: json['namebn'] as String,
      date: _parseDate(json['date']),
      endDate: json['endDate'] != null ? _parseDate(json['endDate']) : null,
      type: HolidayType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HolidayType.national,
      ),
      description: json['description'] as String?,
      descriptionbn: json['descriptionbn'] as String?,
      isGovtHoliday: _parseBool(json['isGovtHoliday']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'namebn': namebn,
      'date': date.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'type': type.name,
      'description': description,
      'descriptionbn': descriptionbn,
      'isGovtHoliday': isGovtHoliday,
    };
  }

  // ------------------- Helpers -------------------

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    throw Exception('Unsupported date format: $value');
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return true;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    if (value is int) return value == 1;
    return true;
  }

  // ------------------- Object Overrides -------------------

  Holiday copyWith({
    String? id,
    String? name,
    String? namebn,
    DateTime? date,
    DateTime? endDate,
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
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      description: description ?? this.description,
      descriptionbn: descriptionbn ?? this.descriptionbn,
      isGovtHoliday: isGovtHoliday ?? this.isGovtHoliday,
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
  String toString() =>
      'Holiday(id: $id, name: $name, date: $date, endDate: $endDate, type: ${type.name})';
}

// ─────────────────────────────────────────────────────────────
// Manual Hive Adapters — replaces generated holiday.g.dart
// ─────────────────────────────────────────────────────────────

class HolidayTypeAdapter extends TypeAdapter<HolidayType> {
  @override
  final int typeId = 1;

  @override
  HolidayType read(BinaryReader reader) {
    final index = reader.readByte();
    return HolidayType.values[index];
  }

  @override
  void write(BinaryWriter writer, HolidayType obj) {
    writer.writeByte(obj.index);
  }
}

class HolidayAdapter extends TypeAdapter<Holiday> {
  @override
  final int typeId = 0;

  @override
  Holiday read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Holiday(
      id: fields[0] as String?,
      name: fields[1] as String,
      namebn: fields[2] as String,
      date: fields[3] as DateTime,
      type: fields[4] as HolidayType,
      description: fields[5] as String?,
      descriptionbn: fields[6] as String?,
      isGovtHoliday: fields[7] as bool? ?? true,
      endDate: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Holiday obj) {
    writer.writeByte(9); // number of fields
    writer
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.namebn)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.descriptionbn)
      ..writeByte(7)
      ..write(obj.isGovtHoliday)
      ..writeByte(8)
      ..write(obj.endDate);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HolidayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}