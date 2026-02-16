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
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous month button
          Material(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            child: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPreviousMonth,
              tooltip: l10n.previous,
              color: colorScheme.primary,
            ),
          ),

          // Month and year display
          Expanded(
            child: Column(
              children: [
                // Gregorian Month & Year
                InkWell(
                  onTap: onMonthTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
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
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Year
                        InkWell(
                          onTap: onYearTap,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              l10n.localizeNumber(gregorianYear),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (bengaliMonthsDisplay.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  // Bengali month(s)
                  Text(
                    bengaliMonthsDisplay,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Next month button
          Material(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            child: IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onNextMonth,
              tooltip: l10n.next,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
