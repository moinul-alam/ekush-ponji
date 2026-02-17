import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/features/home/models/event.dart';
import 'package:ekush_ponji/features/home/models/reminder.dart';
import 'package:ekush_ponji/features/calendar/data/local/calendar_local_datasource.dart';
import 'package:ekush_ponji/features/calendar/data/remote/calendar_remote_datasource.dart';

/// CalendarRepository provides holidays, events, and reminders
/// Reads from local storage (Hive) for offline-first experience
class CalendarRepository {
  final CalendarLocalDatasource _localDatasource;
  final CalendarRemoteDatasource _remoteDatasource;

  CalendarRepository({
    CalendarLocalDatasource? localDatasource,
    CalendarRemoteDatasource? remoteDatasource,
  })  : _localDatasource = localDatasource ?? CalendarLocalDatasource(),
        _remoteDatasource = remoteDatasource ?? CalendarRemoteDatasource();

  // ------------------- Holiday Methods -------------------

  /// Get holidays for a specific month
  /// Reads from local storage (already synced from Firebase)
  Future<List<Holiday>> getHolidaysForMonth(int year, int month) async {
    try {
      // Get all holidays for the year from local storage
      final yearHolidays = await _localDatasource.getAllHolidaysForYear(year);
      
      // Filter by month
      final monthHolidays = yearHolidays
          .where((h) => h.date.month == month)
          .toList();

      debugPrint('📅 Found ${monthHolidays.length} holidays for $year-$month');
      return monthHolidays;
    } catch (e) {
      debugPrint('❌ Error getting holidays for month: $e');
      return [];
    }
  }

  /// Get holidays for a specific date
  Future<List<Holiday>> getHolidaysForDate(DateTime date) async {
    try {
      final monthHolidays = await getHolidaysForMonth(date.year, date.month);
      return monthHolidays
          .where((h) =>
              h.date.year == date.year &&
              h.date.month == date.month &&
              h.date.day == date.day)
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting holidays for date: $e');
      return [];
    }
  }

  /// Get holidays for multiple dates (optimized)
  Future<Map<DateTime, List<Holiday>>> getHolidaysForDates(
      List<DateTime> dates) async {
    final Map<DateTime, List<Holiday>> map = {};
    
    // Group dates by year-month for efficient fetching
    final Map<String, List<DateTime>> datesByMonth = {};
    for (final date in dates) {
      final key = '${date.year}-${date.month}';
      datesByMonth.putIfAbsent(key, () => []).add(date);
    }

    // Fetch holidays month by month
    for (final entry in datesByMonth.entries) {
      final parts = entry.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      
      final monthHolidays = await getHolidaysForMonth(year, month);
      
      // Map holidays to specific dates
      for (final date in entry.value) {
        map[date] = monthHolidays
            .where((h) => h.date.day == date.day)
            .toList();
      }
    }

    return map;
  }

  /// Get all holidays for a year
  Future<List<Holiday>> getHolidaysForYear(int year) async {
    try {
      return await _localDatasource.getAllHolidaysForYear(year);
    } catch (e) {
      debugPrint('❌ Error getting holidays for year: $e');
      return [];
    }
  }

  /// Get upcoming holidays (next 30 days)
  Future<List<Holiday>> getUpcomingHolidays({int days = 30}) async {
    try {
      final now = DateTime.now();
      final currentYear = now.year;
      final nextYear = currentYear + 1;

      // Get holidays for current and next year
      final currentYearHolidays = await getHolidaysForYear(currentYear);
      final nextYearHolidays = await getHolidaysForYear(nextYear);

      // Combine and filter upcoming
      final allHolidays = [...currentYearHolidays, ...nextYearHolidays];
      final upcoming = allHolidays.where((h) {
        final daysUntil = h.daysUntil;
        return daysUntil >= 0 && daysUntil <= days;
      }).toList();

      // Sort by date
      upcoming.sort((a, b) => a.date.compareTo(b.date));

      debugPrint('📅 Found ${upcoming.length} upcoming holidays');
      return upcoming;
    } catch (e) {
      debugPrint('❌ Error getting upcoming holidays: $e');
      return [];
    }
  }

  // ------------------- Custom Holiday Management -------------------

  /// Add a custom holiday
  Future<void> addCustomHoliday(Holiday holiday) async {
    try {
      await _localDatasource.addCustomHoliday(holiday);
      debugPrint('✅ Added custom holiday: ${holiday.name}');
    } catch (e) {
      debugPrint('❌ Error adding custom holiday: $e');
      rethrow;
    }
  }

