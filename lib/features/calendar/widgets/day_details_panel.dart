// lib/features/calendar/widgets/day_details_panel.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/utils/number_converter.dart';
import 'package:ekush_ponji/features/calendar/models/calendar_day.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:go_router/go_router.dart';

class DayDetailsPanel extends StatefulWidget {
  final CalendarDay? selectedDay;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  const DayDetailsPanel({
    super.key,
    required this.selectedDay,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  @override
  State<DayDetailsPanel> createState() => _DayDetailsPanelState();
}

class _DayDetailsPanelState extends State<DayDetailsPanel> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    if (widget.selectedDay == null) return const SizedBox.shrink();

    final isToday = widget.selectedDay!.isToday;

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ───────────────────────────────────────
          InkWell(
            onTap: widget.onToggleExpanded,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Today badge + date ─────────────
                        Row(
                          children: [
                            if (isToday) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  localizations.today,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                localizations.formatDate(
                                    widget.selectedDay!.gregorianDate),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                      ],
                    ),
                  ),
                  Icon(
                    widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),

          // ─── Expanded Content ─────────────────────────────
          if (widget.isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Holidays ──────────────────────────────
                  if (widget.selectedDay!.hasHoliday) ...[
                    _buildSectionTitle(
                        context, localizations.sectionHolidays, Icons.flag),
                    const SizedBox(height: 8),
                    ...widget.selectedDay!.holidays.map(
                      (holiday) =>
                          _buildHolidayItem(context, holiday, localizations),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ─── Events ────────────────────────────────
                  if (widget.selectedDay!.hasEvent) ...[
                    _buildSectionTitle(
                        context, localizations.sectionEvents, Icons.event),
                    const SizedBox(height: 8),
                    ...widget.selectedDay!.events.map(
                      (event) => _buildEventItem(context, event, localizations),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ─── Reminders ─────────────────────────────
                  if (widget.selectedDay!.hasReminder) ...[
                    _buildSectionTitle(context, localizations.sectionReminders,
                        Icons.notifications),
                    const SizedBox(height: 8),
                    ...widget.selectedDay!.reminders.map(
                      (reminder) =>
                          _buildReminderItem(context, reminder, localizations),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ─── No Items ──────────────────────────────
                  if (!widget.selectedDay!.hasAnyItem)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          localizations.noDataAvailable,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),

                  // ─── Action Buttons ────────────────────────
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Add Event
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.add_circle_outline_rounded,
                          label: localizations.addEvent,
                          backgroundColor: theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.7),
                          foregroundColor: theme.colorScheme.onPrimaryContainer,
                          onTap: () => context.push(
                            RouteNames.calendarAddEvent,
                            extra: widget.selectedDay!.gregorianDate,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Add Reminder
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.alarm_add_rounded,
                          label: localizations.addReminder,
                          backgroundColor: theme.colorScheme.secondaryContainer
                              .withValues(alpha: 0.7),
                          foregroundColor:
                              theme.colorScheme.onSecondaryContainer,
                          onTap: () => context.push(
                            RouteNames.calendarAddReminder,
                            extra: widget.selectedDay!.gregorianDate,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Show Details
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.info_outline_rounded,
                          label: localizations.showDetails,
                          backgroundColor: theme.colorScheme.tertiaryContainer
                              .withValues(alpha: 0.7),
                          foregroundColor:
                              theme.colorScheme.onTertiaryContainer,
                          onTap: () =>
                              context.push(RouteNames.calendarDayDetails),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
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

  Widget _buildHolidayItem(
    BuildContext context,
    dynamic holiday,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    final isBangla = localizations.locale.languageCode == 'bn';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
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
                  isBangla ? holiday.namebn : holiday.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (holiday.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    isBangla
                        ? (holiday.descriptionbn ?? holiday.description!)
                        : holiday.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(
      BuildContext context, dynamic event, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final timeText = event.isAllDay
        ? l10n.allDay
        : (l10n.languageCode == 'bn'
            ? NumberConverter.toBengali(event.getTimeRange())
            : event.getTimeRange());

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
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
                Text(
                  event.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (event.location != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 12, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        event.location!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(
      BuildContext context, dynamic reminder, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final timeText = l10n.languageCode == 'bn'
        ? NumberConverter.toBengali(reminder.getFormattedTime())
        : reminder.getFormattedTime();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
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
                Text(
                  reminder.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  _getPriorityColor(reminder.priority).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getPriorityLabel(reminder.priority, l10n),
              style: theme.textTheme.labelSmall?.copyWith(
                color: _getPriorityColor(reminder.priority),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(dynamic priority) {
    final priorityName = priority.toString().split('.').last;
    switch (priorityName) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityLabel(dynamic priority, AppLocalizations l10n) {
    final priorityName = priority.toString().split('.').last;
    switch (priorityName) {
      case 'urgent':
        return l10n.priorityUrgent;
      case 'high':
        return l10n.priorityHigh;
      case 'medium':
        return l10n.priorityMedium;
      case 'low':
        return l10n.priorityLow;
      default:
        return l10n.priorityMedium;
    }
  }
}

// ─── Reusable action button ───────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: foregroundColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
