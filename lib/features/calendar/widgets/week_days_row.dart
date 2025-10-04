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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildDayCell(context, _getDayAbbreviation(localizations.sunday)),
          _buildDayCell(context, _getDayAbbreviation(localizations.monday)),
          _buildDayCell(context, _getDayAbbreviation(localizations.tuesday)),
          _buildDayCell(context, _getDayAbbreviation(localizations.wednesday)),
          _buildDayCell(context, _getDayAbbreviation(localizations.thursday)),
          _buildDayCell(context, _getDayAbbreviation(localizations.friday)),
          _buildDayCell(context, _getDayAbbreviation(localizations.saturday)),
        ],
      ),
    );
  }

  /// Build a single day cell
  Widget _buildDayCell(BuildContext context, String dayName) {
    final theme = Theme.of(context);

    return Expanded(
      child: Center(
        child: Text(
          dayName,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  /// Get abbreviated day name (first 3 characters)
  String _getDayAbbreviation(String fullName) {
    if (fullName.length <= 3) return fullName;
    return fullName.substring(0, 3);
  }
}
