import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekush_ponji/data/models/reminder.dart';
import 'package:ekush_ponji/constants/constants.dart';

class ReminderService {
  late Box<Reminder> _remindersBox;

  ReminderService() {
    _remindersBox = Hive.box<Reminder>(AppConstants.remindersBoxName);
  }

  // Add a new reminder
  Future<void> addReminder(Reminder reminder) async {
    await _remindersBox.put(reminder.id, reminder);
  }

  // Get all reminders
  List<Reminder> getAllReminders() {
    return _remindersBox.values.toList();
  }

  // Get upcoming reminders
  List<Reminder> getUpcomingReminders() {
    final now = DateTime.now();
    return _remindersBox.values
        .where((reminder) => reminder.dateTime.isAfter(now) && !reminder.isCompleted)
        .toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  // Get today's reminders
  List<Reminder> getTodayReminders() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _remindersBox.values
        .where((reminder) => 
            reminder.dateTime.isAfter(today) && 
            reminder.dateTime.isBefore(tomorrow))
        .toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  // Update reminder
  Future<void> updateReminder(Reminder reminder) async {
    await _remindersBox.put(reminder.id, reminder);
  }

  // Delete reminder
  Future<void> deleteReminder(String id) async {
    await _remindersBox.delete(id);
  }

  // Mark as completed
  Future<void> markAsCompleted(String id) async {
    final reminder = _remindersBox.get(id);
    if (reminder != null) {
      reminder.isCompleted = true;
      await _remindersBox.put(id, reminder);
    }
  }
}