// lib/features/home/widgets/home_holidays_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

class HomeHolidaysWidget extends ConsumerStatefulWidget {
  final List<Holiday> holidays;

  const HomeHolidaysWidget({
    super.key,
    required this.holidays,
  });

  @override
  ConsumerState<HomeHolidaysWidget> createState() => _HomeHolidaysWidgetState();
}

class _HomeHolidaysWidgetState extends ConsumerState<HomeHolidaysWidget> {
  static const int _collapseThreshold = 3;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final mandatoryHolidays =
        widget.holidays.where((h) => h.isMandatory).toList();

    final visibleHolidays = _showAll
        ? mandatoryHolidays
        : mandatoryHolidays.take(_collapseThreshold).toList();

    final hasMore = mandatoryHolidays.length > _collapseThreshold;

    return GestureDetector(
      onTap: () => context.push(RouteNames.holidays),
      child: Container(
        margin: const EdgeInsets.fromLTRB(4, 1, 4, 1),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Section Header ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Text(
                        l10n.upcomingHolidays,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.celebration_outlined,
                            size: 13, color: cs.onPrimaryContainer),
                        const SizedBox(width: 4),
                        Text(
                          l10n.localizeNumber(mandatoryHolidays.length),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ─── Empty State ────────────────────────────────
            if (mandatoryHolidays.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.event_busy_outlined,
                          color: cs.onSurfaceVariant, size: 32),
                      const SizedBox(height: 10),
                      Text(
                        l10n.noUpcomingHolidays,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ─── List ───────────────────────────────────────
            if (widget.holidays.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                child: Column(
                  children: [
                    ...visibleHolidays.asMap().entries.map((entry) {
                      final index = entry.key;
                      final holiday = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < visibleHolidays.length - 1 ? 10 : 0,
                        ),
                        child: _HolidayListItem(
                          holiday: holiday,
                          l10n: l10n,
                          theme: theme,
                        ),
                      );
                    }),
                    if (hasMore) ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => setState(() => _showAll = !_showAll),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _showAll
                                    ? l10n.showLess
                                    : l10n.showMore(mandatoryHolidays.length -
                                        _collapseThreshold),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _showAll
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: cs.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── List Item ────────────────────────────────────────────────
class _HolidayListItem extends StatelessWidget {
  final Holiday holiday;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _HolidayListItem({
    required this.holiday,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = holiday.daysUntil < 0;
    final isToday = holiday.daysUntil == 0;
    final typeColor = _typeColor(holiday.category);
    final cs = theme.colorScheme;

    return Opacity(
      opacity: isPast ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isToday
                ? typeColor.withValues(alpha: 0.5)
                : cs.outlineVariant.withValues(alpha: 0.3),
            width: isToday ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: typeColor.withValues(alpha: isPast ? 0.02 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 72,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Container(
              width: 58,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dateLabel(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: typeColor,
                      fontSize: holiday.isMultiDay ? 15 : null,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.getMonthAbbreviation(holiday.startDate.month),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 44,
              color: cs.outlineVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      _typeIcon(holiday.category),
                      color: typeColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.languageCode == 'bn'
                            ? holiday.namebn
                            : holiday.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: _buildStatusPill(isToday, isPast, typeColor, cs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(
      bool isToday, bool isPast, Color typeColor, ColorScheme cs) {
    if (isToday) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: typeColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          l10n.today,
          style: theme.textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    if (isPast) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          l10n.passed,
          style: theme.textTheme.labelMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: typeColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        l10n.formatDaysDistance(holiday.daysUntil),
        style: theme.textTheme.labelMedium?.copyWith(
          color: typeColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _dateLabel() {
    if (holiday.isMultiDay) {
      return '${l10n.localizeNumber(holiday.startDate.day)}–'
          '${l10n.localizeNumber(holiday.endDate!.day)}';
    }
    return l10n.localizeNumber(holiday.startDate.day);
  }

  Color _typeColor(HolidayCategory category) {
    switch (category) {
      case HolidayCategory.national:
        return const Color(0xFF1565C0);
      case HolidayCategory.islamic:
        return const Color(0xFF2E7D32);
      case HolidayCategory.hindu:
        return const Color(0xFFE65100);
      case HolidayCategory.christian:
        return const Color(0xFF6A1B9A);
      case HolidayCategory.buddhist:
        return const Color(0xFFF9A825);
      case HolidayCategory.ethnicMinority:
        return const Color(0xFF00838F);
      case HolidayCategory.cultural:
        return const Color(0xFFC62828);
    }
  }

  IconData _typeIcon(HolidayCategory category) {
    switch (category) {
      case HolidayCategory.national:
        return Icons.flag_rounded;
      case HolidayCategory.islamic:
        return Icons.mosque_rounded;
      case HolidayCategory.hindu:
        return Icons.temple_hindu_rounded;
      case HolidayCategory.christian:
        return Icons.church_rounded;
      case HolidayCategory.buddhist:
        return Icons.self_improvement_rounded;
      case HolidayCategory.ethnicMinority:
        return Icons.diversity_3_rounded;
      case HolidayCategory.cultural:
        return Icons.festival_rounded;
    }
  }

  // String _typeLabel(HolidayCategory category) {
  //   final isBangla = l10n.languageCode == 'bn';
  //   switch (category) {
  //     case HolidayCategory.national:
  //       return isBangla ? 'জাতীয়' : 'National';
  //     case HolidayCategory.islamic:
  //       return isBangla ? 'ইসলামী' : 'Islamic';
  //     case HolidayCategory.hindu:
  //       return isBangla ? 'হিন্দু' : 'Hindu';
  //     case HolidayCategory.christian:
  //       return isBangla ? 'খ্রিষ্টান' : 'Christian';
  //     case HolidayCategory.buddhist:
  //       return isBangla ? 'বৌদ্ধ' : 'Buddhist';
  //     case HolidayCategory.ethnicMinority:
  //       return isBangla ? 'নৃ-গোষ্ঠী' : 'Ethnic';
  //     case HolidayCategory.cultural:
  //       return isBangla ? 'সাংস্কৃতিক' : 'Cultural';
  //   }
  // }
}
