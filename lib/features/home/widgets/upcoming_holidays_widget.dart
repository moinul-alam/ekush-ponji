import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/home/widgets/home_section_widget.dart';

/// Displays upcoming holidays
/// TODO: Replace sample data with API call
class UpcomingHolidaysWidget extends StatelessWidget {
  final List<Holiday>? holidays;
  final int maxDisplay;

  const UpcomingHolidaysWidget({
    super.key,
    this.holidays,
    this.maxDisplay = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    // Use sample data if no holidays provided
    final displayHolidays = holidays ?? _getSampleHolidays();
    final limitedHolidays = displayHolidays.take(maxDisplay).toList();

    if (limitedHolidays.isEmpty) {
      return const SizedBox.shrink();
    }

    return HomeSectionWidget(
      title: l10n.upcomingHolidays,
      trailing: Icon(
        Icons.celebration_outlined,
        color: colorScheme.primary,
      ),
      child: Column(
        children: [
          ...limitedHolidays.asMap().entries.map((entry) {
            final index = entry.key;
            final holiday = entry.value;
            final isLast = index == limitedHolidays.length - 1;

            return Column(
              children: [
                _HolidayItem(holiday: holiday),
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

  // TODO: Replace with API call
  List<Holiday> _getSampleHolidays() {
    return [
      Holiday(
        name: 'Victory Day',
        namebn: 'বিজয় দিবস',
        date: DateTime(2025, 12, 16),
        type: HolidayType.national,
        description: 'Commemorates the victory in the Liberation War',
      ),
      Holiday(
        name: 'Eid ul-Fitr',
        namebn: 'ঈদুল ফিতর',
        date: DateTime(2026, 3, 31),
        type: HolidayType.religious,
        description: 'Festival of breaking the fast',
      ),
      Holiday(
        name: 'Pohela Boishakh',
        namebn: 'পহেলা বৈশাখ',
        date: DateTime(2026, 4, 14),
        type: HolidayType.cultural,
        description: 'Bengali New Year',
      ),
    ];
  }
}

class _HolidayItem extends StatelessWidget {
  final Holiday holiday;

  const _HolidayItem({required this.holiday});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isBangla = l10n.languageCode == 'bn';
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final holidayDate = DateTime(holiday.date.year, holiday.date.month, holiday.date.day);
    final daysUntil = holidayDate.difference(today).inDays;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date badge
        Container(
          width: 60,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: _getTypeColor(holiday.type, colorScheme),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                l10n.localizeNumber(holiday.date.day),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
              Text(
                l10n.getMonthAbbreviation(holiday.date.month),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Holiday details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBangla ? holiday.namebn : holiday.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              if (!isBangla) ...[
                const SizedBox(height: 2),
                Text(
                  holiday.namebn,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  daysUntil < 0
                      ? l10n.passed
                      : l10n.formatDaysDistance(daysUntil),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Type icon
        Icon(
          _getTypeIcon(holiday.type),
          color: _getTypeColor(holiday.type, colorScheme),
          size: 24,
        ),
      ],
    );
  }

  Color _getTypeColor(HolidayType type, ColorScheme colorScheme) {
    switch (type) {
      case HolidayType.national:
        return colorScheme.primary;
      case HolidayType.religious:
        return colorScheme.tertiary;
      case HolidayType.cultural:
        return colorScheme.secondary;
    }
  }

  IconData _getTypeIcon(HolidayType type) {
    switch (type) {
      case HolidayType.national:
        return Icons.flag_rounded;
      case HolidayType.religious:
        return Icons.mosque_rounded;
      case HolidayType.cultural:
        return Icons.festival_rounded;
    }
  }

}

// Models
class Holiday {
  final String name;
  final String namebn;
  final DateTime date;
  final HolidayType type;
  final String? description;

  Holiday({
    required this.name,
    required this.namebn,
    required this.date,
    required this.type,
    this.description,
  });

  // TODO: Add fromJson factory for API integration
  // factory Holiday.fromJson(Map<String, dynamic> json) {
  //   return Holiday(
  //     name: json['name'],
  //     namebn: json['name_bn'],
  //     date: DateTime.parse(json['date']),
  //     type: HolidayType.values.byName(json['type']),
  //     description: json['description'],
  //   );
  // }
}

enum HolidayType {
  national,
  religious,
  cultural,
}
