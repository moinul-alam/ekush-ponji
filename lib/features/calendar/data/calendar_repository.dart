// lib/features/calendar/data/repositories/calendar_repository.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/features/home/models/event.dart';
import 'package:ekush_ponji/features/home/models/reminder.dart';
import 'package:ekush_ponji/features/calendar/data/local/calendar_local_datasource.dart';
import 'package:ekush_ponji/features/calendar/data/remote/calendar_remote_datasource.dart';
import 'package:ekush_ponji/features/events/data/local/events_local_datasource.dart';
import 'package:ekush_ponji/features/reminders/data/local/reminders_local_datasource.dart';
import 'package:ekush_ponji/core/services/holiday_sync_service.dart';

/// CalendarRepository provides holidays, events, and reminders.
/// Offline-first: always reads from Hive.
/// Sync is fully delegated to HolidaySyncService (GitHub → Hive).
class CalendarRepository {
  final CalendarLocalDatasource _localDatasource;
  final CalendarRemoteDatasource _remoteDatasource;
  final EventsLocalDatasource _eventsLocalDatasource;
  final RemindersLocalDatasource _remindersLocalDatasource;
  final HolidaySyncService _syncService;

  CalendarRepository({
    CalendarLocalDatasource? localDatasource,
    CalendarRemoteDatasource? remoteDatasource,
    EventsLocalDatasource? eventsLocalDatasource,
    RemindersLocalDatasource? remindersLocalDatasource,
    HolidaySyncService? syncService,
  })  : _localDatasource = localDatasource ?? CalendarLocalDatasource(),
        _remoteDatasource =
            remoteDatasource ?? CalendarRemoteDatasource(),
        _eventsLocalDatasource =
            eventsLocalDatasource ?? EventsLocalDatasource(),
        _remindersLocalDatasource =
            remindersLocalDatasource ?? RemindersLocalDatasource(),
        _syncService = syncService ?? HolidaySyncService();

  // ------------------- Sync -------------------

  /// Delegates entirely to HolidaySyncService.
  /// HolidaySyncService handles throttling, versioning,
  /// GitHub fetch, and Hive writes internally.
  Future<void> syncHolidaysIfNeeded(int year) async {
    try {
      debugPrint('🔄 CalendarRepository: triggering sync for $year...');
      await _syncService.initialize();
      debugPrint('✅ CalendarRepository: sync complete for $year');
    } catch (e) {
      debugPrint('⚠️ CalendarRepository: sync failed, serving cache: $e');
    }
  }

  // ------------------- Holiday Methods -------------------

  Future<List<Holiday>> getHolidaysForMonth(int year, int month) async {
    try {
      final yearHolidays =
          await _localDatasource.getAllHolidaysForYear(year);

      final monthHolidays = yearHolidays.where((h) {
        if (!h.isMultiDay) {
          return h.startDate.year == year && h.startDate.month == month;
        }
        final monthStart = DateTime(year, month, 1);
        final monthEnd = DateTime(year, month + 1, 0);
        final startDay = DateTime(
            h.startDate.year, h.startDate.month, h.startDate.day);
        final endDay = DateTime(
            h.endDate!.year, h.endDate!.month, h.endDate!.day);
        return !endDay.isBefore(monthStart) && !startDay.isAfter(monthEnd);
      }).toList();

      debugPrint(
          '📅 Found ${monthHolidays.length} holidays for $year-$month');
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

      upcoming.sort((a, b) => a.startDate.compareTo(b.startDate));
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
      if (holiday.isMandatory) {
        await _localDatasource.saveModifiedHoliday(holiday);
        debugPrint('✅ Modified govt holiday: ${holiday.name}');
      } else {
        final customHolidays = await _localDatasource.getCustomHolidays();
        final index =
            customHolidays.indexWhere((h) => h.id == holiday.id);
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
      debugPrint(
          '❌ CalendarRepository: Error getting events for month: $e');
      return [];
    }
  }

  Future<List<Event>> getEventsForDate(DateTime date) async {
    try {
      return await _eventsLocalDatasource.getEventsForDate(date);
    } catch (e) {
      debugPrint(
          '❌ CalendarRepository: Error getting events for date: $e');
      return [];
    }
  }

  Future<Map<DateTime, List<Event>>> getEventsForDates(
      List<DateTime> dates) async {
    try {
      return await _eventsLocalDatasource.getEventsForDates(dates);
    } catch (e) {
      debugPrint(
          '❌ CalendarRepository: Error getting events for dates: $e');
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