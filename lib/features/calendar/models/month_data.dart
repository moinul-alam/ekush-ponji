import 'package:ekush_ponji/core/utils/number_converter.dart';
import 'package:ekush_ponji/features/calendar/models/calendar_day.dart';
import 'package:ekush_ponji/features/calendar/models/bengali_date.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/features/events/models/event.dart';
import 'package:ekush_ponji/features/reminders/models/reminder.dart';

/// Model class for a complete month's data
/// Contains all information needed to render a month in the calendar
class MonthData {
  final int gregorianYear;
  final int gregorianMonth;
  final List<BengaliMonth> bengaliMonths;
  final List<CalendarDay> days; // All 42 cells (6 rows × 7 days)
  final List<Holiday> holidays;
  final List<Event> events;
  final List<Reminder> reminders;

  MonthData({
    required this.gregorianYear,
    required this.gregorianMonth,
    required this.bengaliMonths,
    required this.days,
    this.holidays = const [],
    this.events = const [],
    this.reminders = const [],
  });

  /// Get the first date of this month
  DateTime get firstDate => DateTime(gregorianYear, gregorianMonth, 1);

  /// Get the last date of this month
  DateTime get lastDate {
    final nextMonth = gregorianMonth == 12 ? 1 : gregorianMonth + 1;
    final nextYear = gregorianMonth == 12 ? gregorianYear + 1 : gregorianYear;
    return DateTime(nextYear, nextMonth, 0);
  }

  /// Get month name in English
  String get monthName {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[gregorianMonth];
  }

  /// Get formatted month-year string (e.g., "January 2025")
  String get monthYearString => '$monthName $gregorianYear';

  /// Get Bengali month(s) display string
  /// If spanning two months: "Poush–Magh 1431" (with em dash)
  /// When [useBangla] is true, year is shown in Bengali numerals.
  String getBengaliMonthsDisplay({bool useBangla = false}) {
    if (bengaliMonths.isEmpty) return '';

    String yearStr(int y) =>
        useBangla ? NumberConverter.toBengali(y) : y.toString();

    if (bengaliMonths.length == 1) {
      final month = bengaliMonths.first;
      final name = useBangla ? month.nameBn : month.name;
      return '$name ${yearStr(month.year)}';
    }

    // Two months: use em dash separator
    final month1 = bengaliMonths.first;
    final month2 = bengaliMonths.last;
    final name1 = useBangla ? month1.nameBn : month1.name;
    final name2 = useBangla ? month2.nameBn : month2.name;
    return '$name1–$name2 ${yearStr(month1.year)}';
  }

  /// Get all days that belong to the current month (exclude prev/next month days)
  List<CalendarDay> get currentMonthDays {
    return days.where((day) => day.isCurrentMonth).toList();
  }

  /// Get days from previous month
  List<CalendarDay> get previousMonthDays {
    return days
        .where((day) =>
            !day.isCurrentMonth && day.gregorianDate.isBefore(firstDate))
        .toList();
  }

  /// Get days from next month
  List<CalendarDay> get nextMonthDays {
    return days
        .where(
            (day) => !day.isCurrentMonth && day.gregorianDate.isAfter(lastDate))
        .toList();
  }

  /// Get today's CalendarDay (if this month contains today)
  CalendarDay? get todayCell {
    return days.where((day) => day.isToday).firstOrNull;
  }

  /// Get selected day (if any)
  CalendarDay? get selectedDay {
    return days.where((day) => day.isSelected).firstOrNull;
  }

  /// Get upcoming holidays in this month
  List<Holiday> get upcomingHolidays {
    final now = DateTime.now();
    return holidays.where((h) => h.startDate.isAfter(now) || h.isToday).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  /// Get upcoming events in this month
  List<Event> get upcomingEvents {
    final now = DateTime.now();
    return events.where((e) => e.startTime.isAfter(now) || e.isToday).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Get upcoming reminders in this month
  List<Reminder> get upcomingReminders {
    final now = DateTime.now();
    return reminders
        .where((r) => (r.dateTime.isAfter(now) || r.isToday) && !r.isCompleted)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// Get total count of all items in this month
  int get totalItemsCount => holidays.length + events.length + reminders.length;

  /// Check if this month has any items
  bool get hasItems => totalItemsCount > 0;

  /// Copy with method
  MonthData copyWith({
    int? gregorianYear,
    int? gregorianMonth,
    List<BengaliMonth>? bengaliMonths,
    List<CalendarDay>? days,
    List<Holiday>? holidays,
    List<Event>? events,
    List<Reminder>? reminders,
  }) {
    return MonthData(
      gregorianYear: gregorianYear ?? this.gregorianYear,
      gregorianMonth: gregorianMonth ?? this.gregorianMonth,
      bengaliMonths: bengaliMonths ?? this.bengaliMonths,
      days: days ?? this.days,
      holidays: holidays ?? this.holidays,
      events: events ?? this.events,
      reminders: reminders ?? this.reminders,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'gregorianYear': gregorianYear,
      'gregorianMonth': gregorianMonth,
      'bengaliMonths': bengaliMonths.map((m) => m.toJson()).toList(),
      'days': days.map((d) => d.toJson()).toList(),
      'holidays': holidays.map((h) => h.toJson()).toList(),
      'events': events.map((e) => e.toJson()).toList(),
      'reminders': reminders.map((r) => r.toJson()).toList(),
    };
  }

  /// Create from JSON
  factory MonthData.fromJson(Map<String, dynamic> json) {
    return MonthData(
      gregorianYear: json['gregorianYear'] as int,
      gregorianMonth: json['gregorianMonth'] as int,
      bengaliMonths: (json['bengaliMonths'] as List<dynamic>)
          .map((m) => BengaliMonth.fromJson(m as Map<String, dynamic>))
          .toList(),
      days: (json['days'] as List<dynamic>)
          .map((d) => CalendarDay.fromJson(d as Map<String, dynamic>))
          .toList(),
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
  String toString() {
    return 'MonthData($monthYearString, days: ${days.length}, holidays: ${holidays.length}, events: ${events.length}, reminders: ${reminders.length})';
  }
}
