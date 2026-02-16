// lib/features/home/widgets/today_date_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/services/bengali_calendar_service.dart';
import 'package:ekush_ponji/features/calendar/models/bengali_date.dart';
import 'package:ekush_ponji/features/home/widgets/home_section_widget.dart';
import 'package:ekush_ponji/app/router/route_names.dart';

/// Displays today's date in both Bengali and Gregorian format
/// Side-by-side layout for modern phones, stacked for smaller screens
/// Tappable widget that navigates to calendar screen
class TodayDateWidget extends ConsumerWidget {
  const TodayDateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final bengaliCalendarService = ref.watch(bengaliCalendarServiceProvider);
    final bengaliDate = bengaliCalendarService.getBengaliDate(now);

    return HomeSectionWidget(
      padding: const EdgeInsets.all(16),
      onTap: () {
        context.go(RouteNames.calendar);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Side-by-side for modern phones (>= 320px width)
          // Stacked layout for very small screens
          final useSideBySide = constraints.maxWidth >= 320;

          if (useSideBySide) {
            return Row(
              children: [
                Expanded(
                  child: _BengaliDateCard(
                    bengaliDate: bengaliDate,
                    gregorianDate: now,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GregorianDateCard(
                    gregorianDate: now,
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                _BengaliDateCard(
                  bengaliDate: bengaliDate,
                  gregorianDate: now,
                ),
                const SizedBox(height: 12),
                _GregorianDateCard(
                  gregorianDate: now,
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

// ============================================================================
// BENGALI DATE CARD
// ============================================================================

class _BengaliDateCard extends StatelessWidget {
  final BengaliDate bengaliDate;
  final DateTime gregorianDate;

  const _BengaliDateCard({
    required this.bengaliDate,
    required this.gregorianDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.languageCode == 'bn';

    final dayLabel = l10n.getDayName(gregorianDate.weekday);
    final dayNum = isBn ? bengaliDate.dayBn : bengaliDate.day.toString();
    final monthLabel = isBn ? bengaliDate.monthNameBn : bengaliDate.monthName;
    final yearLabel = isBn ? bengaliDate.yearBn : bengaliDate.year.toString();
    final seasonLabel = l10n.getBengaliSeasonName(bengaliDate.monthNumber);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dayLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimaryContainer,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dayNum,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            monthLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            yearLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              seasonLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// GREGORIAN DATE CARD
// ============================================================================

class _GregorianDateCard extends StatelessWidget {
  final DateTime gregorianDate;

  const _GregorianDateCard({
    required this.gregorianDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.secondaryContainer,
            colorScheme.secondaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.getDayName(gregorianDate.weekday),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSecondaryContainer,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.localizeNumber(gregorianDate.day),
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSecondaryContainer,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.getMonthName(gregorianDate.month),
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            l10n.localizeNumber(gregorianDate.year),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSecondaryContainer.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.getGregorianSeasonName(gregorianDate.month),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}