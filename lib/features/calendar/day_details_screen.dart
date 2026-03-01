// lib/features/calendar/day_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/utils/number_converter.dart';
import 'package:ekush_ponji/features/calendar/calendar_viewmodel.dart';
import 'package:ekush_ponji/features/calendar/models/calendar_day.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/features/home/models/event.dart';
import 'package:ekush_ponji/features/home/models/reminder.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';

class DayDetailsScreen extends ConsumerWidget {
  const DayDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // ── ref.watch so screen rebuilds when calendar state changes ──
    ref.watch(calendarViewModelProvider);
    final viewModel = ref.read(calendarViewModelProvider.notifier);
    final selectedDay = viewModel.selectedDay;

    if (selectedDay == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.showDetails)),
        body: Center(child: Text(l10n.noDataAvailable)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.languageCode == 'bn'
              ? selectedDay.bengaliDate.formatBn()
              : l10n.formatDate(selectedDay.gregorianDate),
        ),
        centerTitle: true,
      ),
      // ── RefreshIndicator for pull-to-refresh ──
      body: RefreshIndicator(
        onRefresh: () => viewModel.refreshSelectedDay(),
        child: SingleChildScrollView(
          // physics required so RefreshIndicator works even when content is short
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Date Header Card ─────────────────────────────
              _DateHeaderCard(selectedDay: selectedDay, l10n: l10n),
              const SizedBox(height: 20),

              // ─── Holidays ────────────────────────────────────
              if (selectedDay.hasHoliday) ...[
                _SectionHeader(
                  title: l10n.sectionHolidays,
                  icon: Icons.celebration,
                ),
                const SizedBox(height: 8),
                ...selectedDay.holidays.map(
                  (h) => _HolidayCard(holiday: h, l10n: l10n),
                ),
                const SizedBox(height: 20),
              ],

              // ─── Events ──────────────────────────────────────
              if (selectedDay.hasEvent) ...[
                _SectionHeader(
                  title: l10n.sectionEvents,
                  icon: Icons.event,
                ),
                const SizedBox(height: 8),
                ...selectedDay.events.map(
                  (e) => _EventCard(event: e, l10n: l10n),
                ),
                const SizedBox(height: 20),
              ],

              // ─── Reminders ───────────────────────────────────
              if (selectedDay.hasReminder) ...[
                _SectionHeader(
                  title: l10n.sectionReminders,
                  icon: Icons.notifications,
                ),
                const SizedBox(height: 8),
                ...selectedDay.reminders.map(
                  (r) => _ReminderCard(reminder: r, l10n: l10n),
                ),
                const SizedBox(height: 20),
              ],

              // ─── No data ─────────────────────────────────────
              if (!selectedDay.hasAnyItem)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noDataAvailable,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ─── Action Buttons ───────────────────────────────
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(
                        RouteNames.calendarAddEvent,
                        extra: selectedDay.gregorianDate,
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.addEvent),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(
                        RouteNames.calendarAddReminder,
                        extra: selectedDay.gregorianDate,
                      ),
                      icon: const Icon(Icons.alarm_add, size: 18),
                      label: Text(l10n.addReminder),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Date Header Card ──────────────────────────────────────────
class _DateHeaderCard extends StatelessWidget {
  final CalendarDay selectedDay;
  final AppLocalizations l10n;

  const _DateHeaderCard({
    required this.selectedDay,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBn = l10n.languageCode == 'bn';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.formatDate(selectedDay.gregorianDate),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isBn
                ? selectedDay.bengaliDate.formatBn()
                : selectedDay.bengaliDate.format(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
            ),
          ),
          if (selectedDay.isToday) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.today,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ─── Holiday Card ──────────────────────────────────────────────
class _HolidayCard extends StatelessWidget {
  final Holiday holiday;
  final AppLocalizations l10n;

  const _HolidayCard({required this.holiday, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBn = l10n.languageCode == 'bn';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn ? holiday.namebn : holiday.name,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if ((isBn ? holiday.descriptionbn : holiday.description) !=
                    null) ...[
                  const SizedBox(height: 4),
                  Text(
                    isBn
                        ? (holiday.descriptionbn ?? holiday.description ?? '')
                        : (holiday.description ?? ''),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    holiday.type.displayName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Event Card ────────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  final Event event;
  final AppLocalizations l10n;

  const _EventCard({required this.event, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBn = l10n.languageCode == 'bn';
    final timeText = event.isAllDay
        ? l10n.allDay
        : (isBn
            ? NumberConverter.toBengali(event.getTimeRange())
            : event.getTimeRange());

    return InkWell(
      onTap: () => context.push(
        RouteNames.calendarEditEvent,
        extra: event,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        timeText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (event.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 12,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (event.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      event.category.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reminder Card ─────────────────────────────────────────────
class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final AppLocalizations l10n;

  const _ReminderCard({required this.reminder, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBn = l10n.languageCode == 'bn';
    final timeText = isBn
        ? NumberConverter.toBengali(reminder.getFormattedTime())
        : reminder.getFormattedTime();

    return InkWell(
      onTap: () => context.push(
        RouteNames.calendarEditReminder,
        extra: reminder,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reminder.title,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.alarm,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        timeText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (reminder.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      reminder.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _priorityColor(reminder.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _priorityLabel(reminder.priority, l10n),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _priorityColor(reminder.priority),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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