import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekush_ponji/features/reminders/models/reminder.dart';

const String _remindersBoxName = 'reminders';

class RemindersLocalDatasource {
  Future<Box> get _box async => Hive.openBox(_remindersBoxName);

  /// Save a new reminder
  Future<void> saveReminder(Reminder reminder) async {
    try {
      final box = await _box;
      await box.put(reminder.id, reminder.toJson());
      debugPrint('✅ Reminder saved: ${reminder.title}');
    } catch (e) {
      debugPrint('❌ Error saving reminder: $e');
      rethrow;
    }
  }

  /// Update an existing reminder
  Future<void> updateReminder(Reminder reminder) async {
    try {
      final box = await _box;
      await box.put(reminder.id, reminder.toJson());
      debugPrint('✅ Reminder updated: ${reminder.title}');
    } catch (e) {
      debugPrint('❌ Error updating reminder: $e');
      rethrow;
    }
  }

  /// Delete a reminder by id
  Future<void> deleteReminder(String id) async {
    try {
      final box = await _box;
      await box.delete(id);
      debugPrint('✅ Reminder deleted: $id');
    } catch (e) {
      debugPrint('❌ Error deleting reminder: $e');
      rethrow;
    }
  }

  /// Get all reminders
  Future<List<Reminder>> getAllReminders() async {
    try {
      final box = await _box;
      return box.values
          .map((e) => Reminder.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting all reminders: $e');
      return [];
    }
  }

  /// Get reminders for a specific date
  Future<List<Reminder>> getRemindersForDate(DateTime date) async {
    try {
      final all = await getAllReminders();
      return all.where((reminder) {
        final reminderDate = DateTime(
          reminder.dateTime.year,
          reminder.dateTime.month,
          reminder.dateTime.day,
        );
        final target = DateTime(date.year, date.month, date.day);
        return reminderDate == target;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting reminders for date: $e');
      return [];
    }
  }

  /// Get reminders for a specific month
  Future<List<Reminder>> getRemindersForMonth(int year, int month) async {
    try {
      final all = await getAllReminders();
      return all.where((reminder) {
        return reminder.dateTime.year == year &&
            reminder.dateTime.month == month;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting reminders for month: $e');
      return [];
    }
  }

  /// Get reminders for a list of dates (used by CalendarViewModel grid)
  Future<Map<DateTime, List<Reminder>>> getRemindersForDates(
      List<DateTime> dates) async {
    try {
      final all = await getAllReminders();
      final Map<DateTime, List<Reminder>> map = {};

      for (final date in dates) {
        final target = DateTime(date.year, date.month, date.day);
        map[date] = all.where((reminder) {
          final reminderDate = DateTime(
            reminder.dateTime.year,
            reminder.dateTime.month,
            reminder.dateTime.day,
          );
          return reminderDate == target;
        }).toList();
      }

      return map;
    } catch (e) {
      debugPrint('❌ Error getting reminders for dates: $e');
      return {for (final date in dates) date: []};
    }
  }

  /// Mark reminder as completed
  Future<void> markCompleted(String id) async {
    try {
      final reminder = await getReminderById(id);
      if (reminder == null) return;
      final updated = reminder.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      await updateReminder(updated);
      debugPrint('✅ Reminder marked completed: $id');
    } catch (e) {
      debugPrint('❌ Error marking reminder completed: $e');
      rethrow;
    }
  }

  /// Get a single reminder by id
  Future<Reminder?> getReminderById(String id) async {
    try {
      final box = await _box;
      final data = box.get(id);
      if (data == null) return null;
      return Reminder.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      debugPrint('❌ Error getting reminder by id: $e');
      return null;
    }
  }
}
