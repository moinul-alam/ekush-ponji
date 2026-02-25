// lib/features/home/widgets/today_date_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/services/bengali_calendar_service.dart';
import 'package:ekush_ponji/core/services/hijri_calendar_service.dart';
import 'package:ekush_ponji/features/calendar/models/bengali_date.dart';
import 'package:ekush_ponji/features/calendar/models/hijri_date.dart';
import 'package:ekush_ponji/features/home/widgets/home_section_widget.dart';
import 'package:ekush_ponji/app/router/route_names.dart';

class TodayDateWidget extends ConsumerWidget {
  const TodayDateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final bengaliDate = ref.watch(bengaliCalendarServiceProvider).getBengaliDate(now);
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
          // ── Row 1: Gregorian (tertiaryContainer) ───────
          _DateRow(
            dayNum: l10n.localizeNumber(gregorianDate.day),
            month: l10n.getMonthName(gregorianDate.month),
            year: l10n.localizeNumber(gregorianDate.year),
            era: isBn ? 'খ্রিস্টাব্দ' : 'AD',
            season: l10n.getGregorianSeasonName(gregorianDate.month),
            backgroundColor: cs.tertiaryContainer,
            textColor: cs.onTertiaryContainer,
          ),

          // _OrnateDivider(
          //   topColor: cs.tertiaryContainer,
          //   bottomColor: cs.primaryContainer,
          //   diamondColor: cs.tertiary,
          //   lineColor: cs.outline,
          // ),

          // ── Row 2: Bengali (primaryContainer) ──────────
          _DateRow(
            dayNum: isBn ? bengaliDate.dayBn : bengaliDate.day.toString(),
            month: isBn ? bengaliDate.monthNameBn : bengaliDate.monthName,
            year: isBn ? bengaliDate.yearBn : bengaliDate.year.toString(),
            era: isBn ? 'বঙ্গাব্দ' : 'BS',
            season: l10n.getBengaliSeasonName(bengaliDate.monthNumber),
            backgroundColor: cs.primaryContainer,
            textColor: cs.onPrimaryContainer,
          ),

          // _OrnateDivider(
          //   topColor: cs.primaryContainer,
          //   bottomColor: cs.secondaryContainer,
          //   diamondColor: cs.primary,
          //   lineColor: cs.outline,
          // ),

          // ── Row 3: Hijri (secondaryContainer) ──────────
          _DateRow(
            dayNum: hijriDate.dayForLocale(l10n.languageCode),
            month: hijriDate.monthNameForLocale(l10n.languageCode),
            year: hijriDate.yearForLocale(l10n.languageCode),
            era: isBn ? 'হিজরি' : 'AH',
            season: '',   // No season concept for Hijri
            backgroundColor: cs.secondaryContainer,
            textColor: cs.onSecondaryContainer,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DATE ROW — 3 equal sections, all centered
// ============================================================================

class _DateRow extends StatelessWidget {
  final String dayNum;
  final String month;
  final String year;
  final String era;
  final String season; // empty string hides the third column gracefully
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

    final labelStyle = theme.textTheme.titleSmall?.copyWith(
      color: textColor.withValues(alpha: 0.85),
      fontWeight: FontWeight.w600,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Section 1: Day + Month ─────────────────────
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  dayNum,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  month,
                  style: labelStyle,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          _VerticalDivider(color: dividerColor),

          // ── Section 2: Year + Era side-by-side ─────────
          Expanded(
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 5,
                children: [
                  Text(
                    year,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    era,
                    style: labelStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          _VerticalDivider(color: dividerColor),

          // ── Section 3: Season (hidden for Hijri) ───────
          Expanded(
            child: season.isEmpty
                ? Center(
                    child: Icon(
                      Icons.mosque_outlined,
                      color: textColor.withValues(alpha: 0.4),
                      size: 20,
                    ),
                  )
                : Text(
                    season,
                    style: labelStyle,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
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
      height: 44,
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
      height: 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: 8,
            child: ColoredBox(color: topColor),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0, height: 8,
            child: ColoredBox(color: bottomColor),
          ),
          Positioned(
            left: 24,
            right: 24,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    lineColor.withValues(alpha: 0.0),
                    lineColor.withValues(alpha: 0.3),
                    lineColor.withValues(alpha: 0.3),
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
                    color: diamondColor.withValues(alpha: 0.45),
                    blurRadius: 8,
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
                const SizedBox(width: 28),
                const SizedBox(width: 10),
                const SizedBox(width: 28),
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