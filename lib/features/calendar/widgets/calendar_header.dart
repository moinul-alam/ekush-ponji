// lib/features/calendar/widgets/calendar_header.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/themes/app_theme_extensions.dart';

class CalendarHeader extends StatelessWidget {
  final int gregorianYear;
  final int gregorianMonth;
  final String bengaliMonthsDisplay;
  final String hijriMonthsDisplay; // ← NEW
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onMonthTap;
  final VoidCallback onYearTap;

  const CalendarHeader({
    super.key,
    required this.gregorianYear,
    required this.gregorianMonth,
    required this.bengaliMonthsDisplay,
    required this.hijriMonthsDisplay, // ← NEW
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

          // Centre: Gregorian + Bengali + Hijri
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Gregorian month + year ─────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onMonthTap,
                      child: Text(
                        l10n.getMonthName(gregorianMonth),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onYearTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        child: Text(
                          l10n.localizeNumber(gregorianYear),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Bengali (left) | divider | Hijri (right) ──
                if (bengaliMonthsDisplay.isNotEmpty ||
                    hijriMonthsDisplay.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (bengaliMonthsDisplay.isNotEmpty)
                        Flexible(
                          child: Text(
                            bengaliMonthsDisplay,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (bengaliMonthsDisplay.isNotEmpty &&
                          hijriMonthsDisplay.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 14,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.0),
                                theme.colorScheme.outlineVariant,
                                theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (hijriMonthsDisplay.isNotEmpty)
                        Flexible(
                          child: Text(
                            hijriMonthsDisplay,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              color: Theme.of(context)
                                      .extension<AppThemeExtension>()
                                      ?.hijriColor ??
                                  theme.colorScheme.tertiary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
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

// ─── Navigation button ────────────────────────────────────────
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
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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
