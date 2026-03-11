// lib/features/holidays/widgets/holiday_card.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

class HolidayCard extends StatelessWidget {
  final Holiday holiday;

  const HolidayCard({
    super.key,
    required this.holiday,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isbn = l10n.languageCode == 'bn';

    final name = isbn ? holiday.namebn : holiday.name;
    final description = isbn ? holiday.descriptionbn : holiday.description;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Date badge ──────────────────────────────────
            _DateBadge(holiday: holiday, l10n: l10n),
            const SizedBox(width: 12),

            // ── Holiday info ─────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + approximate indicator
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (holiday.isApproximate) ...[
                        const SizedBox(width: 4),
                        Tooltip(
                          message: isbn
                              ? 'চাঁদ দেখার উপর নির্ভরশীল'
                              : 'Subject to moon sighting',
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
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
                  if (description != null && description.isNotEmpty) ...[
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

                  const SizedBox(height: 6),

                  // ── Chips row ──────────────────────────────
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      // Category chip
                      _SmallChip(
                        label: isbn
                            ? holiday.category.displayNameBn
                            : holiday.category.displayName,
                        color: _categoryColor(holiday.category, theme),
                      ),

                      // Regional note chip
                      if (holiday.isRegional) ...[
                        _SmallChip(
                          label: isbn
                              ? (holiday.regionNoteBn ?? 'আঞ্চলিক')
                              : (holiday.regionNote ?? 'Regional'),
                          color: theme.colorScheme.tertiary,
                        ),
                      ],
                    ],
                  ),
                ],
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
        return const Color(0xFF2E7D32); // green
      case HolidayCategory.hindu:
        return const Color(0xFFE65100); // deep orange
      case HolidayCategory.christian:
        return const Color(0xFF1565C0); // blue
      case HolidayCategory.buddhist:
        return const Color(0xFFF9A825); // amber
      case HolidayCategory.ethnicMinority:
        return const Color(0xFF6A1B9A); // purple
      case HolidayCategory.cultural:
        return theme.colorScheme.secondary;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// DATE BADGE
// Shows day number + month abbreviation in a styled box
// ─────────────────────────────────────────────────────────────

class _DateBadge extends StatelessWidget {
  final Holiday holiday;
  final AppLocalizations l10n;

  const _DateBadge({required this.holiday, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMandatory = holiday.isMandatory;

    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isMandatory
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.localizeNumber(holiday.startDate.day),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isMandatory
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSecondaryContainer,
            ),
          ),
          Text(
            l10n.getMonthAbbreviation(holiday.startDate.month),
            style: theme.textTheme.labelSmall?.copyWith(
              color: isMandatory
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSecondaryContainer,
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
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
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
