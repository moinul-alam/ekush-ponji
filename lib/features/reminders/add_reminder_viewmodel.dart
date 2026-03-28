// lib/features/reminders/add_reminder_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/services/app_review_service.dart';
import 'package:ekush_ponji/features/reminders/models/reminder.dart';
import 'package:ekush_ponji/features/reminders/data/reminder_repository.dart';
import 'package:ekush_ponji/features/calendar/calendar_viewmodel.dart';
import 'package:ekush_ponji/features/reminders/services/reminder_notification_service.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';

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
  void onSyncSetup() {
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

  String? validate(AppLocalizations l10n) {
    if (title.trim().isEmpty) return l10n.reminderTitle;
    if (dateTime == null) return l10n.selectDate;
    return null;
  }

  Future<bool> saveReminder(AppLocalizations l10n) async {
    final error = validate(l10n);
    if (error != null) {
      validationError = error;
      state = ViewStateError(error, isRetryable: false);
      return false;
    }

    validationError = null;

    return await executeAsync(
      operation: () async {
        final reminder = Reminder(
          id: _editingReminderId,
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
          AppReviewService.recordMeaningfulAction();
        }

        ref
            .read(calendarViewModelProvider.notifier)
            .invalidateCacheForDate(dateTime!);
        ref.read(appDataVersionProvider.notifier).markChanged();

        await ReminderNotificationService.cancel(reminder);
        if (reminder.notificationEnabled) {
          await ReminderNotificationService.schedule(reminder);
        }
      },
      loadingMessage: l10n.loading,
      successMessage: isEditMode
          ? l10n.reminderUpdatedSuccess
          : l10n.reminderAddedSuccess,
      errorMessage:
          '${l10n.error}: ${isEditMode ? l10n.editReminder : l10n.addReminder}',
    );
  }

  Future<bool> deleteReminder(AppLocalizations l10n) async {
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
        await ReminderNotificationService.cancel(reminder);
        await _repository.deleteReminder(_editingReminderId!);

        if (dateToInvalidate != null) {
          ref
              .read(calendarViewModelProvider.notifier)
              .invalidateCacheForDate(dateToInvalidate);
        }
        ref.read(appDataVersionProvider.notifier).markChanged();
      },
      loadingMessage: l10n.loading,
      successMessage: l10n.reminderDeletedSuccess,
      errorMessage: '${l10n.error}: ${l10n.deleteReminder}',
    );
  }
}

final addReminderViewModelProvider =
    NotifierProvider<AddReminderViewModel, ViewState>(
  () => AddReminderViewModel(),
);
