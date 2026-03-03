// lib/features/events/add_event_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/features/home/models/event.dart';
import 'package:ekush_ponji/features/events/data/event_repository.dart';
import 'package:ekush_ponji/features/calendar/calendar_viewmodel.dart';
import 'package:ekush_ponji/core/services/calendar_notification_service.dart';

class AddEventViewModel extends BaseViewModel {
  late final EventRepository _repository;

  String? _editingEventId;
  bool get isEditMode => _editingEventId != null;

  String title = '';
  String? description;
  DateTime? startTime;
  DateTime? endTime;
  String? location;
  EventCategory category = EventCategory.personal;
  bool isAllDay = false;
  String? notes;
  bool notifyAtStartTime = true;
  String? validationError;

  @override
  void onInit() {
    super.onInit();
    _repository = ref.read(eventRepositoryProvider);
  }

  void resetForm() {
    _editingEventId = null;
    title = '';
    description = null;
    startTime = null;
    endTime = null;
    location = null;
    category = EventCategory.personal;
    isAllDay = false;
    notes = null;
    notifyAtStartTime = true;
    validationError = null;
    state = const ViewStateInitial();
  }

  /// Prefill form with an existing event for editing
  void prefillEvent(Event event) {
    _editingEventId = event.id;
    title = event.title;
    description = event.description;
    startTime = event.startTime;
    endTime = event.endTime;
    location = event.location;
    category = event.category;
    isAllDay = event.isAllDay;
    notes = event.notes;
    notifyAtStartTime = event.notifyAtStartTime;
    validationError = null;
    state = ViewStateSuccess();
  }

  void prefillDate(DateTime date) {
    final now = DateTime.now();
    startTime = DateTime(date.year, date.month, date.day, now.hour, now.minute);
    state = ViewStateSuccess();
  }

  void setTitle(String value) => title = value;
  void setDescription(String? value) => description = value;
  void setLocation(String? value) => location = value;
  void setNotes(String? value) => notes = value;

  void setNotifyAtStartTime(bool value) {
    notifyAtStartTime = value;
    state = ViewStateSuccess();
  }

  void setCategory(EventCategory value) {
    category = value;
    state = ViewStateSuccess();
  }

  void setIsAllDay(bool value) {
    isAllDay = value;
    if (value) {
      if (startTime != null) {
        startTime = DateTime(
          startTime!.year,
          startTime!.month,
          startTime!.day,
        );
      }
      endTime = null;
    }
    state = ViewStateSuccess();
  }

  void setStartTime(DateTime value) {
    startTime = value;
    if (endTime != null && endTime!.isBefore(value)) {
      endTime = null;
    }
    state = ViewStateSuccess();
  }

  void setEndTime(DateTime? value) {
    endTime = value;
    state = ViewStateSuccess();
  }

  String? validate() {
    if (title.trim().isEmpty) return 'Title is required';
    if (startTime == null) return 'Start date is required';
    if (!isAllDay && endTime != null && endTime!.isBefore(startTime!)) {
      return 'End time must be after start time';
    }
    return null;
  }

  Future<bool> saveEvent() async {
    final error = validate();
    if (error != null) {
      validationError = error;
      state = ViewStateError(error, isRetryable: false);
      return false;
    }

    validationError = null;

    return await executeAsync(
      operation: () async {
        final event = Event(
          id: _editingEventId, // preserves ID in edit mode
          title: title.trim(),
          description: description?.trim(),
          startTime: startTime!,
          endTime: isAllDay ? null : endTime,
          location: location?.trim(),
          category: category,
          isAllDay: isAllDay,
          notes: notes?.trim(),
          notifyAtStartTime: notifyAtStartTime,
        );

        if (isEditMode) {
          await _repository.updateEvent(event);
        } else {
          await _repository.saveEvent(event);
        }

        ref
            .read(calendarViewModelProvider.notifier)
            .invalidateCacheForDate(startTime!);

        // Notifications (best-effort; event still saves even if permission denied)
        await CalendarNotificationService.cancelEvent(event);
        if (event.notifyAtStartTime) {
          await CalendarNotificationService.scheduleEvent(event);
        }
      },
      loadingMessage: isEditMode ? 'Updating event...' : 'Saving event...',
      successMessage:
          isEditMode ? 'Event updated successfully' : 'Event saved successfully',
      errorMessage:
          isEditMode ? 'Failed to update event' : 'Failed to save event',
    );
  }

  Future<bool> deleteEvent() async {
    if (_editingEventId == null) return false;

    final dateToInvalidate = startTime;

    return await executeAsync(
      operation: () async {
        final event = Event(
          id: _editingEventId,
          title: title,
          startTime: startTime ?? DateTime.now(),
          notifyAtStartTime: false,
        );
        await CalendarNotificationService.cancelEvent(event);
        await _repository.deleteEvent(_editingEventId!);

        if (dateToInvalidate != null) {
          ref
              .read(calendarViewModelProvider.notifier)
              .invalidateCacheForDate(dateToInvalidate);
        }
      },
      loadingMessage: 'Deleting event...',
      successMessage: 'Event deleted successfully',
      errorMessage: 'Failed to delete event',
    );
  }
}

final addEventViewModelProvider =
    NotifierProvider<AddEventViewModel, ViewState>(
  () => AddEventViewModel(),
);