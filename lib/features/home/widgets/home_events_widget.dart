import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/home/widgets/home_section_widget.dart';

/// Displays upcoming events
/// TODO: Replace sample data with API call or user-created events
class UpcomingEventsWidget extends StatelessWidget {
  final List<Event>? events;
  final int maxDisplay;

  const UpcomingEventsWidget({
    super.key,
    this.events,
    this.maxDisplay = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    // Use sample data if no events provided
    final displayEvents = events ?? _getSampleEvents();
    final limitedEvents = displayEvents.take(maxDisplay).toList();

    if (limitedEvents.isEmpty) {
      return HomeSectionWidget(
        title: l10n.upcomingEvents,
        trailing: Icon(
          Icons.event_outlined,
          color: colorScheme.primary,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(
                  Icons.event_busy_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.noUpcomingEvents,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return HomeSectionWidget(
      title: l10n.upcomingEvents,
      trailing: Icon(
        Icons.event_outlined,
        color: colorScheme.primary,
      ),
      child: Column(
        children: [
          ...limitedEvents.asMap().entries.map((entry) {
            final index = entry.key;
            final event = entry.value;
            final isLast = index == limitedEvents.length - 1;

            return Column(
              children: [
                _EventItem(event: event),
                if (!isLast)
                  Divider(
                    height: 24,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // TODO: Replace with API call or calendar integration
  List<Event> _getSampleEvents() {
    return [
      Event(
        title: 'Team Meeting',
        description: 'Monthly team sync-up',
        startTime: DateTime.now().add(const Duration(days: 2, hours: 10)),
        endTime: DateTime.now().add(const Duration(days: 2, hours: 11)),
        location: 'Conference Room A',
        category: EventCategory.work,
      ),
      Event(
        title: 'Birthday Party',
        description: 'Celebrating Ahmed\'s birthday',
        startTime: DateTime.now().add(const Duration(days: 5, hours: 18)),
        endTime: DateTime.now().add(const Duration(days: 5, hours: 21)),
        location: 'Home',
        category: EventCategory.personal,
      ),
      Event(
        title: 'Doctor Appointment',
        description: 'Regular checkup',
        startTime: DateTime.now().add(const Duration(days: 7, hours: 15)),
        endTime: DateTime.now().add(const Duration(days: 7, hours: 16)),
        location: 'City Hospital',
        category: EventCategory.health,
      ),
    ];
  }
}

class _EventItem extends StatelessWidget {
  final Event event;

  const _EventItem({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final timeUntil = _getTimeUntil(context, event.startTime);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category indicator
        Container(
          width: 4,
          height: 60,
          decoration: BoxDecoration(
            color: _getCategoryColor(event.category, colorScheme),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),

        // Event details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(event.category),
                    size: 16,
                    color: _getCategoryColor(event.category, colorScheme),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      event.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (event.description != null) ...[
                Text(
                  event.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
              ],
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(context, event.startTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      timeUntil,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (event.location != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(EventCategory category, ColorScheme colorScheme) {
    switch (category) {
      case EventCategory.work:
        return colorScheme.primary;
      case EventCategory.personal:
        return colorScheme.secondary;
      case EventCategory.health:
        return colorScheme.tertiary;
      case EventCategory.other:
        return colorScheme.outline;
    }
  }

  IconData _getCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.work:
        return Icons.work_outline_rounded;
      case EventCategory.personal:
        return Icons.person_outline_rounded;
      case EventCategory.health:
        return Icons.health_and_safety_outlined;
      case EventCategory.other:
        return Icons.event_note_outlined;
    }
  }

  String _formatTime(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context);
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = dateOnly.difference(today).inDays;

    String dateStr;
    if (difference == 0) {
      dateStr = l10n.today;
    } else if (difference == 1) {
      dateStr = l10n.tomorrow;
    } else {
      dateStr =
          '${l10n.localizeNumber(dateTime.day)}/${l10n.localizeNumber(dateTime.month)}';
    }

    final timePart = '$displayHour:$minute $period';
    final timeDisplay = l10n.languageCode == 'bn'
        ? _toBengaliNumerals(timePart)
        : timePart;
    return '$dateStr, $timeDisplay';
  }

  String _toBengaliNumerals(String s) {
    const map = {
      '0': '০', '1': '১', '2': '২', '3': '৩', '4': '৪',
      '5': '৫', '6': '৬', '7': '৭', '8': '৮', '9': '৯',
    };
    return s.split('').map((c) => map[c] ?? c).join();
  }

  String _getTimeUntil(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = dateOnly.difference(today).inDays;

    if (difference < 0) return l10n.passed;
    return l10n.formatDaysDistance(difference);
  }
}

// Models
class Event {
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final EventCategory category;

  Event({
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    this.category = EventCategory.other,
  });

  // TODO: Add fromJson factory for API integration
  // factory Event.fromJson(Map<String, dynamic> json) {
  //   return Event(
  //     title: json['title'],
  //     description: json['description'],
  //     startTime: DateTime.parse(json['start_time']),
  //     endTime: DateTime.parse(json['end_time']),
  //     location: json['location'],
  //     category: EventCategory.values.byName(json['category']),
  //   );
  // }
}

enum EventCategory {
  work,
  personal,
  health,
  other,
}
