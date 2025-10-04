/// Enum for reminder priority
enum ReminderPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case ReminderPriority.low:
        return 'Low';
      case ReminderPriority.medium:
        return 'Medium';
      case ReminderPriority.high:
        return 'High';
      case ReminderPriority.urgent:
        return 'Urgent';
    }
  }
}

/// Model class for Reminder
/// Represents a reminder/notification in the calendar
class Reminder {
  final String id;
  final String title;
  final String? description;
  final DateTime dateTime;
  final ReminderPriority priority;
  final bool isCompleted;
  final bool notificationEnabled;
  final DateTime? completedAt;

  Reminder({
    String? id,
    required this.title,
    this.description,
    required this.dateTime,
    this.priority = ReminderPriority.medium,
    this.isCompleted = false,
    this.notificationEnabled = true,
    this.completedAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  /// Get the date of this reminder (ignoring time)
  DateTime get reminderDate {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Check if reminder is today
  bool get isToday {
    final now = DateTime.now();
    return reminderDate.year == now.year &&
        reminderDate.month == now.month &&
        reminderDate.day == now.day;
  }

  /// Check if reminder is upcoming (within next 30 days)
  bool get isUpcoming {
    final now = DateTime.now();
    final difference = reminderDate.difference(now);
    return difference.inDays >= 0 && difference.inDays <= 30;
  }

  /// Check if reminder is overdue
  bool get isOverdue {
    if (isCompleted) return false;
    return dateTime.isBefore(DateTime.now());
  }

  /// Get days until this reminder
  int get daysUntil {
    final now = DateTime.now();
    return reminderDate.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  /// Get display text for days until
  String getDaysUntilText() {
    if (daysUntil == 0) return 'Today';
    if (daysUntil == 1) return 'Tomorrow';
    if (daysUntil > 0) return 'In $daysUntil days';
    if (isOverdue) return 'Overdue';
    return 'Passed';
  }

  /// Get formatted time
  String getFormattedTime() {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Copy with method
  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    ReminderPriority? priority,
    bool? isCompleted,
    bool? notificationEnabled,
    DateTime? completedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'priority': priority.name,
      'isCompleted': isCompleted,
      'notificationEnabled': notificationEnabled,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      dateTime: DateTime.parse(json['dateTime'] as String),
      priority: ReminderPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => ReminderPriority.medium,
      ),
      isCompleted: json['isCompleted'] as bool? ?? false,
      notificationEnabled: json['notificationEnabled'] as bool? ?? true,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reminder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Reminder(id: $id, title: $title, dateTime: $dateTime, priority: ${priority.name}, isCompleted: $isCompleted)';
  }
}