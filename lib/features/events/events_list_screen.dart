// lib/features/events/events_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/widgets/ads/native_ad_widget.dart';
import 'package:ekush_ponji/features/events/models/event.dart';
import 'package:ekush_ponji/features/events/data/event_repository.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';

final _allEventsProvider = FutureProvider<List<Event>>((ref) async {
  final repo = ref.read(eventRepositoryProvider);
  final all = await repo.getAllEvents();
  all.sort((a, b) => a.startTime.compareTo(b.startTime));
  return all;
});

class EventsListScreen extends ConsumerWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.languageCode == 'bn';
    final eventsAsync = ref.watch(_allEventsProvider);

    return Scaffold(
      appBar: AppHeader(pageTitle: l10n.allEvents),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(RouteNames.addEvent, extra: DateTime.now());
          ref.invalidate(_allEventsProvider);
        },
        tooltip: l10n.addEvent,
        child: const Icon(Icons.add),
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.error)),
        data: (events) {
          if (events.isEmpty) return _EmptyState(isBn: isBn);
          return _EventDateList(events: events, l10n: l10n, ref: ref);
        },
      ),
    );
  }
}

class _EventDateList extends StatelessWidget {
  final List<Event> events;
  final AppLocalizations l10n;
  final WidgetRef ref;

  const _EventDateList({
    required this.events,
    required this.l10n,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Event>> grouped = {};
    for (final e in events) {
      final key =
          '${e.startTime.year}-${e.startTime.month.toString().padLeft(2, '0')}-${e.startTime.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(e);
    }
    final keys = grouped.keys.toList()..sort();

    // Build items list with native ad injected after the 2nd date group
    final items = <Widget>[];
    for (int i = 0; i < keys.length; i++) {
      final key = keys[i];
      final dayEvents = grouped[key]!;
      final date = DateTime.parse(key);

      items.add(_DateSection(
        date: date,
        events: dayEvents,
        l10n: l10n,
        onRefresh: () => ref.invalidate(_allEventsProvider),
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
  final List<Event> events;
  final AppLocalizations l10n;
  final VoidCallback onRefresh;

  const _DateSection({
    required this.date,
    required this.events,
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
                          : cs.secondary,
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
        ...events.map((e) => _EventCard(
              event: e,
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

class _EventCard extends StatelessWidget {
  final Event event;
  final bool isPast;
  final AppLocalizations l10n;
  final VoidCallback onRefresh;

  const _EventCard({
    required this.event,
    required this.isPast,
    required this.l10n,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isBn = l10n.languageCode == 'bn';

    return Opacity(
      opacity: isPast ? 0.55 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
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
              color: cs.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.event_rounded, size: 20, color: cs.primary),
          ),
          title: Text(
            event.title,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _buildSubtitle(isBn),
            style:
                theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          trailing:
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 18),
          onTap: () async {
            await context.push(RouteNames.editEvent, extra: event);
            onRefresh();
          },
        ),
      ),
    );
  }

  String _buildSubtitle(bool isBn) {
    if (event.isAllDay) return isBn ? 'সারাদিন' : 'All day';
    final h =
        l10n.localizeNumber(event.startTime.hour.toString().padLeft(2, '0'));
    final m =
        l10n.localizeNumber(event.startTime.minute.toString().padLeft(2, '0'));
    final timeStr = '$h:$m';
    if (event.location != null && event.location!.isNotEmpty) {
      return '$timeStr  •  ${event.location}';
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
          Icon(Icons.event_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            isBn ? 'কোনো ইভেন্ট নেই' : 'No events yet',
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            isBn ? 'নিচের + বোতামে চাপুন' : 'Tap + to add your first event',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
