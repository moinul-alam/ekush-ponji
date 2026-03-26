import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/utils/number_converter.dart';
import 'package:ekush_ponji/features/events/models/event.dart';

/// Widget showing upcoming events in current month
/// Displays next 3-5 events with time and location
class UpcomingEventsWidget extends StatelessWidget {
  final String monthName;
  final List<Event> events;
  final int maxItems;

  const UpcomingEventsWidget({
    super.key,
    required this.monthName,
    required this.events,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Filter upcoming events only
    final upcomingEvents =
        events.where((e) => e.isUpcoming).take(maxItems).toList();

    if (upcomingEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.event,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.formatUpcomingEventsInMonth(monthName),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Event items
          ...upcomingEvents.map((event) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date badge
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.localizeNumber(event.startTime.day),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          l10n.getMonthAbbreviation(event.startTime.month),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Event details
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
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.isAllDay
                                  ? l10n.allDay
                                  : (l10n.languageCode == 'bn'
                                      ? NumberConverter.toBengali(
                                          event.getTimeRange())
                                      : event.getTimeRange()),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        if (event.location != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.location!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          event.daysUntil < 0
                              ? l10n.passed
                              : l10n.formatDaysDistance(event.daysUntil),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(event.category)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getCategoryLabel(event.category, l10n),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getCategoryColor(event.category),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Get localized category label
  String _getCategoryLabel(EventCategory category, AppLocalizations l10n) {
    switch (category) {
      case EventCategory.work:
        return l10n.categoryWork;
      case EventCategory.personal:
        return l10n.categoryPersonal;
      case EventCategory.family:
        return l10n.categoryFamily;
      case EventCategory.health:
        return l10n.categoryHealth;
      case EventCategory.education:
        return l10n.categoryEducation;
      case EventCategory.social:
        return l10n.categorySocial;
      case EventCategory.other:
        return l10n.categoryOther;
    }
  }

  /// Get category color
  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.work:
        return Colors.blue;
      case EventCategory.personal:
        return Colors.purple;
      case EventCategory.family:
        return Colors.pink;
      case EventCategory.health:
        return Colors.green;
      case EventCategory.education:
        return Colors.orange;
      case EventCategory.social:
        return Colors.teal;
      case EventCategory.other:
        return Colors.grey;
    }
  }
}
