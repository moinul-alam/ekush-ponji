import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

/// Week days header row widget
/// Shows abbreviated day names: Sun, Mon, Tue, Wed, Thu, Fri, Sat
/// Uses localized day names from AppLocalizations
class WeekDaysRow extends StatelessWidget {
  const WeekDaysRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          _buildDayCell(context, localizations.shortSunday, false),
          _buildDayCell(context, localizations.shortMonday, false),
          _buildDayCell(context, localizations.shortTuesday, false),
          _buildDayCell(context, localizations.shortWednesday, false),
          _buildDayCell(context, localizations.shortThursday, false),
          _buildDayCell(context, localizations.shortFriday, true),
          _buildDayCell(context, localizations.shortSaturday, true),
        ],
      ),
    );
  }

  /// Build a single day cell. [isWeekend] true for Fri/Sat (govt holidays) — shown in red.
  Widget _buildDayCell(BuildContext context, String dayName, bool isWeekend) {
    final theme = Theme.of(context);

    return Expanded(
      child: Center(
        child: Text(
          dayName,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isWeekend ? Colors.red.shade700 : theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
