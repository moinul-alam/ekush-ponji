import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

/// Displays all holidays for the selected calendar month
/// Vertical list style — distinct from HomeHolidaysWidget
class CalendarHolidaysWidget extends StatelessWidget {
  final String monthName;
  final List<Holiday> holidays;

  const CalendarHolidaysWidget({
    super.key,
    required this.monthName,
    required this.holidays,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final isBangla = localizations.locale.languageCode == 'bn';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isBangla
                          ? '$monthName-এর সরকারি ছুটি'
                          : '$monthName Holidays',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isBangla
                        ? localizations.localizeNumber(holidays.length)
                        : '${holidays.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withOpacity(0.4),
          ),

          // ─── Empty State ────────────────────────────────────
          if (holidays.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBangla
                        ? '$monthName মাসে কোনো ছুটি নেই'
                        : 'No holidays in $monthName',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

          // ─── Holiday List ───────────────────────────────────
          if (holidays.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: holidays.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.colorScheme.outlineVariant.withOpacity(0.3),
              ),
              itemBuilder: (context, index) {
                final holiday = holidays[index];
                return _CalendarHolidayItem(
                  holiday: holiday,
                  isBangla: isBangla,
                  localizations: localizations,
                  theme: theme,
                );
              },
            ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─── Holiday List Item ────────────────────────────────────────
class _CalendarHolidayItem extends StatelessWidget {
  final Holiday holiday;
  final bool isBangla;
  final AppLocalizations localizations;
  final ThemeData theme;

  const _CalendarHolidayItem({
    required this.holiday,
    required this.isBangla,
    required this.localizations,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = holiday.daysUntil < 0;
    final typeColor = _typeColor(holiday.type);

    return Opacity(
      opacity: isPast ? 0.55 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // ─── Left accent bar + date ─────────────────────
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // ─── Date block ─────────────────────────────────
            Container(
              width: 44,
              height: 48,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    holiday.isMultiDay
                        ? '${localizations.localizeNumber(holiday.date.day)}-${localizations.localizeNumber(holiday.endDate!.day)}'
                        : localizations.localizeNumber(holiday.date.day),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: typeColor,
                      fontSize: holiday.isMultiDay ? 10 : 14,
                    ),
                  ),
                  Text(
                    localizations.getMonthAbbreviation(holiday.date.month),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: typeColor.withOpacity(0.8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ─── Name + description ─────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBangla ? holiday.namebn : holiday.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (isBangla && holiday.name.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      holiday.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ─── Right: type chip + days until ─────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_typeIcon(holiday.type),
                          color: typeColor, size: 10),
                      const SizedBox(width: 3),
                      Text(
                        _typeLabel(holiday.type, isBangla),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: typeColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPast
                      ? localizations.passed
                      : holiday.daysUntil == 0
                          ? localizations.today
                          : localizations
                              .formatDaysDistance(holiday.daysUntil),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isPast
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  String _typeLabel(HolidayType type, bool isBangla) {
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