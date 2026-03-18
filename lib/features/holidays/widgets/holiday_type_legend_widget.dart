// lib/features/holidays/widgets/holiday_type_legend_widget.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

/// Pinned bottom panel explaining the 3 official gazette holiday types
/// as defined by Bangladesh Ministry of Public Administration.
class HolidayTypeLegendWidget extends StatefulWidget {
  const HolidayTypeLegendWidget({super.key});

  @override
  State<HolidayTypeLegendWidget> createState() =>
      _HolidayTypeLegendWidgetState();
}

class _HolidayTypeLegendWidgetState extends State<HolidayTypeLegendWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.languageCode == 'bn';

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header tap row ──────────────────────────────────
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isBn ? 'ছুটির ধরন সম্পর্কে জানুন' : 'About Holiday Types',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded content ─────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  _LegendCard(
                    color: const Color(0xFF2E7D32),
                    icon: Icons.flag_rounded,
                    title: isBn ? 'সাধারণ ছুটি' : 'General Holiday',
                    body: isBn
                        ? 'সরকারি গেজেটে প্রকাশিত এবং সবার জন্য বাধ্যতামূলক। সরকারি ও বেসরকারি সকল প্রতিষ্ঠানে প্রযোজ্য। জাতীয় দিবস, ঈদ, পূজার মূল দিন এই ধরনের ছুটি।'
                        : 'Declared in the government gazette and mandatory for everyone — both public and private institutions. Covers national days, main Eid days, major religious festivals.',
                  ),
                  const SizedBox(height: 8),
                  _LegendCard(
                    color: const Color(0xFF1565C0),
                    icon: Icons.account_balance_rounded,
                    title: isBn
                        ? 'নির্বাহী আদেশে ছুটি'
                        : 'Executive Order Holiday',
                    body: isBn
                        ? 'সরকার বিশেষ নির্বাহী আদেশে ঘোষণা করে। মূলত সরকারি, আধা-সরকারি ও স্বায়ত্তশাসিত প্রতিষ্ঠানের জন্য প্রযোজ্য। বেসরকারি প্রতিষ্ঠানে বাধ্যতামূলক নয়। সাধারণত ঈদের আগে-পরের অতিরিক্ত দিনগুলো এই ছুটি।'
                        : 'Announced by the government through a special executive order. Applies mainly to government, semi-government and autonomous bodies — not mandatory for private employers. Typically used for extra days around Eid.',
                  ),
                  const SizedBox(height: 8),
                  _LegendCard(
                    color: const Color(0xFF6A1B9A),
                    icon: Icons.event_available_rounded,
                    title: isBn ? 'ঐচ্ছিক ছুটি' : 'Optional Holiday',
                    body: isBn
                        ? 'কর্মচারী তার নিজ ধর্ম বা সম্প্রদায়ের উৎসবের জন্য নেয়। বছরে সর্বোচ্চ ৩ দিন। বছরের শুরুতে কর্তৃপক্ষের আগাম অনুমোদন নিতে হয়। সরকার প্রকাশিত তালিকা থেকে ৩টি বেছে নেওয়া যায়।'
                        : 'Taken by an employee to observe their own religious or community festivals. Maximum 3 days per year. Prior approval from the authority is required at the start of the year, choosing from the government-published list.',
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      isBn
                          ? 'সূত্র: জনপ্রশাসন মন্ত্রণালয়, বাংলাদেশ সরকার'
                          : 'Source: Ministry of Public Administration, Government of Bangladesh',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// LEGEND CARD
// ─────────────────────────────────────────────────────────────

class _LegendCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String body;

  const _LegendCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 15, color: color),
                        const SizedBox(width: 6),
                        Text(
                          title,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      body,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.5,
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
}
