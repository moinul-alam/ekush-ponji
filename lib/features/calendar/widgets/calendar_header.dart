// lib/features/calendar/widgets/calendar_header.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

/// Calendar header widget showing month/year with navigation
/// Uses proper localization and theme colors
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
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
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
            tooltip: l10n.previous,
            color: colorScheme.onSurface,
          ),

          // Month and year display
          Expanded(
            child: Column(
              children: [
                // Gregorian Month & Year
                InkWell(
                  onTap: onMonthTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Month name
                        Text(
                          l10n.getMonthName(gregorianMonth),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),

                        // Year
                        InkWell(
                          onTap: onYearTap,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            child: Text(
                              l10n.localizeNumber(gregorianYear),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Bengali month(s) - automatically uses Hind Siliguri
                Text(
                  bengaliMonthsDisplay,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.secondary,
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
            tooltip: l10n.next,
            color: colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}
