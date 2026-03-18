// lib/features/home/widgets/home_events_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/events/models/event.dart';
import 'package:ekush_ponji/features/home/widgets/home_section_widget.dart';
import 'package:ekush_ponji/features/calendar/calendar_viewmodel.dart';
import 'package:ekush_ponji/app/router/route_names.dart';

class UpcomingEventsWidget extends ConsumerWidget {
  final List<Event> events;

  const UpcomingEventsWidget({
    super.key,
    required this.events,
  });

  Future<void> _navigateToToday(BuildContext context, WidgetRef ref) async {
    final today = DateTime.now();
    final calendarVm = ref.read(calendarViewModelProvider.notifier);
    await calendarVm.jumpToMonth(today.year, today.month);
    calendarVm.selectDate(today);
    if (context.mounted) context.push(RouteNames.calendarDayDetails);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (events.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return HomeSectionWidget(
      title: l10n.upcomingEvents,
      margin: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colorScheme.primary,
      ),
      onTap: () => _navigateToToday(context, ref),
      child: Column(
        children: [
          ...events.asMap().entries.map((entry) {
            final index = entry.key;
            final event = entry.value;
            final isLast = index == events.length - 1;

            return Column(
              children: [
                _EventItem(
                  event: event,
                  onTap: () => _navigateToToday(context, ref),
                ),
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
}

class _EventItem extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _EventItem({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 60,
          decoration: BoxDecoration(
            color: _getCategoryColor(event.category, colorScheme),
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
                    event.isAllDay
                        ? l10n.allDay
                        : _formatTime(event.startTime, l10n.languageCode),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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

  String _formatTime(DateTime dateTime, String languageCode) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final time = '$displayHour:$minute $period';

    if (languageCode == 'bn') {
      const map = {
        '0': '০',
        '1': '১',
        '2': '২',
        '3': '৩',
        '4': '৪',
        '5': '৫',
        '6': '৬',
        '7': '৭',
        '8': '৮',
        '9': '৯',
      };
      return time.split('').map((c) => map[c] ?? c).join();
    }
    return time;
  }

  Color _getCategoryColor(EventCategory category, ColorScheme cs) {
    switch (category) {
      case EventCategory.work:
        return cs.primary;
      case EventCategory.personal:
        return cs.secondary;
      case EventCategory.health:
        return cs.tertiary;
      case EventCategory.family:
        return cs.primaryContainer;
      case EventCategory.education:
        return cs.secondaryContainer;
      case EventCategory.social:
        return cs.tertiaryContainer;
      case EventCategory.other:
        return cs.outline;
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
      case EventCategory.family:
        return Icons.family_restroom_outlined;
      case EventCategory.education:
        return Icons.school_outlined;
      case EventCategory.social:
        return Icons.people_outline_rounded;
      case EventCategory.other:
        return Icons.event_note_outlined;
    }
  }
}
