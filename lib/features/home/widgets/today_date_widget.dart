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
      onTap: () => context.go(RouteNames.calendar),
      child: _MergedDateCard(
        bengaliDate: bengaliDate,
        hijriDate: hijriDate,
        gregorianDate: now,
      ),
    );
  }
}

// ============================================================================
// MERGED DATE CARD
// ============================================================================

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
          // ── Row 1: Gregorian ────────────────────────────
          _DateRow(
            dayNum: l10n.localizeNumber(gregorianDate.day),
            month: l10n.getMonthName(gregorianDate.month),
            year: l10n.localizeNumber(gregorianDate.year),
            era: l10n.calendarShortGregorian,
            season: l10n.getGregorianSeasonName(gregorianDate.month),
            backgroundColor: cs.tertiaryContainer,
            textColor: cs.onTertiaryContainer,
          ),

          // ── Row 2: Bengali ──────────────────────────────
          _DateRow(
            dayNum: isBn ? bengaliDate.dayBn : bengaliDate.day.toString(),
            month: isBn ? bengaliDate.monthNameBn : bengaliDate.monthName,
            year: isBn ? bengaliDate.yearBn : bengaliDate.year.toString(),
            era: l10n.calendarShortBangla,
            season: l10n.getBengaliSeasonName(bengaliDate.monthNumber),
            backgroundColor: cs.primaryContainer,
            textColor: cs.onPrimaryContainer,
          ),

          // ── Row 3: Hijri ────────────────────────────────
          _DateRow(
            dayNum: hijriDate.dayForLocale(l10n.languageCode),
            month: hijriDate.monthNameForLocale(l10n.languageCode),
            year: hijriDate.yearForLocale(l10n.languageCode),
            era: l10n.calendarShortHijri,
            season: '',
            backgroundColor: cs.secondaryContainer,
            textColor: cs.onSecondaryContainer,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DATE ROW
// Layout: [day month] | [year era] | [season]
// e.g.:   ১ মার্চ    | ২০২৬ খ্রিস্টাব্দ | বসন্ত
// ============================================================================

class _DateRow extends StatelessWidget {
  final String dayNum;
  final String month;
  final String year;
  final String era;
  final String season;
  final Color backgroundColor;
  final Color textColor;

  const _DateRow({
    required this.dayNum,
    required this.month,
    required this.year,
    required this.era,
    required this.season,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = textColor.withValues(alpha: 0.2);

    final dateStyle = theme.textTheme.headlineMedium?.copyWith(
      color: textColor,
      fontWeight: FontWeight.bold,
      height: 1.0,
    );

    final secondaryStyle = theme.textTheme.titleSmall?.copyWith(
      color: textColor.withValues(alpha: 0.85),
      fontWeight: FontWeight.w500,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Section 1: day + month ───────────────────────
          Expanded(
            flex: 3,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    dayNum,
                    style: dateStyle, // headlineMedium — bigger
                  ),
                  const SizedBox(width: 6),
                  Text(
                    month,
                    style: secondaryStyle, // titleSmall — smaller
                  ),
                ],
              ),
            ),
          ),

          _VerticalDivider(color: dividerColor),

          // ── Section 2: year + era ────────────────────────
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                '$year $era',
                style: secondaryStyle,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),

          _VerticalDivider(color: dividerColor),

          // ── Section 3: season / hijri icon ───────────────
          Expanded(
            flex: 2,
            child: Center(
              child: season.isEmpty
                  ? Icon(
                      Icons.mosque_outlined,
                      color: textColor.withValues(alpha: 0.4),
                      size: 20,
                    )
                  : Text(
                      season,
                      style: secondaryStyle,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// VERTICAL DIVIDER
// ============================================================================

class _VerticalDivider extends StatelessWidget {
  final Color color;
  const _VerticalDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.0),
            color,
            color.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
