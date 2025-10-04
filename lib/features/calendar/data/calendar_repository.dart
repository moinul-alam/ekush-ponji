import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/features/home/models/event.dart';
import 'package:ekush_ponji/features/home/models/reminder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mock repository for calendar data
/// This will be replaced with actual API/database implementation later
/// Provides sample data for holidays, events, and reminders
class CalendarRepository {
  /// Get holidays for a specific month
  Future<List<Holiday>> getHolidaysForMonth(int year, int month) async {
    // Simulate network delay
    // await Future.delayed(const Duration(milliseconds: 300));

    // Return sample holidays
    return _getSampleHolidays()
        .where((h) => h.date.year == year && h.date.month == month)
        .toList();
  }

  /// Get events for a specific month
  Future<List<Event>> getEventsForMonth(int year, int month) async {
    // Simulate network delay
    // await Future.delayed(const Duration(milliseconds: 300));

    // Return sample events
    return _getSampleEvents()
        .where((e) => e.startTime.year == year && e.startTime.month == month)
        .toList();
  }

  /// Get reminders for a specific month
  Future<List<Reminder>> getRemindersForMonth(int year, int month) async {
    // Simulate network delay
    // await Future.delayed(const Duration(milliseconds: 300));

    // Return sample reminders
    return _getSampleReminders()
        .where((r) => r.dateTime.year == year && r.dateTime.month == month)
        .toList();
  }

  /// Get holidays for a specific date
  Future<List<Holiday>> getHolidaysForDate(DateTime date) async {
    final holidays = await getHolidaysForMonth(date.year, date.month);
    return holidays
        .where((h) =>
            h.date.year == date.year &&
            h.date.month == date.month &&
            h.date.day == date.day)
        .toList();
  }

  /// Get events for a specific date
  Future<List<Event>> getEventsForDate(DateTime date) async {
    final events = await getEventsForMonth(date.year, date.month);
    return events.where((e) {
      final eventDate = DateTime(
        e.startTime.year,
        e.startTime.month,
        e.startTime.day,
      );
      return eventDate.year == date.year &&
          eventDate.month == date.month &&
          eventDate.day == date.day;
    }).toList();
  }

  /// Get reminders for a specific date
  Future<List<Reminder>> getRemindersForDate(DateTime date) async {
    final reminders = await getRemindersForMonth(date.year, date.month);
    return reminders.where((r) {
      final reminderDate = DateTime(
        r.dateTime.year,
        r.dateTime.month,
        r.dateTime.day,
      );
      return reminderDate.year == date.year &&
          reminderDate.month == date.month &&
          reminderDate.day == date.day;
    }).toList();
  }

  // ==================== Sample Data Methods ====================

  /// Generate sample holidays for 2025
  List<Holiday> _getSampleHolidays() {
    return [
      // January 2025
      Holiday(
        name: 'New Year\'s Day',
        namebn: 'নববর্ষ দিবস',
        date: DateTime(2025, 1, 1),
        type: HolidayType.national,
        description: 'First day of the year',
        descriptionbn: 'বছরের প্রথম দিন',
      ),

      // February 2025
      Holiday(
        name: 'Shaheed Day',
        namebn: 'শহীদ দিবস',
        date: DateTime(2025, 2, 21),
        type: HolidayType.national,
        description: 'International Mother Language Day',
        descriptionbn: 'আন্তর্জাতিক মাতৃভাষা দিবস',
      ),

      // March 2025
      Holiday(
        name: 'Independence Day',
        namebn: 'স্বাধীনতা দিবস',
        date: DateTime(2025, 3, 26),
        type: HolidayType.national,
        description: 'Celebrates independence of Bangladesh',
        descriptionbn: 'বাংলাদেশের স্বাধীনতা উদযাপন',
      ),
      Holiday(
        name: 'Shab-e-Barat',
        namebn: 'শবে বরাত',
        date: DateTime(2025, 3, 15),
        type: HolidayType.religious,
        description: 'Night of Fortune',
        descriptionbn: 'ভাগ্য রজনী',
      ),

      // April 2025
      Holiday(
        name: 'Pohela Boishakh',
        namebn: 'পহেলা বৈশাখ',
        date: DateTime(2025, 4, 14),
        type: HolidayType.cultural,
        description: 'Bengali New Year 1432',
        descriptionbn: 'বাংলা নববর্ষ ১৪৩২',
      ),
      Holiday(
        name: 'Good Friday',
        namebn: 'গুড ফ্রাইডে',
        date: DateTime(2025, 4, 18),
        type: HolidayType.religious,
        description: 'Christian holy day',
        descriptionbn: 'খ্রিস্টান পবিত্র দিবস',
      ),

      // May 2025
      Holiday(
        name: 'May Day',
        namebn: 'মে দিবস',
        date: DateTime(2025, 5, 1),
        type: HolidayType.national,
        description: 'International Workers\' Day',
        descriptionbn: 'আন্তর্জাতিক শ্রমিক দিবস',
      ),
      Holiday(
        name: 'Buddha Purnima',
        namebn: 'বুদ্ধ পূর্ণিমা',
        date: DateTime(2025, 5, 12),
        type: HolidayType.religious,
        description: 'Birth of Buddha',
        descriptionbn: 'বুদ্ধের জন্ম',
      ),

      // August 2025
      Holiday(
        name: 'National Mourning Day',
        namebn: 'জাতীয় শোক দিবস',
        date: DateTime(2025, 8, 15),
        type: HolidayType.national,
        description: 'Remembering Bangabandhu',
        descriptionbn: 'বঙ্গবন্ধুকে স্মরণ',
      ),

      // October 2025
      Holiday(
        name: 'Durga Puja',
        namebn: 'দুর্গা পূজা',
        date: DateTime(2025, 10, 2),
        type: HolidayType.religious,
        description: 'Hindu festival',
        descriptionbn: 'হিন্দু উৎসব',
      ),

      // December 2025
      Holiday(
        name: 'Victory Day',
        namebn: 'বিজয় দিবস',
        date: DateTime(2025, 12, 16),
        type: HolidayType.national,
        description: 'Celebrates victory in Liberation War',
        descriptionbn: 'মুক্তিযুদ্ধে বিজয় উদযাপন',
      ),
      Holiday(
        name: 'Christmas',
        namebn: 'ক্রিসমাস',
        date: DateTime(2025, 12, 25),
        type: HolidayType.religious,
        description: 'Christian celebration',
        descriptionbn: 'খ্রিস্টান উৎসব',
      ),
    ];
  }

