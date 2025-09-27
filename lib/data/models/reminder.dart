// lib/data/models/reminder.dart
import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 1)
class Reminder extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String? description;
  
  @HiveField(3)
  DateTime dateTime;
  
  @HiveField(4)
  bool isCompleted;
  
  @HiveField(5)
  DateTime createdAt;

  Reminder({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // FIXED: This was likely causing your null check error
  factory Reminder.fromMap(Map<String, dynamic> map) {
    // Validate required fields and provide safe defaults
    final id = map['id']?.toString();
    if (id == null || id.isEmpty) {
      throw ArgumentError('Reminder id cannot be null or empty');
    }

    final title = map['title']?.toString();
    if (title == null || title.isEmpty) {
      throw ArgumentError('Reminder title cannot be null or empty');
    }

    DateTime dateTime;
    try {
      if (map['dateTime'] is String) {
        dateTime = DateTime.parse(map['dateTime']);
      } else if (map['dateTime'] is DateTime) {
        dateTime = map['dateTime'];
      } else {
        throw ArgumentError('Invalid dateTime format');
      }
    } catch (e) {
      throw ArgumentError('Failed to parse dateTime: ${map['dateTime']}');
    }

    DateTime createdAt;
    try {
      if (map['createdAt'] is String) {
        createdAt = DateTime.parse(map['createdAt']);
      } else if (map['createdAt'] is DateTime) {
        createdAt = map['createdAt'];
      } else {
        // Fallback to current time if createdAt is invalid
        createdAt = DateTime.now();
      }
    } catch (e) {
      // Fallback to current time if parsing fails
      createdAt = DateTime.now();
    }

    return Reminder(
      id: id,
      title: title,
      description: map['description']?.toString(), // Can be null
      dateTime: dateTime,
      isCompleted: map['isCompleted'] == true, // Safe boolean conversion
      createdAt: createdAt,
    );
  }

  // Safe factory method for creating from potentially unsafe data
  factory Reminder.safeFromMap(Map<String, dynamic>? map) {
    if (map == null) {
      throw ArgumentError('Cannot create Reminder from null map');
    }
    
    try {
      return Reminder.fromMap(map);
    } catch (e) {
      // Create a fallback reminder with minimal data
      final now = DateTime.now();
      return Reminder(
        id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: map['title']?.toString() ?? 'Untitled Reminder',
        description: map['description']?.toString(),
        dateTime: now,
        isCompleted: false,
        createdAt: now,
      );
    }
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Reminder(id: $id, title: $title, description: $description, dateTime: $dateTime, isCompleted: $isCompleted, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reminder &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.dateTime == dateTime &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        dateTime.hashCode ^
        isCompleted.hashCode ^
        createdAt.hashCode;
  }
}