// lib/features/reminders/reminders_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/widgets/ads/native_ad_widget.dart';
import 'package:ekush_ponji/features/reminders/models/reminder.dart';
import 'package:ekush_ponji/features/reminders/data/reminder_repository.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';

final _allRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final repo = ref.read(reminderRepositoryProvider);
  final all = await repo.getAllReminders();
  all.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  return all;
});

class RemindersListScreen extends ConsumerWidget {
  const RemindersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.languageCode == 'bn';
    final remindersAsync = ref.watch(_allRemindersProvider);

    return Scaffold(
      appBar: AppHeader(pageTitle: l10n.allReminders),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(RouteNames.addReminder, extra: DateTime.now());
          ref.invalidate(_allRemindersProvider);
        },
        tooltip: isBn ? 'রিমাইন্ডার যোগ করুন' : 'Add Reminder',
        child: const Icon(Icons.add),
      ),
      body: remindersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.error)),
        data: (reminders) {
          if (reminders.isEmpty) return _EmptyState(isBn: isBn);
          return _ReminderDateList(reminders: reminders, l10n: l10n, ref: ref);
        },
      ),
    );
  }
}

class _ReminderDateList extends StatelessWidget {
  final List<Reminder> reminders;
  final AppLocalizations l10n;
  final WidgetRef ref;

  const _ReminderDateList({
    required this.reminders,
    required this.l10n,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Reminder>> grouped = {};
    for (final r in reminders) {
      final key =
          '${r.dateTime.year}-${r.dateTime.month.toString().padLeft(2, '0')}-${r.dateTime.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(r);
    }
    final keys = grouped.keys.toList()..sort();

    // Build items list with native ad injected after the 2nd date group
    final items = <Widget>[];
    for (int i = 0; i < keys.length; i++) {
      final key = keys[i];
      final dayReminders = grouped[key]!;
      final date = DateTime.parse(key);

      items.add(_DateSection(
        date: date,
        reminders: dayReminders,
        l10n: l10n,
        onRefresh: () => ref.invalidate(_allRemindersProvider),
      ));

      // Inject native ad after the 2nd date group
      if (i == 1) {
        items.add(const NativeAdWidget(style: NativeAdStyle.card));
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: items,
    );
  }
}

class _DateSection extends StatelessWidget {
  final DateTime date;
  final List<Reminder> reminders;
  final AppLocalizations l10n;
  final VoidCallback onRefresh;

  const _DateSection({
    required this.date,
    required this.reminders,
    required this.l10n,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sectionDate = DateTime(date.year, date.month, date.day);
    final isToday = sectionDate == today;
    final isPast = sectionDate.isBefore(today);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          color:
              isToday ? cs.primaryContainer.withValues(alpha: 0.3) : cs.surface,
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: isToday
                      ? cs.primary
                      : isPast
                          ? cs.outlineVariant
                          : cs.tertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _buildDateLabel(isToday),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isToday
                      ? cs.primary
                      : isPast
                          ? cs.onSurfaceVariant
                          : cs.onSurface,
                ),
              ),
            ],
          ),
        ),
        ...reminders.map((r) => _ReminderCard(
              reminder: r,
              isPast: isPast,
              l10n: l10n,
              onRefresh: onRefresh,
            )),
        const SizedBox(height: 4),
      ],
    );
  }

  String _buildDateLabel(bool isToday) {
    final isBn = l10n.languageCode == 'bn';
    if (isToday) return isBn ? 'আজ' : 'Today';
    final day = l10n.localizeNumber(date.day);
    final month = l10n.getMonthName(date.month);
    final year = l10n.localizeNumber(date.year);
    return '$day $month $year';
  }
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final bool isPast;
  final AppLocalizations l10n;
  final VoidCallback onRefresh;

  const _ReminderCard({
    required this.reminder,
    required this.isPast,
    required this.l10n,
    required this.onRefresh,
  });

  Color _priorityColor(ReminderPriority p, ColorScheme cs) {
    switch (p) {
      case ReminderPriority.low:
        return Colors.green.shade400;
      case ReminderPriority.medium:
        return cs.primary;
      case ReminderPriority.high:
        return Colors.orange.shade600;
      case ReminderPriority.urgent:
        return Colors.red.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isBn = l10n.languageCode == 'bn';
    final priorityColor = _priorityColor(reminder.priority, cs);
    final isOverdue = reminder.isOverdue;

    return Opacity(
      opacity: reminder.isCompleted ? 0.5 : (isPast && !isOverdue ? 0.6 : 1.0),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isOverdue
              ? Colors.red.shade50.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.07 : 1.0)
              : cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOverdue
                ? Colors.red.shade300.withValues(alpha: 0.5)
                : cs.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              reminder.isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.alarm_rounded,
              size: 20,
              color: priorityColor,
            ),
          ),
          title: Text(
            reminder.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              decoration:
                  reminder.isCompleted ? TextDecoration.lineThrough : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _buildSubtitle(isBn, isOverdue),
            style: theme.textTheme.bodySmall?.copyWith(
              color: isOverdue ? Colors.red.shade400 : cs.onSurfaceVariant,
            ),
          ),
          trailing:
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 18),
          onTap: () async {
            await context.push(RouteNames.editReminder, extra: reminder);
            onRefresh();
          },
        ),
      ),
    );
  }

  String _buildSubtitle(bool isBn, bool isOverdue) {
    final h =
        l10n.localizeNumber(reminder.dateTime.hour.toString().padLeft(2, '0'));
    final m = l10n
        .localizeNumber(reminder.dateTime.minute.toString().padLeft(2, '0'));
    final timeStr = '$h:$m';
    if (isOverdue) {
      return isBn ? '$timeStr  •  মেয়াদোত্তীর্ণ' : '$timeStr  •  Overdue';
    }
    return timeStr;
  }
}

class _EmptyState extends StatelessWidget {
  final bool isBn;
  const _EmptyState({required this.isBn});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.alarm_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            isBn ? 'কোনো রিমাইন্ডার নেই' : 'No reminders yet',
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            isBn ? 'নিচের + বোতামে চাপুন' : 'Tap + to add your first reminder',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
