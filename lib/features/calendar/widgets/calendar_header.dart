import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onTap: onPreviousMonth,
            tooltip: l10n.previous,
          ),

          // Month + Year + Bengali month
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gregorian month and year
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Month - tappable
                    GestureDetector(
                      onTap: onMonthTap,
                      child: Text(
                        l10n.getMonthName(gregorianMonth),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Year - tappable
                    GestureDetector(
                      onTap: onYearTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          l10n.localizeNumber(gregorianYear),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Bengali month
                if (bengaliMonthsDisplay.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    bengaliMonthsDisplay,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Next button
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onTap: onNextMonth,
            tooltip: l10n.next,
          ),
        ],
      ),
    );
  }
}

// Navigation button widget
class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onSurface,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}