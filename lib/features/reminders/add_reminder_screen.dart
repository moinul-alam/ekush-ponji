// lib/features/reminders/add_reminder_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/reminders/add_reminder_viewmodel.dart';
import 'package:ekush_ponji/features/reminders/models/reminder.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ekush_ponji/core/widgets/pickers/app_date_time_picker.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';

class AddReminderScreen extends ConsumerStatefulWidget {
  final DateTime? prefilledDate;
  final Reminder? reminderToEdit;

  const AddReminderScreen({
    super.key,
    this.prefilledDate,
    this.reminderToEdit,
  });

  @override
  ConsumerState<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends ConsumerState<AddReminderScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(addReminderViewModelProvider.notifier);
      viewModel.resetForm();

      if (widget.reminderToEdit != null) {
        viewModel.prefillReminder(widget.reminderToEdit!);
        _titleController.text = widget.reminderToEdit!.title;
        _descriptionController.text = widget.reminderToEdit!.description ?? '';
      } else {
        _titleController.clear();
        _descriptionController.clear();
        if (widget.prefilledDate != null) {
          viewModel.prefillDate(widget.prefilledDate!);
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave() {
    final l10n = AppLocalizations.of(context);
    final viewModel = ref.read(addReminderViewModelProvider.notifier);
    viewModel.setTitle(_titleController.text);
    viewModel.setDescription(_descriptionController.text);
    viewModel.saveReminder(l10n);
  }

  Future<void> _onDelete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteReminder),
        content: Text(l10n.deleteReminderConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final viewModel = ref.read(addReminderViewModelProvider.notifier);
    await viewModel.deleteReminder(l10n);
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Theme.of(context).colorScheme.error : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final viewState = ref.watch(addReminderViewModelProvider);
    final viewModel = ref.read(addReminderViewModelProvider.notifier);
    final isLoading = viewState is ViewStateLoading;
    final isEditMode = widget.reminderToEdit != null;

    ref.listen(addReminderViewModelProvider, (prev, next) {
      if (next is ViewStateSuccess && next.message != null) {
        _showSnackbar(next.message!);
        if (mounted) context.pop();
      }
      if (next is ViewStateError) {
        _showSnackbar(next.message, isError: true);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: AppHeader.title(
            context, isEditMode ? l10n.editReminder : l10n.addReminder),
        centerTitle: true,
        actions: [
          if (isEditMode)
            IconButton(
              onPressed: isLoading ? null : _onDelete,
              icon: Icon(
                Icons.delete_outline,
                color: isLoading
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.error,
              ),
              tooltip: l10n.deleteReminder,
            ),
          TextButton(
            onPressed: isLoading ? null : _onSave,
            child: Text(
              l10n.save,
              style: TextStyle(
                color: isLoading
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.reminderTitle,
                hintText: l10n.reminderSubtitle,
                prefixIcon: const Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            _ReminderDateTimePicker(
              dateTime: viewModel.dateTime,
              onPick: viewModel.setDateTime,
              l10n: l10n,
            ),
            const SizedBox(height: 16),
            _PrioritySelector(viewModel: viewModel, l10n: l10n),
            const SizedBox(height: 16),
            _NotificationToggle(viewModel: viewModel, l10n: l10n),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: l10n.descriptionSubtitle,
                prefixIcon: const Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Date Time Picker ──────────────────────────────────────────
class _ReminderDateTimePicker extends ConsumerWidget {
  final DateTime? dateTime;
  final void Function(DateTime) onPick;
  final AppLocalizations l10n;

  const _ReminderDateTimePicker({
    required this.dateTime,
    required this.onPick,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(addReminderViewModelProvider);
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _pick(context, l10n),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.alarm, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.selectDate,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateTime != null
                        ? _formatDateTime(dateTime!, l10n)
                        : l10n.selectDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: dateTime != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt, AppLocalizations l10n) {
    final day = l10n.localizeNumber(dt.day);
    final monthName = l10n.getMonthName(dt.month);
    final year = l10n.localizeNumber(dt.year);
    final hour = l10n.localizeNumber(dt.hour.toString().padLeft(2, '0'));
    final minute = l10n.localizeNumber(dt.minute.toString().padLeft(2, '0'));
    return '$day $monthName $year  $hour:$minute';
  }

  Future<void> _pick(BuildContext context, AppLocalizations l10n) async {
    final result = await AppDateTimePicker.show(
      context: context,
      initial: dateTime ?? DateTime.now(),
      l10n: l10n,
    );
    if (result != null) onPick(result);
  }
}

// ─── Priority Selector ─────────────────────────────────────────
class _PrioritySelector extends ConsumerWidget {
  final AddReminderViewModel viewModel;
  final AppLocalizations l10n;

  const _PrioritySelector({required this.viewModel, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(addReminderViewModelProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.priority,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ReminderPriority.values.map((priority) {
            final isSelected = viewModel.priority == priority;
            final color = _priorityColor(priority);
            return ChoiceChip(
              label: Text(_priorityLabel(priority, l10n)),
              selected: isSelected,
              onSelected: (_) => viewModel.setPriority(priority),
              selectedColor: color.withValues(alpha: 0.15),
              labelStyle: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: isSelected ? BorderSide(color: color, width: 1.5) : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _priorityColor(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.urgent:
        return Colors.red;
      case ReminderPriority.high:
        return Colors.orange;
      case ReminderPriority.medium:
        return Colors.blue;
      case ReminderPriority.low:
        return Colors.grey;
    }
  }

  String _priorityLabel(ReminderPriority priority, AppLocalizations l10n) {
    switch (priority) {
      case ReminderPriority.urgent:
        return l10n.priorityUrgent;
      case ReminderPriority.high:
        return l10n.priorityHigh;
      case ReminderPriority.medium:
        return l10n.priorityMedium;
      case ReminderPriority.low:
        return l10n.priorityLow;
    }
  }
}

// ─── Notification Toggle ───────────────────────────────────────
class _NotificationToggle extends ConsumerWidget {
  final AddReminderViewModel viewModel;
  final AppLocalizations l10n;

  const _NotificationToggle({required this.viewModel, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(addReminderViewModelProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_outlined,
                  size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(l10n.notifications, style: theme.textTheme.bodyMedium),
            ],
          ),
          Switch(
            value: viewModel.notificationEnabled,
            onChanged: (val) async {
              if (val) {
                final ok = await LocalNotificationService.ensurePermission();
                if (!ok) {
                  viewModel.setNotificationEnabled(false);
                  if (context.mounted) {
                    await showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.notifications),
                        content: Text(l10n.notificationsPermissionRequired),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await openAppSettings();
                            },
                            child: Text(l10n.openSettings),
                          ),
                        ],
                      ),
                    );
                  }
                  return;
                }
              }
              viewModel.setNotificationEnabled(val);
            },
          ),
        ],
      ),
    );
  }
}
