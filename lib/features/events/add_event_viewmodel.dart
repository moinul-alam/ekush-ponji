// lib/features/events/add_event_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/services/app_review_service.dart';
import 'package:ekush_ponji/features/events/models/event.dart';
import 'package:ekush_ponji/features/events/data/event_repository.dart';
import 'package:ekush_ponji/features/calendar/calendar_viewmodel.dart';
import 'package:ekush_ponji/features/events/services/event_notification_service.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';

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
  void onSyncSetup() {
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

  String? validate(AppLocalizations l10n) {
    if (title.trim().isEmpty) return l10n.eventTitle;
    if (startTime == null) return l10n.selectFromDate;
    if (!isAllDay && endTime != null && endTime!.isBefore(startTime!)) {
      return l10n.invalidDateRange;
    }
    return null;
  }

  Future<bool> saveEvent(AppLocalizations l10n) async {
    final error = validate(l10n);
    if (error != null) {
      validationError = error;
      state = ViewStateError(error, isRetryable: false);
      return false;
    }

    validationError = null;

    return await executeAsync(
      operation: () async {
        final event = Event(
          id: _editingEventId,
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
          AppReviewService.recordMeaningfulAction();
        }

        ref
            .read(calendarViewModelProvider.notifier)
            .invalidateCacheForDate(startTime!);
        ref.read(appDataVersionProvider.notifier).markChanged();

        await EventNotificationService.cancel(event);
        if (event.notifyAtStartTime) {
          await EventNotificationService.schedule(event);
        }
      },
      loadingMessage: l10n.loading,
      successMessage:
          isEditMode ? l10n.eventUpdatedSuccess : l10n.eventAddedSuccess,
      errorMessage: '${l10n.error}: ${isEditMode ? l10n.editEvent : l10n.addEvent}',
    );
  }

  Future<bool> deleteEvent(AppLocalizations l10n) async {
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
        await EventNotificationService.cancel(event);
        await _repository.deleteEvent(_editingEventId!);

        if (dateToInvalidate != null) {
          ref
              .read(calendarViewModelProvider.notifier)
              .invalidateCacheForDate(dateToInvalidate);
        }
        ref.read(appDataVersionProvider.notifier).markChanged();
      },
      loadingMessage: l10n.loading,
      successMessage: l10n.eventDeletedSuccess,
      errorMessage: '${l10n.error}: ${l10n.deleteEvent}',
    );
  }
}

final addEventViewModelProvider =
    NotifierProvider<AddEventViewModel, ViewState>(
  () => AddEventViewModel(),
);
