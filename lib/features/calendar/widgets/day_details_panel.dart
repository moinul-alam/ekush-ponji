import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/calendar/models/calendar_day.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// Day details panel widget
/// Expandable/collapsible panel showing selected date details
/// Contains holidays, events, reminders, and action buttons
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

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and expand/collapse button
          InkWell(
            onTap: widget.onToggleExpanded,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gregorian date
                        Text(
                          _formatGregorianDate(widget.selectedDay!),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Bengali date
                        Text(
                          widget.selectedDay!.bengaliDate.formatBn(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.green.shade700,
                          ),
                        ),
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

          // Expanded content
          if (widget.isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Holidays section
                  if (widget.selectedDay!.hasHoliday) ...[
                    _buildSectionTitle(context, 'Holidays', Icons.celebration),
                    const SizedBox(height: 8),
                    ...widget.selectedDay!.holidays.map((holiday) => 
                      _buildHolidayItem(context, holiday, localizations),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Events section
                  if (widget.selectedDay!.hasEvent) ...[
                    _buildSectionTitle(context, 'Events', Icons.event),
                    const SizedBox(height: 8),
                    ...widget.selectedDay!.events.map((event) => 
                      _buildEventItem(context, event),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Reminders section
                  if (widget.selectedDay!.hasReminder) ...[
                    _buildSectionTitle(context, 'Reminders', Icons.notifications),
                    const SizedBox(height: 8),
                    ...widget.selectedDay!.reminders.map((reminder) => 
                      _buildReminderItem(context, reminder),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // No items message
                  if (!widget.selectedDay!.hasAnyItem) ...[
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
                  ],

                  // Action buttons
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Navigate to day details screen
                            context.push('/calendar/day-details');
                          },
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: const Text('Show Details'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Navigate to add event screen
                            context.push('/calendar/add-event');
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Event'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to add reminder screen
                        context.push('/calendar/add-reminder');
                      },
                      icon: const Icon(Icons.alarm_add, size: 18),
                      label: const Text('Add Reminder'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build section title
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

  /// Build holiday item
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
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
          width: 1,
        ),
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

  /// Build event item
  Widget _buildEventItem(BuildContext context, dynamic event) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
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
                  event.getTimeRange(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (event.location != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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

  /// Build reminder item
  Widget _buildReminderItem(BuildContext context, dynamic reminder) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.withOpacity(0.2),
          width: 1,
        ),
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
                  reminder.getFormattedTime(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Priority badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPriorityColor(reminder.priority).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              reminder.priority.displayName,
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

  /// Get priority color
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

  /// Format Gregorian date
  String _formatGregorianDate(CalendarDay day) {
    final months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final month = months[day.gregorianDate.month];
    return '${month} ${day.gregorianDate.day}, ${day.gregorianDate.year}';
  }
}