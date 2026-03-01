/// Enum for event categories
enum EventCategory {
  work,
  personal,
  family,
  health,
  education,
  social,
  other;

  String get displayName {
    switch (this) {
      case EventCategory.work:
        return 'Work';
      case EventCategory.personal:
        return 'Personal';
      case EventCategory.family:
        return 'Family';
      case EventCategory.health:
        return 'Health';
      case EventCategory.education:
        return 'Education';
      case EventCategory.social:
        return 'Social';
      case EventCategory.other:
        return 'Other';
    }
  }
}

/// Model class for Event
/// Represents a user-created event in the calendar
class Event {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  final EventCategory category;
  final bool isAllDay;
  final String? notes;
  final List<String>? attendees;
  final bool notifyAtStartTime;

  Event({
    String? id,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    this.location,
    this.category = EventCategory.personal,
    this.isAllDay = false,
    this.notes,
    this.attendees,
    this.notifyAtStartTime = true,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  /// Get the date of this event (ignoring time)
  DateTime get eventDate {
    return DateTime(startTime.year, startTime.month, startTime.day);
  }

  /// Check if event is today
  bool get isToday {
    final now = DateTime.now();
    return eventDate.year == now.year &&
        eventDate.month == now.month &&
        eventDate.day == now.day;
  }

  /// Check if event is upcoming (within next 30 days)
  bool get isUpcoming {
    final now = DateTime.now();
    final difference = eventDate.difference(now);
    return difference.inDays >= 0 && difference.inDays <= 30;
  }

  /// Get days until this event
  int get daysUntil {
    final now = DateTime.now();
    return eventDate.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  /// Get display text for days until
  String getDaysUntilText() {
    if (daysUntil == 0) return 'Today';
    if (daysUntil == 1) return 'Tomorrow';
    if (daysUntil > 0) return 'In $daysUntil days';
    return 'Passed';
  }

  /// Get duration in hours
  int? get durationInHours {
    if (endTime == null) return null;
    return endTime!.difference(startTime).inHours;
  }

  /// Get formatted time range
  String getTimeRange() {
    if (isAllDay) return 'All day';
    final startHour = startTime.hour.toString().padLeft(2, '0');
    final startMinute = startTime.minute.toString().padLeft(2, '0');
    if (endTime == null) return '$startHour:$startMinute';

    final endHour = endTime!.hour.toString().padLeft(2, '0');
    final endMinute = endTime!.minute.toString().padLeft(2, '0');
    return '$startHour:$startMinute - $endHour:$endMinute';
  }

  /// Copy with method
  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    EventCategory? category,
    bool? isAllDay,
    String? notes,
    List<String>? attendees,
    bool? notifyAtStartTime,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      category: category ?? this.category,
      isAllDay: isAllDay ?? this.isAllDay,
      notes: notes ?? this.notes,
      attendees: attendees ?? this.attendees,
      notifyAtStartTime: notifyAtStartTime ?? this.notifyAtStartTime,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'location': location,
      'category': category.name,
      'isAllDay': isAllDay,
      'notes': notes,
      'attendees': attendees,
      'notifyAtStartTime': notifyAtStartTime,
    };
  }

  /// Create from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      location: json['location'] as String?,
      category: EventCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => EventCategory.personal,
      ),
      isAllDay: json['isAllDay'] as bool? ?? false,
      notes: json['notes'] as String?,
      attendees: (json['attendees'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      notifyAtStartTime: json['notifyAtStartTime'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Event(id: $id, title: $title, startTime: $startTime, category: ${category.name})';
  }
}