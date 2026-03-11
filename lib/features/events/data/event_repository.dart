import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/events/models/event.dart';
import 'package:ekush_ponji/features/events/data/local/events_local_datasource.dart';

class EventRepository {
  final EventsLocalDatasource _localDatasource;

  EventRepository({EventsLocalDatasource? localDatasource})
      : _localDatasource = localDatasource ?? EventsLocalDatasource();

  /// Save a new event
  Future<void> saveEvent(Event event) async {
    try {
      await _localDatasource.saveEvent(event);
    } catch (e) {
      debugPrint('❌ EventRepository: Error saving event: $e');
      rethrow;
    }
  }

  /// Update an existing event
  Future<void> updateEvent(Event event) async {
    try {
      await _localDatasource.updateEvent(event);
    } catch (e) {
      debugPrint('❌ EventRepository: Error updating event: $e');
      rethrow;
    }
  }

  /// Delete an event
  Future<void> deleteEvent(String id) async {
    try {
      await _localDatasource.deleteEvent(id);
    } catch (e) {
      debugPrint('❌ EventRepository: Error deleting event: $e');
      rethrow;
    }
  }

  /// Get all events
  Future<List<Event>> getAllEvents() async {
    try {
      return await _localDatasource.getAllEvents();
    } catch (e) {
      debugPrint('❌ EventRepository: Error getting all events: $e');
      return [];
    }
  }

  /// Get events for a specific date
  Future<List<Event>> getEventsForDate(DateTime date) async {
    try {
      return await _localDatasource.getEventsForDate(date);
    } catch (e) {
      debugPrint('❌ EventRepository: Error getting events for date: $e');
      return [];
    }
  }

  /// Get events for a specific month
  Future<List<Event>> getEventsForMonth(int year, int month) async {
    try {
      return await _localDatasource.getEventsForMonth(year, month);
    } catch (e) {
      debugPrint('❌ EventRepository: Error getting events for month: $e');
      return [];
    }
  }

  /// Get events for a list of dates
  Future<Map<DateTime, List<Event>>> getEventsForDates(
      List<DateTime> dates) async {
    try {
      return await _localDatasource.getEventsForDates(dates);
    } catch (e) {
      debugPrint('❌ EventRepository: Error getting events for dates: $e');
      return {for (final date in dates) date: []};
    }
  }

  /// Get a single event by id
  Future<Event?> getEventById(String id) async {
    try {
      return await _localDatasource.getEventById(id);
    } catch (e) {
      debugPrint('❌ EventRepository: Error getting event by id: $e');
      return null;
    }
  }
}

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});
