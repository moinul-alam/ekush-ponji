// lib/features/home/widgets/home_holidays_widget.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

class HomeHolidaysWidget extends StatefulWidget {
  final List<Holiday> holidays;

  const HomeHolidaysWidget({
    super.key,
    required this.holidays,
  });

  @override
  State<HomeHolidaysWidget> createState() => _HomeHolidaysWidgetState();
}

class _HomeHolidaysWidgetState extends State<HomeHolidaysWidget> {
  static const int _collapseThreshold = 3;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final monthName = l10n.getMonthName(DateTime.now().month);

    final visibleHolidays = _showAll
        ? widget.holidays
        : widget.holidays.take(_collapseThreshold).toList();

    final hasMore = widget.holidays.length > _collapseThreshold;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Section Header ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 22,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.sectionHolidays,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          l10n.formatUpcomingHolidaysInMonth(monthName),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Count badge
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
                          size: 12, color: cs.onPrimaryContainer),
                      const SizedBox(width: 4),
                      Text(
                        l10n.localizeNumber(widget.holidays.length),
                        style: theme.textTheme.labelSmall?.copyWith(
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

          // ─── Empty State ──────────────────────────────────
          if (widget.holidays.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.event_busy_outlined,
                        color: cs.onSurfaceVariant, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      l10n.noUpcomingHolidays,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ─── Vertical List ────────────────────────────────
          if (widget.holidays.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              child: Column(
                children: [
                  ...visibleHolidays.asMap().entries.map((entry) {
                    final index = entry.key;
                    final holiday = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < visibleHolidays.length - 1 ? 8 : 0,
                      ),
                      child: _HolidayListItem(
                        holiday: holiday,
                        l10n: l10n,
                        theme: theme,
                      ),
                    );
                  }),

                  // ── Show more / less button ────────────────
                  if (hasMore) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(() => _showAll = !_showAll),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: cs.outlineVariant.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _showAll
                                  ? (l10n.languageCode == 'bn'
                                      ? 'কম দেখাও'
                                      : 'Show less')
                                  : (l10n.languageCode == 'bn'
                                      ? 'আরও ${l10n.localizeNumber(widget.holidays.length - _collapseThreshold)}টি দেখাও'
                                      : 'Show ${widget.holidays.length - _collapseThreshold} more'),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _showAll
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 18,
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
    final typeColor = _typeColor(holiday.type);
    final cs = theme.colorScheme;

    return Opacity(
      opacity: isPast ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday
                ? typeColor.withOpacity(0.5)
                : cs.outlineVariant.withOpacity(0.3),
            width: isToday ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: typeColor.withOpacity(isPast ? 0.02 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Left color bar ────────────────────────────
            Container(
              width: 4,
              height: 64,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),

            // ── Date badge ────────────────────────────────
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dateLabel(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: typeColor,
                      fontSize: holiday.isMultiDay ? 13 : 22,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    l10n.getMonthAbbreviation(holiday.date.month),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            // ── Divider ───────────────────────────────────
            Container(
              width: 1,
              height: 40,
              color: cs.outlineVariant.withOpacity(0.4),
            ),

            const SizedBox(width: 12),

            // ── Holiday info ──────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Type chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_typeIcon(holiday.type),
                              color: typeColor, size: 9),
                          const SizedBox(width: 3),
                          Text(
                            _typeLabel(holiday.type),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: typeColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Holiday name
                    Text(
                      l10n.languageCode == 'bn'
                          ? holiday.namebn
                          : holiday.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // ── Days-until / status pill ──────────────────
            Padding(
              padding: const EdgeInsets.only(right: 12),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: typeColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          l10n.today,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
      );
    }

    if (isPast) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          l10n.passed,
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: typeColor.withOpacity(0.2), width: 1),
      ),
      child: Text(
        l10n.formatDaysDistance(holiday.daysUntil),
        style: theme.textTheme.labelSmall?.copyWith(
          color: typeColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  String _dateLabel() {
    if (holiday.isMultiDay) {
      return '${l10n.localizeNumber(holiday.date.day)}–'
          '${l10n.localizeNumber(holiday.endDate!.day)}';
    }
    return l10n.localizeNumber(holiday.date.day);
  }

  Color _typeColor(HolidayType type) {
    switch (type) {
      case HolidayType.national:
        return const Color(0xFF1565C0);
      case HolidayType.religious:
        return const Color(0xFF2E7D32);
      case HolidayType.cultural:
        return const Color(0xFFE65100);
      case HolidayType.optional:
        return const Color(0xFF6A1B9A);
    }
  }

  IconData _typeIcon(HolidayType type) {
    switch (type) {
      case HolidayType.national:
        return Icons.flag_rounded;
      case HolidayType.religious:
        return Icons.mosque_rounded;
      case HolidayType.cultural:
        return Icons.festival_rounded;
      case HolidayType.optional:
        return Icons.event_outlined;
    }
  }

  String _typeLabel(HolidayType type) {
    final isBangla = l10n.languageCode == 'bn';
    switch (type) {
      case HolidayType.national:
        return isBangla ? 'জাতীয়' : 'National';
      case HolidayType.religious:
        return isBangla ? 'ধর্মীয়' : 'Religious';
      case HolidayType.cultural:
        return isBangla ? 'সাংস্কৃতিক' : 'Cultural';
      case HolidayType.optional:
        return isBangla ? 'ঐচ্ছিক' : 'Optional';
    }
  }
}