// lib/features/home/widgets/today_date_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/calendar/services/bengali_calendar_service.dart';
import 'package:ekush_ponji/features/calendar/services/hijri_calendar_service.dart';
import 'package:ekush_ponji/features/calendar/models/bengali_date.dart';
import 'package:ekush_ponji/features/calendar/models/hijri_date.dart';
import 'package:ekush_ponji/features/home/widgets/home_section_widget.dart';
import 'package:ekush_ponji/app/router/route_names.dart';

const List<String> _enMonths = [
  '',
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _enGregorianSeason(int month) {
  if (month >= 3 && month <= 5) return 'Spring';
  if (month >= 6 && month <= 8) return 'Summer';
  if (month >= 9 && month <= 11) return 'Autumn';
  return 'Winter';
}

// ── Today Header Row ──────────────────────────────────────────

class _TodayHeaderRow extends StatelessWidget {
  final DateTime gregorianDate;

  const _TodayHeaderRow({required this.gregorianDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final dayName = l10n.getDayName(gregorianDate.weekday);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      color: cs.primary,
      child: Center(
        child: RichText(
          text: TextSpan(
            style: theme.textTheme.titleMedium?.copyWith(
              color: cs.onPrimary,
              fontSize: 24,
              height: 1.0,
            ),
            children: [
              TextSpan(
                text: '${l10n.today} ',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text: dayName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TodayDateWidget extends ConsumerWidget {
  const TodayDateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final bengaliDate =
        ref.watch(bengaliCalendarServiceProvider).getBengaliDate(now);
    final hijriDate = ref.watch(hijriCalendarServiceProvider).getHijriDate(now);

    return HomeSectionWidget(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      onTap: () => context.go(RouteNames.calendar),
      child: _MergedDateCard(
        bengaliDate: bengaliDate,
        hijriDate: hijriDate,
        gregorianDate: now,
      ),
    );
  }
}

// ── Merged Date Card ──────────────────────────────────────────

class _MergedDateCard extends StatelessWidget {
  final BengaliDate bengaliDate;
  final HijriDate hijriDate;
  final DateTime gregorianDate;

  const _MergedDateCard({
    required this.bengaliDate,
    required this.hijriDate,
    required this.gregorianDate,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.languageCode == 'bn';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          // ── New top card ────────────────────────────────
          _TodayHeaderRow(gregorianDate: gregorianDate),

          // ── Gregorian ───────────────────────────────────
          _DateRow(
            dayNum: gregorianDate.day.toString(),
            monthYearEra:
                '${_enMonths[gregorianDate.month]} ${gregorianDate.year} AD',
            seasonOrIcon:
                _SeasonOrIcon.season(_enGregorianSeason(gregorianDate.month)),
            backgroundColor: cs.tertiaryContainer,
            textColor: cs.onTertiaryContainer,
          ),

          // ── Bengali ─────────────────────────────────────
          _DateRow(
            dayNum: isBn ? bengaliDate.dayBn : bengaliDate.day.toString(),
            monthYearEra:
                '${isBn ? bengaliDate.monthNameBn : bengaliDate.monthName} '
                '${isBn ? bengaliDate.yearBn : bengaliDate.year} '
                '${l10n.calendarShortBangla}',
            seasonOrIcon: _SeasonOrIcon.season(
                l10n.getBengaliSeasonName(bengaliDate.monthNumber)),
            backgroundColor: cs.primaryContainer,
            textColor: cs.onPrimaryContainer,
          ),

          // ── Hijri ────────────────────────────────────────
          _DateRow(
            dayNum: hijriDate.dayForLocale(l10n.languageCode),
            monthYearEra: '${hijriDate.monthNameForLocale(l10n.languageCode)} '
                '${hijriDate.yearForLocale(l10n.languageCode)} '
                '${l10n.calendarShortHijri}',
            seasonOrIcon: _SeasonOrIcon.icon(),
            backgroundColor: cs.secondaryContainer,
            textColor: cs.onSecondaryContainer,
          ),
        ],
      ),
    );
  }
}

// ── Season or Icon ────────────────────────────────────────────

class _SeasonOrIcon {
  final String? season;
  final bool isIcon;

  const _SeasonOrIcon.season(this.season) : isIcon = false;
  const _SeasonOrIcon.icon()
      : season = null,
        isIcon = true;
}

// ── Date Row ──────────────────────────────────────────────────

class _DateRow extends StatelessWidget {
  final String dayNum;
  final String monthYearEra;
  final _SeasonOrIcon seasonOrIcon;
  final Color backgroundColor;
  final Color textColor;

  const _DateRow({
    required this.dayNum,
    required this.monthYearEra,
    required this.seasonOrIcon,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = textColor.withValues(alpha: 0.15);

    final dayStyle = theme.textTheme.headlineLarge?.copyWith(
      color: textColor,
      fontWeight: FontWeight.w800,
      height: 1.0,
    );

    final dateLineStyle = theme.textTheme.titleMedium?.copyWith(
      color: textColor,
      fontWeight: FontWeight.w600,
      fontSize: 18,
      height: 1.0,
    );

    final seasonStyle = theme.textTheme.labelMedium?.copyWith(
      color: textColor,
      fontWeight: FontWeight.w600,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            child: Center(
              child: Text(dayNum, style: dayStyle),
            ),
          ),
          Container(
            width: 1,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  dividerColor.withValues(alpha: 0.0),
                  dividerColor,
                  dividerColor.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Expanded(
            child: Text(
              monthYearEra,
              style: dateLineStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          if (seasonOrIcon.isIcon)
            Icon(
              Icons.mosque_outlined,
              color: textColor.withValues(alpha: 0.4),
              size: 22,
            )
          else if (seasonOrIcon.season != null &&
              seasonOrIcon.season!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                seasonOrIcon.season!,
                style: seasonStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
