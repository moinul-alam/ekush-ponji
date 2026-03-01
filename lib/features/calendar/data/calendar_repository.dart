import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/features/home/models/event.dart';
import 'package:ekush_ponji/features/home/models/reminder.dart';
import 'package:ekush_ponji/features/calendar/data/local/calendar_local_datasource.dart';
import 'package:ekush_ponji/features/calendar/data/remote/calendar_remote_datasource.dart';
import 'package:ekush_ponji/features/events/data/local/events_local_datasource.dart';
import 'package:ekush_ponji/features/reminders/data/local/reminders_local_datasource.dart';

/// CalendarRepository provides holidays, events, and reminders
/// Offline-first: reads from Hive, syncs from Firestore on startup
class CalendarRepository {
  final CalendarLocalDatasource _localDatasource;
  final CalendarRemoteDatasource _remoteDatasource;
  final EventsLocalDatasource _eventsLocalDatasource;
  final RemindersLocalDatasource _remindersLocalDatasource;

  CalendarRepository({
    CalendarLocalDatasource? localDatasource,
    CalendarRemoteDatasource? remoteDatasource,
    EventsLocalDatasource? eventsLocalDatasource,
    RemindersLocalDatasource? remindersLocalDatasource,
  })  : _localDatasource = localDatasource ?? CalendarLocalDatasource(),
        _remoteDatasource = remoteDatasource ?? CalendarRemoteDatasource(),
        _eventsLocalDatasource =
            eventsLocalDatasource ?? EventsLocalDatasource(),
        _remindersLocalDatasource =
            remindersLocalDatasource ?? RemindersLocalDatasource();

  // ------------------- Sync -------------------

  Future<void> syncHolidaysIfNeeded(int year) async {
    try {
      final remoteLastUpdated =
          await _remoteDatasource.getLastUpdatedTimestamp(year);

      if (remoteLastUpdated == null) {
        debugPrint('ℹ️ No remote holidays found for $year');
        return;
      }

      final localLastUpdated = await _localDatasource.getLastUpdated(year);

      if (localLastUpdated != null &&
          remoteLastUpdated.isAtSameMomentAs(localLastUpdated)) {
        debugPrint('✅ Holidays for $year are up to date, skipping sync');
        return;
      }

      debugPrint('🔄 Syncing holidays for $year...');
      final holidays = await _remoteDatasource.fetchGovtHolidays(year);
      await _localDatasource.saveGovtHolidays(year, holidays);
      await _localDatasource.saveLastUpdated(year, remoteLastUpdated);
      debugPrint('✅ Synced ${holidays.length} holidays for $year');
    } catch (e) {
      debugPrint('⚠️ Sync failed, serving cache: $e');
    }
  }

  // ------------------- Holiday Methods -------------------

  Future<List<Holiday>> getHolidaysForMonth(int year, int month) async {
    try {
      final yearHolidays = await _localDatasource.getAllHolidaysForYear(year);

      final monthHolidays = yearHolidays.where((h) {
        if (!h.isMultiDay) {
          return h.date.year == year && h.date.month == month;
        }
        final monthStart = DateTime(year, month, 1);
        final monthEnd = DateTime(year, month + 1, 0);
        final startDay = DateTime(h.date.year, h.date.month, h.date.day);
        final endDay =
            DateTime(h.endDate!.year, h.endDate!.month, h.endDate!.day);
        return !endDay.isBefore(monthStart) && !startDay.isAfter(monthEnd);
      }).toList();

      debugPrint('📅 Found ${monthHolidays.length} holidays for $year-$month');
      return monthHolidays;
    } catch (e) {
      debugPrint('❌ Error getting holidays for month: $e');
      return [];
    }
  }

  Future<List<Holiday>> getHolidaysForDate(DateTime date) async {
    try {
      final monthHolidays =
          await getHolidaysForMonth(date.year, date.month);
      return monthHolidays.where((h) => h.containsDate(date)).toList();
    } catch (e) {
      debugPrint('❌ Error getting holidays for date: $e');
      return [];
    }
  }

  Future<Map<DateTime, List<Holiday>>> getHolidaysForDates(
      List<DateTime> dates) async {
    final Map<DateTime, List<Holiday>> map = {};
    final Map<String, List<DateTime>> datesByMonth = {};

    for (final date in dates) {
      final key = '${date.year}-${date.month}';
      datesByMonth.putIfAbsent(key, () => []).add(date);
    }

    for (final entry in datesByMonth.entries) {
      final parts = entry.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final monthHolidays = await getHolidaysForMonth(year, month);

      for (final date in entry.value) {
        map[date] =
            monthHolidays.where((h) => h.containsDate(date)).toList();
      }
    }

    return map;
  }

