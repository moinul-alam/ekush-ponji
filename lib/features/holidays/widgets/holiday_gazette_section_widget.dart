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

    // Consistent with HolidayCard accent colors
    final accentColor =
        isMandatory ? const Color(0xFF2E7D32) : theme.colorScheme.outline;

    // Total calendar days covered
    final totalDays = widget.holidays.fold(0, (sum, h) => sum + h.durationDays);
    final totalDaysLabel = isBn
        ? '(মোট ${l10n.localizeNumber(totalDays)} দিন)'
        : '(Total $totalDays days)';

    // Whether any holiday in this section is moon-dependent
    final hasApproximate = widget.holidays.any((h) => h.isApproximate);

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
              color: accentColor.withValues(alpha: isMandatory ? 0.08 : 0.05),
              border: Border(
                left: BorderSide(
                  color: accentColor,
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
                  color: accentColor,
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
                            color: accentColor,
                          ),
                        ),
                        TextSpan(
                          text: totalDaysLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: accentColor.withValues(alpha: 0.7),
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
                    color: accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.localizeNumber(count),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
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
              // Gazette-type view: no gazette chip needed
              ...widget.holidays.map(
                (holiday) => HolidayCard(
                  holiday: holiday,
                  showGazetteChip: false,
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
