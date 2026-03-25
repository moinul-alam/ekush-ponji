// lib/features/holidays/widgets/holiday_month_section_widget.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/features/holidays/widgets/holiday_card.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

class HolidayMonthSectionWidget extends StatefulWidget {
  final int month;
  final int year;
  final List<Holiday> holidays;

  /// Whether this section should be expanded by default.
  /// Current month is expanded by default, others are collapsed.
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  const HolidayMonthSectionWidget({
    super.key,
    required this.month,
    required this.year,
    required this.holidays,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
  });

  @override
  State<HolidayMonthSectionWidget> createState() =>
      _HolidayMonthSectionWidgetState();
}

class _HolidayMonthSectionWidgetState extends State<HolidayMonthSectionWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant HolidayMonthSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyExpanded != widget.initiallyExpanded) {
      _isExpanded = widget.initiallyExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.languageCode == 'bn';

    final monthName = l10n.getMonthName(widget.month);
    final yearStr = l10n.localizeNumber(widget.year);
    final count = widget.holidays.length;

    final now = DateTime.now();
    final isCurrentMonth = widget.month == now.month && widget.year == now.year;

    // Whether any holiday in this month is moon-dependent
    final hasApproximate = widget.holidays.any((h) => h.isApproximate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Month Header ─────────────────────────────────────
        InkWell(
          onTap: () {
            setState(() => _isExpanded = !_isExpanded);
            widget.onExpansionChanged?.call(_isExpanded);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: isCurrentMonth
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                  : theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Current month indicator dot
                if (isCurrentMonth) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Month + year
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: monthName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isCurrentMonth
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: '  $yearStr',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Holiday count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentMonth
                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                        : theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrentMonth
                          ? theme.colorScheme.primary.withValues(alpha: 0.4)
                          : theme.colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${l10n.localizeNumber(count)} ${count == 1 ? l10n.day : l10n.days}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isCurrentMonth
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Expand/collapse chevron
                AnimatedRotation(
                  turns: _isExpanded ? 0 : -0.25,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Holiday Cards + footnote ─────────────────────────
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Month-wise view: show gazette chip on each card
              ...widget.holidays.map(
                (holiday) => HolidayCard(
                  holiday: holiday,
                  showGazetteChip: true,
                ),
              ),
              // * footnote — only if at least one holiday is moon-dependent
              if (hasApproximate) _ApproximateFootnote(isBn: isBn),
              const SizedBox(height: 8),
            ],
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// APPROXIMATE FOOTNOTE
// ─────────────────────────────────────────────────────────────

class _ApproximateFootnote extends StatelessWidget {
  final bool isBn;
  const _ApproximateFootnote({required this.isBn});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '* ',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          Expanded(
            child: Text(
              isBn ? 'চাঁদ দেখার উপর নির্ভরশীল' : 'Subject to moon sighting',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
