// lib/features/home/widgets/today_date_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/services/bengali_calendar_service.dart';
import 'package:ekush_ponji/features/calendar/models/bengali_date.dart';
import 'package:ekush_ponji/features/home/widgets/home_section_widget.dart';
import 'package:ekush_ponji/app/router/route_names.dart';

class TodayDateWidget extends ConsumerWidget {
  const TodayDateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final bengaliCalendarService = ref.watch(bengaliCalendarServiceProvider);
    final bengaliDate = bengaliCalendarService.getBengaliDate(now);

    return HomeSectionWidget(
      padding: EdgeInsets.zero,
      onTap: () => context.go(RouteNames.calendar),
      child: _MergedDateCard(
        bengaliDate: bengaliDate,
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
  final DateTime gregorianDate;

  const _MergedDateCard({
    required this.bengaliDate,
    required this.gregorianDate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.languageCode == 'bn';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          _DateRow(
            dayNum: isBn ? bengaliDate.dayBn : bengaliDate.day.toString(),
            month: isBn ? bengaliDate.monthNameBn : bengaliDate.monthName,
            year: isBn ? bengaliDate.yearBn : bengaliDate.year.toString(),
            era: isBn ? 'বঙ্গাব্দ' : 'BS',
            season: l10n.getBengaliSeasonName(bengaliDate.monthNumber),
            backgroundColor: colorScheme.primaryContainer,
            textColor: colorScheme.onPrimaryContainer,
          ),
          _OrnateDivider(
            topColor: colorScheme.primaryContainer,
            bottomColor: colorScheme.secondaryContainer,
            diamondColor: colorScheme.primary,
            lineColor: colorScheme.outline.withValues(alpha: 0.25),
          ),
          _DateRow(
            dayNum: l10n.localizeNumber(gregorianDate.day),
            month: l10n.getMonthName(gregorianDate.month),
            year: l10n.localizeNumber(gregorianDate.year),
            era: isBn ? 'খ্রিস্টাব্দ' : 'AD',
            season: l10n.getGregorianSeasonName(gregorianDate.month),
            backgroundColor: colorScheme.secondaryContainer,
            textColor: colorScheme.onSecondaryContainer,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DATE ROW — 33% | 33% | 33%
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

    final bodyStyle = theme.textTheme.titleSmall?.copyWith(
      color: textColor,
      fontWeight: FontWeight.bold,
    );

    final dividerColor = textColor.withValues(alpha: 0.2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 33% — day number + month
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  dayNum,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    month,
                    style: bodyStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          _VerticalDivider(color: dividerColor),
          // 33% — year + era
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(year, style: bodyStyle, overflow: TextOverflow.ellipsis),
                  Text(era, style: bodyStyle, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
          _VerticalDivider(color: dividerColor),
          // 33% — season
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                season,
                style: bodyStyle,
                overflow: TextOverflow.ellipsis,
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

// ============================================================================
// ORNATE HORIZONTAL DIVIDER
// ============================================================================

class _OrnateDivider extends StatelessWidget {
  final Color topColor;
  final Color bottomColor;
  final Color diamondColor;
  final Color lineColor;

  const _OrnateDivider({
    required this.topColor,
    required this.bottomColor,
    required this.diamondColor,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: 10,
            child: ColoredBox(color: topColor),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0, height: 10,
            child: ColoredBox(color: bottomColor),
          ),
          Positioned(
            left: 16,
            right: 16,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    lineColor.withValues(alpha: 0.0),
                    lineColor,
                    lineColor,
                    lineColor.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
          ),
          Transform.rotate(
            angle: 0.785398,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: diamondColor,
                boxShadow: [
                  BoxShadow(
                    color: diamondColor.withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _DotAccent(color: diamondColor),
                const SizedBox(width: 24),
                const SizedBox(width: 10),
                const SizedBox(width: 24),
                _DotAccent(color: diamondColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotAccent extends StatelessWidget {
  final Color color;

  const _DotAccent({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.5),
      ),
    );
  }
}