  Future<List<Holiday>> getHolidaysForYear(int year) async {
    try {
      return await _localDatasource.getAllHolidaysForYear(year);
    } catch (e) {
      debugPrint('❌ Error getting holidays for year: $e');
      return [];
    }
  }

  Future<List<Holiday>> getUpcomingHolidays({int days = 30}) async {
    try {
      final now = DateTime.now();
      final currentYear = now.year;
      final nextYear = currentYear + 1;

      final currentYearHolidays = await getHolidaysForYear(currentYear);
      final nextYearHolidays = await getHolidaysForYear(nextYear);

      final allHolidays = [...currentYearHolidays, ...nextYearHolidays];
      final upcoming = allHolidays.where((h) {
        final daysUntil = h.daysUntil;
        return daysUntil >= 0 && daysUntil <= days;
      }).toList();

      upcoming.sort((a, b) => a.date.compareTo(b.date));
      debugPrint('📅 Found ${upcoming.length} upcoming holidays');
      return upcoming;
    } catch (e) {
      debugPrint('❌ Error getting upcoming holidays: $e');
      return [];
    }
  }

  // ------------------- Custom Holiday Management -------------------

  Future<void> addCustomHoliday(Holiday holiday) async {
    try {
      await _localDatasource.addCustomHoliday(holiday);
      debugPrint('✅ Added custom holiday: ${holiday.name}');
    } catch (e) {
      debugPrint('❌ Error adding custom holiday: $e');
      rethrow;
    }
  }

  Future<void> deleteCustomHoliday(String id) async {
    try {
      await _localDatasource.deleteCustomHoliday(id);
      debugPrint('✅ Deleted custom holiday: $id');
    } catch (e) {
      debugPrint('❌ Error deleting custom holiday: $e');
      rethrow;
    }
  }

  Future<void> editHoliday(Holiday holiday) async {
    try {
      if (holiday.isGovtHoliday) {
        await _localDatasource.saveModifiedHoliday(holiday);
        debugPrint('✅ Modified govt holiday: ${holiday.name}');
      } else {
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

  Future<void> hideHoliday(String id) async {
    try {
      await _localDatasource.hideHoliday(id);
      debugPrint('✅ Hidden holiday: $id');
    } catch (e) {
      debugPrint('❌ Error hiding holiday: $e');
      rethrow;
    }
  }

  Future<void> unhideHoliday(String id) async {
    try {
      await _localDatasource.unhideHoliday(id);
      debugPrint('✅ Unhidden holiday: $id');
    } catch (e) {
      debugPrint('❌ Error unhiding holiday: $e');
      rethrow;
    }
  }

  // ------------------- Event Methods -------------------

  Future<List<Event>> getEventsForMonth(int year, int month) async {
    try {
      return await _eventsLocalDatasource.getEventsForMonth(year, month);
    } catch (e) {
      debugPrint('❌ CalendarRepository: Error getting events for month: $e');
      return [];
    }
  }

  Future<List<Event>> getEventsForDate(DateTime date) async {
    try {
      return await _eventsLocalDatasource.getEventsForDate(date);
    } catch (e) {
      debugPrint('❌ CalendarRepository: Error getting events for date: $e');
      return [];
    }
  }

  Future<Map<DateTime, List<Event>>> getEventsForDates(
      List<DateTime> dates) async {
    try {
      return await _eventsLocalDatasource.getEventsForDates(dates);
    } catch (e) {
      debugPrint('❌ CalendarRepository: Error getting events for dates: $e');
      return {for (final date in dates) date: []};
    }
  }

  // ------------------- Reminder Methods -------------------

  Future<List<Reminder>> getRemindersForMonth(int year, int month) async {
    try {
      return await _remindersLocalDatasource.getRemindersForMonth(
          year, month);
    } catch (e) {
      debugPrint(
          '❌ CalendarRepository: Error getting reminders for month: $e');
      return [];
    }
  }

  Future<List<Reminder>> getRemindersForDate(DateTime date) async {
    try {
      return await _remindersLocalDatasource.getRemindersForDate(date);
    } catch (e) {
      debugPrint(
          '❌ CalendarRepository: Error getting reminders for date: $e');
      return [];
    }
  }

  Future<Map<DateTime, List<Reminder>>> getRemindersForDates(
      List<DateTime> dates) async {
    try {
      return await _remindersLocalDatasource.getRemindersForDates(dates);
    } catch (e) {
      debugPrint(
          '❌ CalendarRepository: Error getting reminders for dates: $e');
      return {for (final date in dates) date: []};
    }
  }
}

/// Provider for CalendarRepository
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository();
});