  /// Delete a custom holiday
  Future<void> deleteCustomHoliday(String id) async {
    try {
      await _localDatasource.deleteCustomHoliday(id);
      debugPrint('✅ Deleted custom holiday: $id');
    } catch (e) {
      debugPrint('❌ Error deleting custom holiday: $e');
      rethrow;
    }
  }

  /// Edit a holiday (govt or custom)
  Future<void> editHoliday(Holiday holiday) async {
    try {
      if (holiday.isGovtHoliday) {
        // If govt holiday, save as modified
        await _localDatasource.saveModifiedHoliday(holiday);
        debugPrint('✅ Modified govt holiday: ${holiday.name}');
      } else {
        // If custom holiday, update in custom list
        final customHolidays = await _localDatasource.getCustomHolidays();
        final index = customHolidays.indexWhere((h) => h.id == holiday.id);
        if (index != -1) {
          customHolidays[index] = holiday;
          await _localDatasource.saveCustomHolidays(customHolidays);
          debugPrint('✅ Updated custom holiday: ${holiday.name}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error editing holiday: $e');
      rethrow;
    }
  }

  /// Hide a holiday
  Future<void> hideHoliday(String id) async {
    try {
      await _localDatasource.hideHoliday(id);
      debugPrint('✅ Hidden holiday: $id');
    } catch (e) {
      debugPrint('❌ Error hiding holiday: $e');
      rethrow;
    }
  }

  /// Unhide a holiday
  Future<void> unhideHoliday(String id) async {
    try {
      await _localDatasource.unhideHoliday(id);
      debugPrint('✅ Unhidden holiday: $id');
    } catch (e) {
      debugPrint('❌ Error unhiding holiday: $e');
      rethrow;
    }
  }

  // ------------------- Event Methods (Sample Data for now) -------------------

  Future<List<Event>> getEventsForMonth(int year, int month) async {
    return _getSampleEvents()
        .where((e) => e.startTime.year == year && e.startTime.month == month)
        .toList();
  }

  Future<List<Event>> getEventsForDate(DateTime date) async {
    final monthEvents = await getEventsForMonth(date.year, date.month);
    return monthEvents
        .where((e) =>
            e.startTime.year == date.year &&
            e.startTime.month == date.month &&
            e.startTime.day == date.day)
        .toList();
  }

  Future<Map<DateTime, List<Event>>> getEventsForDates(
      List<DateTime> dates) async {
    final Map<DateTime, List<Event>> map = {};
    for (final date in dates) {
      map[date] = await getEventsForDate(date);
    }
    return map;
  }

  // ------------------- Reminder Methods (Sample Data for now) -------------------

  Future<List<Reminder>> getRemindersForMonth(int year, int month) async {
    return _getSampleReminders()
        .where((r) => r.dateTime.year == year && r.dateTime.month == month)
        .toList();
  }

  Future<List<Reminder>> getRemindersForDate(DateTime date) async {
    final monthReminders = await getRemindersForMonth(date.year, date.month);
    return monthReminders
        .where((r) =>
            r.dateTime.year == date.year &&
            r.dateTime.month == date.month &&
            r.dateTime.day == date.day)
        .toList();
  }

  Future<Map<DateTime, List<Reminder>>> getRemindersForDates(
      List<DateTime> dates) async {
    final Map<DateTime, List<Reminder>> map = {};
    for (final date in dates) {
      map[date] = await getRemindersForDate(date);
    }
    return map;
  }

  // ------------------- Sample Data (to be replaced) -------------------

  List<Event> _getSampleEvents() {
    final now = DateTime.now();
    return [
      Event(
        title: "Team Meeting",
        description: "Weekly sync",
        startTime: now.add(const Duration(days: 1, hours: 10)),
        endTime: now.add(const Duration(days: 1, hours: 11)),
        category: EventCategory.work,
      ),
      Event(
        title: "Doctor Appointment",
        description: "Checkup",
        startTime: now.add(const Duration(days: 3, hours: 14)),
        endTime: now.add(const Duration(days: 3, hours: 15)),
        category: EventCategory.health,
      ),
    ];
  }

  List<Reminder> _getSampleReminders() {
    final now = DateTime.now();
    return [
      Reminder(
        title: "Pay Bills",
        description: "Electricity before 10th",
        dateTime: now.add(const Duration(days: 2, hours: 9)),
        priority: ReminderPriority.high,
      ),
      Reminder(
        title: "Buy Groceries",
        description: "Weekly shopping",
        dateTime: now.add(const Duration(days: 1, hours: 17)),
        priority: ReminderPriority.medium,
      ),
    ];
  }
}

/// Provider for CalendarRepository
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository();
});