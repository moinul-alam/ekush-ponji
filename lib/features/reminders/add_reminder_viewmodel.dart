// lib/features/reminders/add_reminder_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/features/home/models/reminder.dart';
import 'package:ekush_ponji/features/reminders/data/reminder_repository.dart';
import 'package:ekush_ponji/features/calendar/calendar_viewmodel.dart';
import 'package:ekush_ponji/core/services/calendar_notification_service.dart';

class AddReminderViewModel extends BaseViewModel {
  late final ReminderRepository _repository;

  String? _editingReminderId;
  bool get isEditMode => _editingReminderId != null;

  String title = '';
  String? description;
  DateTime? dateTime;
  ReminderPriority priority = ReminderPriority.medium;
  bool notificationEnabled = true;
  String? validationError;

  @override
  void onInit() {
    super.onInit();
    _repository = ref.read(reminderRepositoryProvider);
  }

  void resetForm() {
    _editingReminderId = null;
    title = '';
    description = null;
    dateTime = null;
    priority = ReminderPriority.medium;
    notificationEnabled = true;
    validationError = null;
    state = const ViewStateInitial();
  }

  /// Prefill form with an existing reminder for editing
  void prefillReminder(Reminder reminder) {
    _editingReminderId = reminder.id;
    title = reminder.title;
    description = reminder.description;
    dateTime = reminder.dateTime;
    priority = reminder.priority;
    notificationEnabled = reminder.notificationEnabled;
    validationError = null;
    state = ViewStateSuccess();
  }

  void prefillDate(DateTime date) {
    final now = DateTime.now();
    dateTime = DateTime(date.year, date.month, date.day, now.hour, now.minute);
    state = ViewStateSuccess();
  }

  void setTitle(String value) => title = value;
  void setDescription(String? value) => description = value;

  void setDateTime(DateTime value) {
    dateTime = value;
    state = ViewStateSuccess();
  }

  void setPriority(ReminderPriority value) {
    priority = value;
    state = ViewStateSuccess();
  }

  void setNotificationEnabled(bool value) {
    notificationEnabled = value;
    state = ViewStateSuccess();
  }

  String? validate() {
    if (title.trim().isEmpty) return 'Title is required';
    if (dateTime == null) return 'Date and time is required';
    return null;
  }

  Future<bool> saveReminder() async {
    final error = validate();
    if (error != null) {
      validationError = error;
      state = ViewStateError(error, isRetryable: false);
      return false;
    }

    validationError = null;

    return await executeAsync(
      operation: () async {
        final reminder = Reminder(
          id: _editingReminderId, // preserves ID in edit mode
          title: title.trim(),
          description: description?.trim(),
          dateTime: dateTime!,
          priority: priority,
          notificationEnabled: notificationEnabled,
        );

        if (isEditMode) {
          await _repository.updateReminder(reminder);
        } else {
          await _repository.saveReminder(reminder);
        }

        ref
            .read(calendarViewModelProvider.notifier)
            .invalidateCacheForDate(dateTime!);

        // Notifications (best-effort)
        await CalendarNotificationService.cancelReminder(reminder);
        if (reminder.notificationEnabled) {
          await CalendarNotificationService.scheduleReminder(reminder);
        }
      },
      loadingMessage: isEditMode ? 'Updating reminder...' : 'Saving reminder...',
      successMessage: isEditMode
          ? 'Reminder updated successfully'
          : 'Reminder saved successfully',
      errorMessage: isEditMode
          ? 'Failed to update reminder'
          : 'Failed to save reminder',
    );
  }

  Future<bool> deleteReminder() async {
    if (_editingReminderId == null) return false;

    final dateToInvalidate = dateTime;

    return await executeAsync(
      operation: () async {
        final reminder = Reminder(
          id: _editingReminderId,
          title: title,
          dateTime: dateTime ?? DateTime.now(),
          notificationEnabled: false,
        );
        await CalendarNotificationService.cancelReminder(reminder);
        await _repository.deleteReminder(_editingReminderId!);

        if (dateToInvalidate != null) {
          ref
              .read(calendarViewModelProvider.notifier)
              .invalidateCacheForDate(dateToInvalidate);
        }
      },
      loadingMessage: 'Deleting reminder...',
      successMessage: 'Reminder deleted successfully',
      errorMessage: 'Failed to delete reminder',
    );
  }
}

final addReminderViewModelProvider =
    NotifierProvider<AddReminderViewModel, ViewState>(
  () => AddReminderViewModel(),
);