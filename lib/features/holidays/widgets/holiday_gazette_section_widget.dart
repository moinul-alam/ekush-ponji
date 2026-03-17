// lib/features/holidays/widgets/holiday_gazette_section_widget.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/features/holidays/widgets/holiday_card.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

class HolidayGazetteSectionWidget extends StatefulWidget {
  final GazetteType gazetteType;
  final List<Holiday> holidays;

  const HolidayGazetteSectionWidget({
    super.key,
    required this.gazetteType,
    required this.holidays,
  });

  @override
  State<HolidayGazetteSectionWidget> createState() =>
      _HolidayGazetteSectionWidgetState();
}

class _HolidayGazetteSectionWidgetState
    extends State<HolidayGazetteSectionWidget> {
  // Collapsed by default — user taps to expand
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.languageCode == 'bn';

    final sectionTitle = isBn
        ? widget.gazetteType.displayNameBn
        : widget.gazetteType.displayName;

    final isMandatory = widget.gazetteType.isMandatory;
    final count = widget.holidays.length;

    // Total calendar days covered (multi-day holidays count their full span)
    final totalDays = widget.holidays.fold(0, (sum, h) => sum + h.durationDays);
    final totalDaysLabel = isBn
        ? '(মোট ${l10n.localizeNumber(totalDays)} দিন)'
        : '(Total $totalDays days)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ───────────────────────────────────
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isMandatory
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                  : theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
              border: Border(
                left: BorderSide(
                  color: isMandatory
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              children: [
                // Section icon
                Icon(
                  _gazetteIcon(widget.gazetteType),
                  size: 18,
                  color: isMandatory
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary,
                ),
                const SizedBox(width: 10),

                // Section title + total days label
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$sectionTitle  ',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isMandatory
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: totalDaysLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isMandatory
                                ? theme.colorScheme.primary.withOpacity(0.75)
                                : theme.colorScheme.secondary.withOpacity(0.75),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isMandatory
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.localizeNumber(count),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isMandatory
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSecondary,
                      fontWeight: FontWeight.w700,
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

        // ── Holiday Cards ────────────────────────────────────
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Column(
            children: [
              const SizedBox(height: 8),
              ...widget.holidays.map(
                (holiday) => HolidayCard(holiday: holiday),
              ),
              const SizedBox(height: 8),
            ],
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ── Icon per gazette type ──────────────────────────────────

  IconData _gazetteIcon(GazetteType type) {
    switch (type) {
      case GazetteType.mandatoryGeneral:
        return Icons.flag_rounded;
      case GazetteType.mandatoryExecutive:
        return Icons.account_balance_rounded;
      case GazetteType.optionalMuslim:
        return Icons.star_rounded;
      case GazetteType.optionalHindu:
        return Icons.auto_awesome_rounded;
      case GazetteType.optionalChristian:
        return Icons.church_rounded;
      case GazetteType.optionalBuddhist:
        return Icons.self_improvement_rounded;
      case GazetteType.optionalEthnicMinority:
        return Icons.diversity_3_rounded;
    }
  }
}
