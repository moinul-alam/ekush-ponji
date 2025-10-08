// lib/features/home/widgets/today_date_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/features/home/widgets/home_section_widget.dart';
import 'package:ekush_ponji/core/services/bengali_calendar_service.dart';
import 'package:ekush_ponji/features/calendar/models/bengali_date.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:intl/intl.dart';

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
          // Bengali Day of Week
          Text(
            _getBengaliDayName(gregorianDate.weekday),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimaryContainer,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),

          // Bengali Date (Large)
          Text(
            bengaliDate.dayBn,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),

          // Bengali Month
          Text(
            bengaliDate.monthNameBn,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Bengali Year
          Text(
            bengaliDate.yearBn,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Bengali Season Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getBengaliSeason(bengaliDate.monthNumber),
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

  String _getBengaliDayName(int weekday) {
    const days = [
      'সোমবার',
      'মঙ্গলবার',
      'বুধবার',
      'বৃহস্পতিবার',
      'শুক্রবার',
      'শনিবার',
      'রবিবার',
    ];
    return days[weekday - 1];
  }

  String _getBengaliSeason(int monthNumber) {
    // Bengali seasons: 6 seasons (Ritu)
    if (monthNumber >= 1 && monthNumber <= 2) return 'গ্রীষ্ম'; // Summer
    if (monthNumber >= 3 && monthNumber <= 4) return 'বর্ষা'; // Monsoon
    if (monthNumber >= 5 && monthNumber <= 6) return 'শরৎ'; // Autumn
    if (monthNumber >= 7 && monthNumber <= 8) return 'হেমন্ত'; // Late Autumn
    if (monthNumber >= 9 && monthNumber <= 10) return 'শীত'; // Winter
    return 'বসন্ত'; // Spring
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
          // English Day of Week
          Text(
            DateFormat('EEEE').format(gregorianDate),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSecondaryContainer,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),

          // Date Number (Large)
          Text(
            DateFormat('dd').format(gregorianDate),
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSecondaryContainer,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),

          // Month Name
          Text(
            DateFormat('MMMM').format(gregorianDate),
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Year
          Text(
            DateFormat('yyyy').format(gregorianDate),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSecondaryContainer.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Season Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getEnglishSeason(gregorianDate.month),
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

  String _getEnglishSeason(int month) {
    // Meteorological seasons (Northern Hemisphere)
    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    if (month >= 9 && month <= 11) return 'Autumn';
    return 'Winter';
  }
}