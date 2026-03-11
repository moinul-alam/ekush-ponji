import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

/// Displays all holidays for the selected calendar month in two sections:
/// 1. সরকারি ছুটি  — Mandatory (সাধারণ + নির্বাহী আদেশে ছুটি)
/// 2. ঔচ্ছিক ছুটি — Optional (community-specific holidays)
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

    final mandatory = holidays.where((h) => h.isMandatory).toList();
    final optional = holidays.where((h) => h.isOptional).toList();

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
          // ─── Mandatory Section ──────────────────────────────
          _HolidaySection(
            monthName: monthName,
            holidays: mandatory,
            isBangla: isBangla,
            localizations: localizations,
            theme: theme,
            isMandatory: true,
          ),

          // ─── Section separator ──────────────────────────────
          if (optional.isNotEmpty) ...[
            Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            ),

            // ─── Optional Section ─────────────────────────────
            _HolidaySection(
              monthName: monthName,
              holidays: optional,
              isBangla: isBangla,
              localizations: localizations,
              theme: theme,
              isMandatory: false,
            ),
          ],

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─── Section ──────────────────────────────────────────────────────────────────
class _HolidaySection extends StatelessWidget {
  final String monthName;
  final List<Holiday> holidays;
  final bool isBangla;
  final AppLocalizations localizations;
  final ThemeData theme;
  final bool isMandatory;

  const _HolidaySection({
    required this.monthName,
    required this.holidays,
    required this.isBangla,
    required this.localizations,
    required this.theme,
    required this.isMandatory,
  });

  String get _title {
    if (isBangla) {
      return isMandatory
          ? '$monthName মাসে সরকারি ছুটি'
          : '$monthName মাসে ঔচ্ছিক ছুটি';
    }
    return isMandatory
        ? '$monthName Public Holidays'
        : '$monthName Optional Holidays';
  }

  String get _emptyText {
    if (isBangla) {
      return isMandatory
          ? '$monthName মাসে কোনো সরকারি ছুটি নেই'
          : '$monthName মাসে কোনো ঔচ্ছিক ছুটি নেই';
    }
    return isMandatory
        ? 'No public holidays in $monthName'
        : 'No optional holidays in $monthName';
  }

  // Mandatory uses primary; optional uses tertiary
  Color get _headerColor =>
      isMandatory ? theme.colorScheme.primary : theme.colorScheme.tertiary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Header ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isMandatory
                        ? Icons.calendar_month_rounded
                        : Icons.event_available_rounded,
                    color: _headerColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _headerColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isBangla
                      ? localizations.localizeNumber(holidays.length)
                      : '${holidays.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _headerColor,
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

        // ─── Empty state ────────────────────────────────────
        if (holidays.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  _emptyText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

        // ─── List ────────────────────────────────────────────
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
            itemBuilder: (context, index) => _HolidayItem(
              holiday: holidays[index],
              isBangla: isBangla,
              localizations: localizations,
              theme: theme,
            ),
          ),
      ],
    );
  }
}

// ─── Holiday Item ─────────────────────────────────────────────────────────────
class _HolidayItem extends StatelessWidget {
  final Holiday holiday;
  final bool isBangla;
  final AppLocalizations localizations;
  final ThemeData theme;

  const _HolidayItem({
    required this.holiday,
    required this.isBangla,
    required this.localizations,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = holiday.daysUntil < 0;
    final catColor = _categoryColor(holiday.category);

    return Opacity(
      opacity: isPast ? 0.55 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // ─── Left accent bar ────────────────────────────
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: catColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // ─── Date block ─────────────────────────────────
            Container(
              width: 44,
              height: 48,
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    holiday.isMultiDay
                        ? '${localizations.localizeNumber(holiday.startDate.day)}-'
                            '${localizations.localizeNumber(holiday.endDate!.day)}'
                        : localizations.localizeNumber(holiday.startDate.day),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: catColor,
                      fontSize: holiday.isMultiDay ? 10 : 14,
                    ),
                  ),
                  Text(
                    localizations.getMonthAbbreviation(holiday.startDate.month),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: catColor.withOpacity(0.8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ─── Name + gazette label + regional note ────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isBangla ? holiday.namebn : holiday.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      // Moon icon for moon-sighting-dependent dates (e.g. Eid)
                      if (holiday.isApproximate) ...[
                        const SizedBox(width: 4),
                        Tooltip(
                          message: isBangla
                              ? 'চাঁদ দেখার উপর নির্ভরশীল'
                              : 'Subject to moon sighting',
                          child: Icon(
                            Icons.brightness_3_rounded,
                            size: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Gazette type — সরকারি শ্রেণিবিন্যাস
                  Text(
                    isBangla
                        ? holiday.gazetteType.displayNameBn
                        : holiday.gazetteType.displayName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  // Regional note if applicable
                  if (holiday.isRegional) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 10,
                          color: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            isBangla
                                ? (holiday.regionNoteBn ?? '')
                                : (holiday.regionNote ?? ''),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.tertiary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ─── Right: category chip + countdown ───────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Category chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _categoryIcon(holiday.category),
                        color: catColor,
                        size: 10,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isBangla
                            ? holiday.category.displayNameBn
                            : holiday.category.displayName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: catColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Countdown / passed label
                Text(
                  isPast
                      ? localizations.passed
                      : holiday.daysUntil == 0
                          ? localizations.today
                          : localizations.formatDaysDistance(holiday.daysUntil),
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

  Color _categoryColor(HolidayCategory category) {
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

  IconData _categoryIcon(HolidayCategory category) {
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
}
