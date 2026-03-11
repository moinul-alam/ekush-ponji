import 'package:ekush_ponji/features/calendar/models/bengali_date.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/features/events/models/event.dart';
import 'package:ekush_ponji/features/reminders/models/reminder.dart';

/// Model class for a single day cell in the calendar grid
/// Contains both Gregorian and Bengali date information
/// Plus associated holidays, events, and reminders
class CalendarDay {
  final DateTime gregorianDate;
  final BengaliDate bengaliDate;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final List<Holiday> holidays;
  final List<Event> events;
  final List<Reminder> reminders;

  CalendarDay({
    required this.gregorianDate,
    required this.bengaliDate,
    required this.isCurrentMonth,
    this.isToday = false,
    this.isSelected = false,
    this.holidays = const [],
    this.events = const [],
    this.reminders = const [],
  });

  // Computed properties for easy access

  /// Check if this day has any holidays
  bool get hasHoliday => holidays.isNotEmpty;

  /// Check if this day has any events
  bool get hasEvent => events.isNotEmpty;

  /// Check if this day has any reminders
  bool get hasReminder => reminders.isNotEmpty;

  /// Get total count of indicators (holidays + events + reminders)
  int get totalIndicators => holidays.length + events.length + reminders.length;

  /// Check if this day has any items (holidays, events, or reminders)
  bool get hasAnyItem => hasHoliday || hasEvent || hasReminder;

  /// Get the first holiday (if any)
  Holiday? get firstHoliday => holidays.isEmpty ? null : holidays.first;

  /// Get the first event (if any)
  Event? get firstEvent => events.isEmpty ? null : events.first;

  /// Get the first reminder (if any)
  Reminder? get firstReminder => reminders.isEmpty ? null : reminders.first;

  /// Get Gregorian day number (1-31)
  int get gregorianDay => gregorianDate.day;

  /// Get Bengali day number (1-31)
  int get bengaliDay => bengaliDate.day;

  /// Check if this is a weekend (Friday or Saturday in Bangladesh)
  bool get isWeekend {
    // In Bangladesh: Friday and Saturday are weekend
    return gregorianDate.weekday == DateTime.friday ||
        gregorianDate.weekday == DateTime.saturday;
  }

  /// Check if this day is in the past
  bool get isPast {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return gregorianDate.isBefore(today);
  }

  /// Check if this day is in the future
  bool get isFuture {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return gregorianDate.isAfter(today);
  }

  /// Get opacity for days from other months
  double get opacity => isCurrentMonth ? 1.0 : 0.4;

  /// Check if this is Pohela Boishakh (Bengali New Year)
  bool get isPohelaBoishakh => bengaliDate.isPohelaBoishakh;

  /// Copy with method
  CalendarDay copyWith({
    DateTime? gregorianDate,
    BengaliDate? bengaliDate,
    bool? isCurrentMonth,
    bool? isToday,
    bool? isSelected,
    List<Holiday>? holidays,
    List<Event>? events,
    List<Reminder>? reminders,
  }) {
    return CalendarDay(
      gregorianDate: gregorianDate ?? this.gregorianDate,
      bengaliDate: bengaliDate ?? this.bengaliDate,
      isCurrentMonth: isCurrentMonth ?? this.isCurrentMonth,
      isToday: isToday ?? this.isToday,
      isSelected: isSelected ?? this.isSelected,
      holidays: holidays ?? this.holidays,
      events: events ?? this.events,
      reminders: reminders ?? this.reminders,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'gregorianDate': gregorianDate.toIso8601String(),
      'bengaliDate': bengaliDate.toJson(),
      'isCurrentMonth': isCurrentMonth,
      'isToday': isToday,
      'isSelected': isSelected,
      'holidays': holidays.map((h) => h.toJson()).toList(),
      'events': events.map((e) => e.toJson()).toList(),
      'reminders': reminders.map((r) => r.toJson()).toList(),
    };
  }

  /// Create from JSON
  factory CalendarDay.fromJson(Map<String, dynamic> json) {
    return CalendarDay(
      gregorianDate: DateTime.parse(json['gregorianDate'] as String),
      bengaliDate:
          BengaliDate.fromJson(json['bengaliDate'] as Map<String, dynamic>),
      isCurrentMonth: json['isCurrentMonth'] as bool,
      isToday: json['isToday'] as bool? ?? false,
      isSelected: json['isSelected'] as bool? ?? false,
      holidays: (json['holidays'] as List<dynamic>?)
              ?.map((h) => Holiday.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reminders: (json['reminders'] as List<dynamic>?)
              ?.map((r) => Reminder.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarDay &&
        other.gregorianDate == gregorianDate &&
        other.isSelected == isSelected;
  }

  @override
  int get hashCode => Object.hash(gregorianDate, isSelected);

  @override
  String toString() {
    return 'CalendarDay(gregorian: ${gregorianDate.toIso8601String()}, bengali: ${bengaliDate.format()}, isToday: $isToday, hasItems: $hasAnyItem)';
  }
}
