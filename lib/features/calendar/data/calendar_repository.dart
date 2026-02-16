// lib/features/calendar/data/calendar_repository.dart

import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/features/home/models/event.dart';
import 'package:ekush_ponji/features/home/models/reminder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// CalendarRepository provides holidays, events, and reminders
/// Currently uses in-memory sample data (can be replaced with DB/API)
class CalendarRepository {
  // ------------------- Month-level methods -------------------

  Future<List<Holiday>> getHolidaysForMonth(int year, int month) async {
    return _getSampleHolidays()
        .where((h) => h.date.year == year && h.date.month == month)
        .toList();
  }

  Future<List<Event>> getEventsForMonth(int year, int month) async {
    return _getSampleEvents()
        .where((e) => e.startTime.year == year && e.startTime.month == month)
        .toList();
  }

  Future<List<Reminder>> getRemindersForMonth(int year, int month) async {
    return _getSampleReminders()
        .where((r) => r.dateTime.year == year && r.dateTime.month == month)
        .toList();
  }

  // ------------------- Date-level methods -------------------

  Future<List<Holiday>> getHolidaysForDate(DateTime date) async {
    final monthHolidays = await getHolidaysForMonth(date.year, date.month);
    return monthHolidays.where((h) =>
        h.date.year == date.year &&
        h.date.month == date.month &&
        h.date.day == date.day).toList();
  }

  Future<List<Event>> getEventsForDate(DateTime date) async {
    final monthEvents = await getEventsForMonth(date.year, date.month);
    return monthEvents.where((e) =>
        e.startTime.year == date.year &&
        e.startTime.month == date.month &&
        e.startTime.day == date.day).toList();
  }

  Future<List<Reminder>> getRemindersForDate(DateTime date) async {
    final monthReminders = await getRemindersForMonth(date.year, date.month);
    return monthReminders.where((r) =>
        r.dateTime.year == date.year &&
        r.dateTime.month == date.month &&
        r.dateTime.day == date.day).toList();
  }

  // ------------------- Multi-date fetch for optimization -------------------

  /// Returns a map: Date → List<Holiday>
  Future<Map<DateTime, List<Holiday>>> getHolidaysForDates(List<DateTime> dates) async {
    final Map<DateTime, List<Holiday>> map = {};
    for (final date in dates) {
      map[date] = await getHolidaysForDate(date);
    }
    return map;
  }

  /// Returns a map: Date → List<Event>
  Future<Map<DateTime, List<Event>>> getEventsForDates(List<DateTime> dates) async {
    final Map<DateTime, List<Event>> map = {};
    for (final date in dates) {
      map[date] = await getEventsForDate(date);
    }
    return map;
  }

  /// Returns a map: Date → List<Reminder>
  Future<Map<DateTime, List<Reminder>>> getRemindersForDates(List<DateTime> dates) async {
    final Map<DateTime, List<Reminder>> map = {};
    for (final date in dates) {
      map[date] = await getRemindersForDate(date);
    }
    return map;
  }

  // ------------------- Sample Data -------------------

  List<Holiday> _getSampleHolidays() {
    return [
      Holiday(name: "New Year", namebn: "নতুন বছর", date: DateTime(2025, 1, 1), type: HolidayType.national, description: "First day of the year", descriptionbn: "বছরের প্রথম দিন"),
      Holiday(name: "Pohela Boishakh", namebn: "পহেলা বৈশাখ", date: DateTime(2026, 2, 9), type: HolidayType.cultural, description: "Bengali New Year", descriptionbn: "বাংলা নববর্ষ"),
      Holiday(name: "Independence Day", namebn: "স্বাধীনতা দিবস", date: DateTime(2026, 2, 12), type: HolidayType.national, description: "Bangladesh Independence", descriptionbn: "বাংলাদেশের স্বাধীনতা"),
    ];
  }

  List<Event> _getSampleEvents() {
    final now = DateTime.now();
    return [
      Event(title: "Team Meeting", description: "Weekly sync", startTime: now.add(const Duration(days: 1, hours: 10)), endTime: now.add(const Duration(days: 1, hours: 11)), category: EventCategory.work),
      Event(title: "Doctor Appointment", description: "Checkup", startTime: now.add(const Duration(days: 3, hours: 14)), endTime: now.add(const Duration(days: 3, hours: 15)), category: EventCategory.health),
    ];
  }

  List<Reminder> _getSampleReminders() {
    final now = DateTime.now();
    return [
      Reminder(title: "Pay Bills", description: "Electricity before 10th", dateTime: now.add(const Duration(days: 2, hours: 9)), priority: ReminderPriority.high),
      Reminder(title: "Buy Groceries", description: "Weekly shopping", dateTime: now.add(const Duration(days: 1, hours: 17)), priority: ReminderPriority.medium),
    ];
  }
}

/// Provider for CalendarRepository
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository();
});
