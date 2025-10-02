import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/home/widgets/home_section_widget.dart';
import 'package:intl/intl.dart';

/// Displays today's date in both Gregorian and Bangla format
/// Stunning and attractive design to catch user attention
class TodayDateWidget extends StatelessWidget {
  const TodayDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();

    return HomeSectionWidget(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Day of week - Large and prominent
          Text(
            DateFormat('EEEE').format(now),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // Gregorian Date - Main focus
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Day number - Extra large
                Text(
                  DateFormat('dd').format(now),
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                // Month and Year
                Text(
                  DateFormat('MMMM yyyy').format(now),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Bangla Date
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  _getBanglaDate(now),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TODO: Implement proper Bangla calendar conversion
  // This is a placeholder - integrate with a Bangla calendar library
  String _getBanglaDate(DateTime date) {
    // Placeholder Bangla date
    // TODO: Use proper Bangla calendar conversion library
    // Example libraries:
    // - Create custom Bangla calendar converter
    // - Use API for accurate conversion

    final banglaMonths = [
      'বৈশাখ',
      'জ্যৈষ্ঠ',
      'আষাঢ়',
      'শ্রাবণ',
      'ভাদ্র',
      'আশ্বিন',
      'কার্তিক',
      'অগ্রহায়ণ',
      'পৌষ',
      'মাঘ',
      'ফাল্গুন',
      'চৈত্র',
    ];

    final banglaNumerals = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

    // Approximate conversion (this should be replaced with accurate algorithm)
    int banglaMonth = (date.month + 8) % 12;
    int banglaDay = date.day + 15; // Rough approximation
    if (banglaDay > 30) banglaDay -= 30;

    String banglaDayStr = banglaDay.toString().split('').map((digit) {
      return banglaNumerals[int.parse(digit)];
    }).join();

    return '$banglaDayStr ${banglaMonths[banglaMonth]}, ১৪৩২'; // Example year
  }
}