  /// Generate sample events for October 2025
  List<Event> _getSampleEvents() {
    final now = DateTime.now();
    return [
      Event(
        title: 'Team Meeting',
        description: 'Weekly team sync-up',
        startTime: DateTime(now.year, now.month, now.day + 1, 10, 0),
        endTime: DateTime(now.year, now.month, now.day + 1, 11, 0),
        location: 'Conference Room A',
        category: EventCategory.work,
      ),
      Event(
        title: 'Doctor Appointment',
        description: 'Regular checkup',
        startTime: DateTime(now.year, now.month, now.day + 3, 14, 30),
        endTime: DateTime(now.year, now.month, now.day + 3, 15, 30),
        location: 'City Hospital',
        category: EventCategory.health,
      ),
      Event(
        title: 'Birthday Party',
        description: 'Friend\'s birthday celebration',
        startTime: DateTime(now.year, now.month, now.day + 5, 18, 0),
        endTime: DateTime(now.year, now.month, now.day + 5, 21, 0),
        location: 'Home',
        category: EventCategory.personal,
      ),
      Event(
        title: 'Project Deadline',
        description: 'Submit final report',
        startTime: DateTime(now.year, now.month, now.day + 7, 17, 0),
        isAllDay: true,
        category: EventCategory.work,
      ),
      Event(
        title: 'Family Dinner',
        description: 'Monthly family gathering',
        startTime: DateTime(now.year, now.month, now.day + 10, 19, 0),
        endTime: DateTime(now.year, now.month, now.day + 10, 22, 0),
        location: 'Restaurant',
        category: EventCategory.family,
      ),
    ];
  }

  /// Generate sample reminders for October 2025
  List<Reminder> _getSampleReminders() {
    final now = DateTime.now();
    return [
      Reminder(
        title: 'Pay electricity bill',
        description: 'Before 10th of the month',
        dateTime: DateTime(now.year, now.month, now.day + 2, 9, 0),
        priority: ReminderPriority.high,
      ),
      Reminder(
        title: 'Buy groceries',
        description: 'Weekly shopping',
        dateTime: DateTime(now.year, now.month, now.day + 1, 17, 0),
        priority: ReminderPriority.medium,
      ),
      Reminder(
        title: 'Call mom',
        dateTime: DateTime(now.year, now.month, now.day + 4, 20, 0),
        priority: ReminderPriority.low,
      ),
      Reminder(
        title: 'Submit report',
        description: 'Quarterly performance report',
        dateTime: DateTime(now.year, now.month, now.day + 6, 16, 0),
        priority: ReminderPriority.urgent,
      ),
      Reminder(
        title: 'Renew insurance',
        description: 'Health insurance renewal',
        dateTime: DateTime(now.year, now.month, now.day + 15, 10, 0),
        priority: ReminderPriority.high,
      ),
    ];
  }
}

/// Provider for CalendarRepository
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository();
});
