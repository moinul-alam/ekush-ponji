// lib/features/calendar/widgets/week_days_row.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

class WeekDaysRow extends StatelessWidget {
  const WeekDaysRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _dayLabel(context, l10n.shortSunday, false),
          _dayLabel(context, l10n.shortMonday, false),
          _dayLabel(context, l10n.shortTuesday, false),
          _dayLabel(context, l10n.shortWednesday, false),
          _dayLabel(context, l10n.shortThursday, false),
          _dayLabel(context, l10n.shortFriday, true),
          _dayLabel(context, l10n.shortSaturday, true),
        ],
      ),
    );
  }

  Widget _dayLabel(BuildContext context, String label, bool isWeekend) {
    final theme = Theme.of(context);
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15, // ← reduced from 18
            color: isWeekend
                ? const Color(0xFFB83232)
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
