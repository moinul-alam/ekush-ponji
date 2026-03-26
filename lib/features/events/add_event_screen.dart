// lib/features/events/add_event_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/events/add_event_viewmodel.dart';
import 'package:ekush_ponji/features/events/models/event.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ekush_ponji/core/widgets/pickers/app_date_time_picker.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  final DateTime? prefilledDate;
  final Event? eventToEdit;

  const AddEventScreen({
    super.key,
    this.prefilledDate,
    this.eventToEdit,
  });

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _titleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(addEventViewModelProvider.notifier);
      viewModel.resetForm();

      if (widget.eventToEdit != null) {
        viewModel.prefillEvent(widget.eventToEdit!);
        _titleController.text = widget.eventToEdit!.title;
        _descriptionController.text = widget.eventToEdit!.description ?? '';
        _locationController.text = widget.eventToEdit!.location ?? '';
        _notesController.text = widget.eventToEdit!.notes ?? '';
      } else {
        _titleController.clear();
        _descriptionController.clear();
        _locationController.clear();
        _notesController.clear();
        if (widget.prefilledDate != null) {
          viewModel.prefillDate(widget.prefilledDate!);
        }
        _titleFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _onSave() {
    final l10n = AppLocalizations.of(context);
    final viewModel = ref.read(addEventViewModelProvider.notifier);
    viewModel.setTitle(_titleController.text);
    viewModel.setDescription(_descriptionController.text);
    viewModel.setLocation(_locationController.text);
    viewModel.setNotes(_notesController.text);
    viewModel.saveEvent(l10n);
  }

  Future<void> _onDelete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteEvent),
        content: Text(l10n.deleteEventConfirmMessage),
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
    final viewModel = ref.read(addEventViewModelProvider.notifier);
    await viewModel.deleteEvent(l10n);
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
    final viewState = ref.watch(addEventViewModelProvider);
    final viewModel = ref.read(addEventViewModelProvider.notifier);
    final isLoading = viewState is ViewStateLoading;
    final isEditMode = widget.eventToEdit != null;

    ref.listen(addEventViewModelProvider, (prev, next) {
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
            context, isEditMode ? l10n.editEvent : l10n.addEvent),
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
              tooltip: l10n.deleteEvent,
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
              focusNode: _titleFocusNode,
              decoration: InputDecoration(
                labelText: l10n.eventTitle,
                hintText: l10n.eventSubtitle,
                prefixIcon: const Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            _DateTimePicker(
              label: l10n.selectDate,
              icon: Icons.calendar_today,
              dateTime: viewModel.startTime,
              onPick: (dt) => viewModel.setStartTime(dt),
              l10n: l10n,
            ),
            const SizedBox(height: 16),
            _NotificationToggle(viewModel: viewModel, l10n: l10n),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: l10n.location,
                hintText: l10n.locationSubtitle,
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
            ),
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
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.notes,
                hintText: l10n.notesSubtitle,
                prefixIcon: const Icon(Icons.note_outlined),
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

// ─── Notification Toggle ───────────────────────────────────────
class _NotificationToggle extends ConsumerWidget {
  final AddEventViewModel viewModel;
  final AppLocalizations l10n;

  const _NotificationToggle({required this.viewModel, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(addEventViewModelProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            viewModel.notifyAtStartTime
                ? Icons.notifications_active_outlined
                : Icons.notifications_off_outlined,
            size: 20,
            color: viewModel.notifyAtStartTime
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.notifications, style: theme.textTheme.bodyMedium),
                Text(
                  l10n.notificationSubtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: viewModel.notifyAtStartTime,
            onChanged: (val) async {
              if (val) {
                final ok = await LocalNotificationService.ensurePermission();
                if (!ok) {
                  viewModel.setNotifyAtStartTime(false);
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
              viewModel.setNotifyAtStartTime(val);
            },
          ),
        ],
      ),
    );
  }
}

// ─── Date Time Picker ──────────────────────────────────────────
class _DateTimePicker extends ConsumerWidget {
  final String label;
  final IconData icon;
  final DateTime? dateTime;
  final void Function(DateTime) onPick;
  final AppLocalizations l10n;

  const _DateTimePicker({
    required this.label,
    required this.icon,
    required this.dateTime,
    required this.onPick,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(addEventViewModelProvider);
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
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
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
