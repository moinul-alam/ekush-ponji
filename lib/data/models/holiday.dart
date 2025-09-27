// lib/data/models/holiday.dart
import 'package:hive/hive.dart';

part 'holiday.g.dart';

@HiveType(typeId: 0)
class Holiday extends HiveObject {
  @HiveField(0)
  final String nameEn;
  
  @HiveField(1)
  final String nameBn;
  
  @HiveField(2)
  final DateTime date;
  
  @HiveField(3)
  final bool isPublicHoliday;

  Holiday({
    required this.nameEn,
    required this.nameBn,
    required this.date,
    this.isPublicHoliday = true,
  });

  // Add these methods for better data handling
  Map<String, dynamic> toMap() {
    return {
      'nameEn': nameEn,
      'nameBn': nameBn,
      'date': date.toIso8601String(),
      'isPublicHoliday': isPublicHoliday,
    };
  }

  factory Holiday.fromMap(Map<String, dynamic> map) {
    return Holiday(
      nameEn: map['nameEn']?.toString() ?? '',
      nameBn: map['nameBn']?.toString() ?? '',
      date: map['date'] != null 
          ? (map['date'] is String 
              ? DateTime.parse(map['date']) 
              : map['date'] as DateTime)
          : DateTime.now(),
      isPublicHoliday: map['isPublicHoliday'] ?? true,
    );
  }

  Holiday copyWith({
    String? nameEn,
    String? nameBn,
    DateTime? date,
    bool? isPublicHoliday,
  }) {
    return Holiday(
      nameEn: nameEn ?? this.nameEn,
      nameBn: nameBn ?? this.nameBn,
      date: date ?? this.date,
      isPublicHoliday: isPublicHoliday ?? this.isPublicHoliday,
    );
  }

  @override
  String toString() {
    return 'Holiday(nameEn: $nameEn, nameBn: $nameBn, date: $date, isPublicHoliday: $isPublicHoliday)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Holiday &&
        other.nameEn == nameEn &&
        other.nameBn == nameBn &&
        other.date == date &&
        other.isPublicHoliday == isPublicHoliday;
  }

  @override
  int get hashCode {
    return nameEn.hashCode ^
        nameBn.hashCode ^
        date.hashCode ^
        isPublicHoliday.hashCode;
  }
}