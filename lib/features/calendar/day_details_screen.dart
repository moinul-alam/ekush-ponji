// lib/features/calendar/day_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/utils/number_converter.dart';
import 'package:ekush_ponji/core/widgets/ads/native_ad_widget.dart';
import 'package:ekush_ponji/features/calendar/calendar_viewmodel.dart';
import 'package:ekush_ponji/features/calendar/models/calendar_day.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/features/events/models/event.dart';
import 'package:ekush_ponji/features/reminders/models/reminder.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';

class DayDetailsScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const DayDetailsScreen({super.key, this.initialDate});

  @override
  ConsumerState<DayDetailsScreen> createState() => _DayDetailsScreenState();
}

class _DayDetailsScreenState extends ConsumerState<DayDetailsScreen> {
  int? _lastSeenDataVersion;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vm = ref.read(calendarViewModelProvider.notifier);
        final date = widget.initialDate!;
        vm.jumpToMonth(date.year, date.month).then((_) {
          vm.selectDate(date);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataVersion = ref.watch(appDataVersionProvider);
    if (_lastSeenDataVersion != dataVersion) {
      _lastSeenDataVersion = dataVersion;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(calendarViewModelProvider.notifier).refreshSelectedDay();
      });
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
        title: AppHeader.title(
          context,
          l10n.dayDetails,
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => viewModel.refreshSelectedDay(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DateHeaderCard(selectedDay: selectedDay, l10n: l10n),
              const SizedBox(height: 20),

              // ── Holidays ─────────────────────────────────────────────────
              if (selectedDay.hasHoliday) ...[
                _SectionHeader(
                  title: l10n.sectionHolidays,
                  icon: Icons.flag_rounded,
                ),
                const SizedBox(height: 8),
                ...selectedDay.holidays.map(
                  (h) => _HolidayCard(holiday: h, l10n: l10n),
                ),
                const SizedBox(height: 12),
              ],

              // ── Native ad — after holidays, before events/reminders ──────
              const NativeAdWidget(style: NativeAdStyle.card),
              const SizedBox(height: 12),

              // ── Events ───────────────────────────────────────────────────
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

              // ── Reminders ────────────────────────────────────────────────
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

              // ── Empty state ──────────────────────────────────────────────
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
                              .withValues(alpha: 0.4),
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

              // ── Action buttons — filled, matching day_details_panel ───────
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _FilledActionButton(
                      icon: Icons.add_circle_outline_rounded,
                      label: l10n.addEvent,
                      backgroundColor: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.7),
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      onTap: () => context.push(
                        RouteNames.calendarAddEvent,
                        extra: selectedDay.gregorianDate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FilledActionButton(
                      icon: Icons.alarm_add_rounded,
                      label: l10n.addReminder,
                      backgroundColor: theme.colorScheme.secondaryContainer
                          .withValues(alpha: 0.7),
                      foregroundColor: theme.colorScheme.onSecondaryContainer,
                      onTap: () => context.push(
                        RouteNames.calendarAddReminder,
                        extra: selectedDay.gregorianDate,
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

// ─── Date Header Card ──────────────────────────────────────────────────────────
class _DateHeaderCard extends StatelessWidget {
  final CalendarDay selectedDay;
  final AppLocalizations l10n;

  const _DateHeaderCard({required this.selectedDay, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBn = l10n.languageCode == 'bn';

    final gregorianDate = l10n.formatDate(selectedDay.gregorianDate);
    final bengaliDate = isBn
        ? selectedDay.bengaliDate.formatBn()
        : selectedDay.bengaliDate.format();
    final dayName = l10n.getDayName(selectedDay.gregorianDate.weekday);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // ── Left: Gregorian + Bengali dates ─────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gregorianDate,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bengaliDate,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),

          // ── Subtle gradient vertical divider ─────────────────────────────
          Container(
            width: 1,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.0),
                  theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.3),
                  theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ── Right: day name ──────────────────────────────────────────────
          Text(
            dayName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
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
}

// ─── Holiday Card ──────────────────────────────────────────────────────────────
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
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isBn
                        ? holiday.gazetteType.displayNameBn
                        : holiday.gazetteType.displayName,
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

// ─── Event Card ────────────────────────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  final Event event;
  final AppLocalizations l10n;

  const _EventCard({required this.event, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isBn = l10n.languageCode == 'bn';
    final timeText = event.isAllDay
        ? l10n.allDay
        : (isBn
            ? NumberConverter.toBengali(event.getTimeRange())
            : event.getTimeRange());

    return InkWell(
      onTap: () => context.push(RouteNames.calendarEditEvent, extra: event),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primary,
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
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          size: 16, color: cs.onSurfaceVariant),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 12, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        timeText,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                  if (event.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 12, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (event.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.description!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      event.category.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.primary,
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

// ─── Reminder Card ─────────────────────────────────────────────────────────────
class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final AppLocalizations l10n;

  const _ReminderCard({required this.reminder, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isBn = l10n.languageCode == 'bn';
    final timeText = isBn
        ? NumberConverter.toBengali(reminder.getFormattedTime())
        : reminder.getFormattedTime();

    return InkWell(
      onTap: () =>
          context.push(RouteNames.calendarEditReminder, extra: reminder),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.secondaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.secondary.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: cs.secondary,
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
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          size: 16, color: cs.onSurfaceVariant),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.alarm, size: 12, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        timeText,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                  if (reminder.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      reminder.description!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cs.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _priorityLabel(reminder.priority, l10n),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.secondary,
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

// ─── Filled Action Button — matches day_details_panel.dart _ActionButton ───────
class _FilledActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _FilledActionButton({
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
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
