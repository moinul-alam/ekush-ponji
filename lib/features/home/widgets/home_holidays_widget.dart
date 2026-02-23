import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

/// Displays current month holidays on the home screen
/// Horizontal scroll card style with rich visual design
class HomeHolidaysWidget extends StatelessWidget {
  final List<Holiday> holidays;

  const HomeHolidaysWidget({
    super.key,
    required this.holidays,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final monthName = l10n.getMonthName(DateTime.now().month);

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
                        l10n.localizeNumber(holidays.length),
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

          const SizedBox(height: 14),

          // ─── Empty State ──────────────────────────────────
          if (holidays.isEmpty)
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

          // ─── Horizontal Scroll Cards ──────────────────────
          if (holidays.isNotEmpty)
            SizedBox(
              height: 178,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: holidays.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                        right: index < holidays.length - 1 ? 10 : 0),
                    child: _HolidayCard(
                      holiday: holidays[index],
                      l10n: l10n,
                      theme: theme,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Holiday Card ─────────────────────────────────────────────
class _HolidayCard extends StatelessWidget {
  final Holiday holiday;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _HolidayCard({
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
      opacity: isPast ? 0.5 : 1.0,
      child: Container(
        width: 148,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday
                ? typeColor.withOpacity(0.6)
                : typeColor.withOpacity(0.18),
            width: isToday ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: typeColor.withOpacity(isPast ? 0.03 : 0.09),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Colored header strip ───────────────────────
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Type chip row ─────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
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
                        if (isToday)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: typeColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              l10n.today,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const Spacer(),

                    // ── Large day number ──────────────────────
                    Text(
                      _dateLabel(),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: typeColor,
                        fontSize: 38,
                        height: 1.0,
                      ),
                    ),

                    // ── Month name ────────────────────────────
                    Text(
                      l10n.getMonthName(holiday.date.month),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Holiday name ──────────────────────────
                    Text(
                      l10n.languageCode == 'bn'
                          ? holiday.namebn
                          : holiday.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        height: 1.25,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // ── Days-until pill ───────────────────────
                    if (!isPast && !isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: typeColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          l10n.formatDaysDistance(holiday.daysUntil),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),

                    if (isPast)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
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
                      ),
                  ],
                ),
              ),
            ),
          ],
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