// lib/features/holidays/widgets/holiday_card.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

class HolidayCard extends StatelessWidget {
  final Holiday holiday;

  /// When true, a gazette-type chip is shown in the chips row.
  /// Pass true from month-wise view; false (default) from gazette-type view.
  final bool showGazetteChip;

  const HolidayCard({
    super.key,
    required this.holiday,
    this.showGazetteChip = false,
  });

  // ── Accent colors ──────────────────────────────────────────

  /// Strong green for mandatory holidays, neutral grey for optional.
  static Color accentColor(bool isMandatory, ThemeData theme) {
    return isMandatory
        ? const Color(0xFF2E7D32) // Material green-800
        : theme.colorScheme.outline; // neutral grey
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.languageCode == 'bn';

    final name = isBn ? holiday.namebn : holiday.name;
    final description = isBn ? holiday.descriptionbn : holiday.description;
    final isMandatory = holiday.isMandatory;
    final accent = accentColor(isMandatory, theme);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent.withValues(alpha: isMandatory ? 0.35 : 0.25),
          width: 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Left accent bar ──────────────────────────────
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),

            // ── Content ──────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Date badge ─────────────────────────
                    _DateBadge(holiday: holiday, l10n: l10n, accent: accent),
                    const SizedBox(width: 12),

                    // ── Holiday info ───────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name row with optional * superscript
                          _NameRow(
                            name: name,
                            isApproximate: holiday.isApproximate,
                            theme: theme,
                          ),

                          // Multi-day range label
                          if (holiday.isMultiDay) ...[
                            const SizedBox(height: 2),
                            Text(
                              _buildDateRangeText(holiday, l10n),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],

                          // Description
                          if (description != null &&
                              description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          const SizedBox(height: 8),

                          // ── Chips row ──────────────────────
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              // Gazette chip — only in month-wise view
                              if (showGazetteChip)
                                _SmallChip(
                                  label: isBn
                                      ? holiday.gazetteType.displayNameBn
                                      : holiday.gazetteType.displayName,
                                  color: accent,
                                ),

                              // Category chip
                              _SmallChip(
                                label: isBn
                                    ? holiday.category.displayNameBn
                                    : holiday.category.displayName,
                                color: _categoryColor(holiday.category, theme),
                              ),

                              // Regional chip
                              if (holiday.isRegional)
                                _SmallChip(
                                  label: isBn
                                      ? (holiday.regionNoteBn ?? 'আঞ্চলিক')
                                      : (holiday.regionNote ?? 'Regional'),
                                  color: theme.colorScheme.tertiary,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  String _buildDateRangeText(Holiday holiday, AppLocalizations l10n) {
    final start = holiday.startDate;
    final end = holiday.endDate!;
    final startStr =
        '${l10n.localizeNumber(start.day)} ${l10n.getMonthAbbreviation(start.month)}';
    final endStr =
        '${l10n.localizeNumber(end.day)} ${l10n.getMonthAbbreviation(end.month)}';
    final days = l10n.localizeNumber(holiday.durationDays);
    final dayWord = holiday.durationDays > 1 ? l10n.days : l10n.day;
    return '$startStr – $endStr ($days $dayWord)';
  }

  Color _categoryColor(HolidayCategory category, ThemeData theme) {
    switch (category) {
      case HolidayCategory.national:
        return theme.colorScheme.primary;
      case HolidayCategory.islamic:
        return const Color(0xFF2E7D32);
      case HolidayCategory.hindu:
        return const Color(0xFFE65100);
      case HolidayCategory.christian:
        return const Color(0xFF1565C0);
      case HolidayCategory.buddhist:
        return const Color(0xFFF9A825);
      case HolidayCategory.ethnicMinority:
        return const Color(0xFF6A1B9A);
      case HolidayCategory.cultural:
        return theme.colorScheme.secondary;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// NAME ROW — title with optional * superscript
// ─────────────────────────────────────────────────────────────

class _NameRow extends StatelessWidget {
  final String name;
  final bool isApproximate;
  final ThemeData theme;

  const _NameRow({
    required this.name,
    required this.isApproximate,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (!isApproximate) {
      return Text(
        name,
        style: theme.textTheme.titleSmall?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      );
    }

    // Name + superscript *
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          WidgetSpan(
            baseline: TextBaseline.alphabetic,
            alignment: PlaceholderAlignment.top,
            child: Text(
              ' *',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DATE BADGE
// ─────────────────────────────────────────────────────────────

class _DateBadge extends StatelessWidget {
  final Holiday holiday;
  final AppLocalizations l10n;
  final Color accent;

  const _DateBadge({
    required this.holiday,
    required this.l10n,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accent.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.localizeNumber(holiday.startDate.day),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          Text(
            l10n.getMonthAbbreviation(holiday.startDate.month),
            style: theme.textTheme.labelSmall?.copyWith(
              color: accent.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SMALL CHIP
// ─────────────────────────────────────────────────────────────

class _SmallChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
