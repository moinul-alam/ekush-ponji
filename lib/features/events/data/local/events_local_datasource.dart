import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekush_ponji/features/events/models/event.dart';

const String _eventsBoxName = 'events';

class EventsLocalDatasource {
  Future<Box> get _box async => Hive.openBox(_eventsBoxName);

  /// Save a new event
  Future<void> saveEvent(Event event) async {
    try {
      final box = await _box;
      await box.put(event.id, event.toJson());
      debugPrint('✅ Event saved: ${event.title}');
    } catch (e) {
      debugPrint('❌ Error saving event: $e');
      rethrow;
    }
  }

  /// Update an existing event
  Future<void> updateEvent(Event event) async {
    try {
      final box = await _box;
      await box.put(event.id, event.toJson());
      debugPrint('✅ Event updated: ${event.title}');
    } catch (e) {
      debugPrint('❌ Error updating event: $e');
      rethrow;
    }
  }

  /// Delete an event by id
  Future<void> deleteEvent(String id) async {
    try {
      final box = await _box;
      await box.delete(id);
      debugPrint('✅ Event deleted: $id');
    } catch (e) {
      debugPrint('❌ Error deleting event: $e');
      rethrow;
    }
  }

  /// Get all events
  Future<List<Event>> getAllEvents() async {
    try {
      final box = await _box;
      return box.values
          .map((e) => Event.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting all events: $e');
      return [];
    }
  }

  /// Get events for a specific date
  Future<List<Event>> getEventsForDate(DateTime date) async {
    try {
      final all = await getAllEvents();
      return all.where((event) {
        final eventDate = DateTime(
          event.startTime.year,
          event.startTime.month,
          event.startTime.day,
        );
        final target = DateTime(date.year, date.month, date.day);
        return eventDate == target;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting events for date: $e');
      return [];
    }
  }

  /// Get events for a specific month
  Future<List<Event>> getEventsForMonth(int year, int month) async {
    try {
      final all = await getAllEvents();
      return all.where((event) {
        return event.startTime.year == year && event.startTime.month == month;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting events for month: $e');
      return [];
    }
  }

  /// Get events for a list of dates (used by CalendarViewModel grid)
  Future<Map<DateTime, List<Event>>> getEventsForDates(
      List<DateTime> dates) async {
    try {
      final all = await getAllEvents();
      final Map<DateTime, List<Event>> map = {};

      for (final date in dates) {
        final target = DateTime(date.year, date.month, date.day);
        map[date] = all.where((event) {
          final eventDate = DateTime(
            event.startTime.year,
            event.startTime.month,
            event.startTime.day,
          );
          return eventDate == target;
        }).toList();
      }

      return map;
    } catch (e) {
      debugPrint('❌ Error getting events for dates: $e');
      return {for (final date in dates) date: []};
    }
  }

  /// Get a single event by id
  Future<Event?> getEventById(String id) async {
    try {
      final box = await _box;
      final data = box.get(id);
      if (data == null) return null;
      return Event.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      debugPrint('❌ Error getting event by id: $e');
      return null;
    }
  }
}
