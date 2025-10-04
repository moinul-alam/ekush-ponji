import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

/// Calendar header widget showing month/year with navigation
/// Top row: Gregorian month and year
/// Bottom row: Bengali month(s) and year
/// Includes arrow buttons for month navigation
class CalendarHeader extends StatelessWidget {
  final int gregorianYear;
  final int gregorianMonth;
  final String bengaliMonthsDisplay;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onMonthTap;
  final VoidCallback onYearTap;

  const CalendarHeader({
    super.key,
    required this.gregorianYear,
    required this.gregorianMonth,
    required this.bengaliMonthsDisplay,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onMonthTap,
    required this.onYearTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous month button
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPreviousMonth,
            tooltip: localizations.previous,
          ),

          // Month and year display
          Expanded(
            child: Column(
              children: [
                // Gregorian month and year (larger, primary)
                InkWell(
                  onTap: onMonthTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getMonthName(gregorianMonth, localizations),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: onYearTap,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              gregorianYear.toString(),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Bengali month(s) and year (smaller, green)
                Text(
                  bengaliMonthsDisplay,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Next month button
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNextMonth,
            tooltip: localizations.next,
          ),
        ],
      ),
    );
  }

  /// Get localized month name
  String _getMonthName(int month, AppLocalizations localizations) {
    switch (month) {
      case 1:
        return localizations.january;
      case 2:
        return localizations.february;
      case 3:
        return localizations.march;
      case 4:
        return localizations.april;
      case 5:
        return localizations.may;
      case 6:
        return localizations.june;
      case 7:
        return localizations.july;
      case 8:
        return localizations.august;
      case 9:
        return localizations.september;
      case 10:
        return localizations.october;
      case 11:
        return localizations.november;
      case 12:
        return localizations.december;
      default:
        return '';
    }
  }
}
