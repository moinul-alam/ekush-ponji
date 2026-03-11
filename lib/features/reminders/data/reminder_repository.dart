import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/reminders/models/reminder.dart';
import 'package:ekush_ponji/features/reminders/data/local/reminders_local_datasource.dart';

class ReminderRepository {
  final RemindersLocalDatasource _localDatasource;

  ReminderRepository({RemindersLocalDatasource? localDatasource})
      : _localDatasource = localDatasource ?? RemindersLocalDatasource();

  /// Save a new reminder
  Future<void> saveReminder(Reminder reminder) async {
    try {
      await _localDatasource.saveReminder(reminder);
    } catch (e) {
      debugPrint('❌ ReminderRepository: Error saving reminder: $e');
      rethrow;
    }
  }

  /// Update an existing reminder
  Future<void> updateReminder(Reminder reminder) async {
    try {
      await _localDatasource.updateReminder(reminder);
    } catch (e) {
      debugPrint('❌ ReminderRepository: Error updating reminder: $e');
      rethrow;
    }
  }

  /// Delete a reminder
  Future<void> deleteReminder(String id) async {
    try {
      await _localDatasource.deleteReminder(id);
    } catch (e) {
      debugPrint('❌ ReminderRepository: Error deleting reminder: $e');
      rethrow;
    }
  }

  /// Get all reminders
  Future<List<Reminder>> getAllReminders() async {
    try {
      return await _localDatasource.getAllReminders();
    } catch (e) {
      debugPrint('❌ ReminderRepository: Error getting all reminders: $e');
      return [];
    }
  }

  /// Get reminders for a specific date
  Future<List<Reminder>> getRemindersForDate(DateTime date) async {
    try {
      return await _localDatasource.getRemindersForDate(date);
    } catch (e) {
      debugPrint('❌ ReminderRepository: Error getting reminders for date: $e');
      return [];
    }
  }

  /// Get reminders for a specific month
  Future<List<Reminder>> getRemindersForMonth(int year, int month) async {
    try {
      return await _localDatasource.getRemindersForMonth(year, month);
    } catch (e) {
      debugPrint('❌ ReminderRepository: Error getting reminders for month: $e');
      return [];
    }
  }

  /// Get reminders for a list of dates
  Future<Map<DateTime, List<Reminder>>> getRemindersForDates(
      List<DateTime> dates) async {
    try {
      return await _localDatasource.getRemindersForDates(dates);
    } catch (e) {
      debugPrint('❌ ReminderRepository: Error getting reminders for dates: $e');
      return {for (final date in dates) date: []};
    }
  }

  /// Mark a reminder as completed
  Future<void> markCompleted(String id) async {
    try {
      await _localDatasource.markCompleted(id);
    } catch (e) {
      debugPrint('❌ ReminderRepository: Error marking completed: $e');
      rethrow;
    }
  }

  /// Get a single reminder by id
  Future<Reminder?> getReminderById(String id) async {
    try {
      return await _localDatasource.getReminderById(id);
    } catch (e) {
      debugPrint('❌ ReminderRepository: Error getting reminder by id: $e');
      return null;
    }
  }
}

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepository();
});
