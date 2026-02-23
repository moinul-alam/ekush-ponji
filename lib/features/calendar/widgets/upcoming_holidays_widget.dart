import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

class UpcomingHolidaysWidget extends StatelessWidget {
  final String monthName;
  final List<Holiday> holidays;
  final int maxItems;

  const UpcomingHolidaysWidget({
    super.key,
    required this.monthName,
    required this.holidays,
    this.maxItems = 10,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final isBangla = localizations.locale.languageCode == 'bn';

    final allHolidays = holidays.take(maxItems).toList();

    if (allHolidays.isEmpty) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: theme.dividerColor, width: 1),
    ),
    child: Row(
      children: [
        Icon(Icons.celebration_outlined,
            color: theme.colorScheme.onSurfaceVariant, size: 20),
        const SizedBox(width: 8),
        Text(
          isBangla ? 'এই মাসে কোনো ছুটি নেই' : 'No holidays available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
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
                Icons.celebration,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isBangla
                    ? '$monthName-এর ছুটির দিন'
                    : 'Holidays in $monthName',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Holiday items
          ...allHolidays.map((holiday) {
            final isPast = holiday.daysUntil < 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Opacity(
                opacity: isPast ? 0.5 : 1.0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date badge — single or range
                    _buildDateBadge(holiday, isPast, localizations, theme),

                    const SizedBox(width: 12),

                    // Holiday details
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
                          const SizedBox(height: 4),
                          Text(
                            isPast
                                ? localizations.passed
                                : holiday.daysUntil == 0
                                    ? localizations.today
                                    : '${localizations.formatDaysDistance(holiday.daysUntil)} ${isBangla ? (holiday.descriptionbn ?? holiday.description ?? '') : (holiday.description ?? '')}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isPast
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ------------------- Date Badge -------------------

  Widget _buildDateBadge(
    Holiday holiday,
    bool isPast,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    final isRange = holiday.isMultiDay;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(isPast ? 0.05 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withOpacity(isPast ? 0.15 : 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isRange) ...[
            // Range: show "19-23"
            Text(
              '${localizations.localizeNumber(holiday.date.day)}-${localizations.localizeNumber(holiday.endDate!.day)}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 10,
              ),
            ),
          ] else ...[
            // Single day: show day number
            Text(
              localizations.localizeNumber(holiday.date.day),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
          // Month abbreviation always shown
          Text(
            localizations.getMonthAbbreviation(holiday.date.month),
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}