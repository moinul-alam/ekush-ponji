import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

/// Calendar legend widget showing symbol meanings
/// Displays icons/colors for: Today, Holiday, Event, Reminder
/// Collapsible to save space
class CalendarLegend extends StatefulWidget {
  const CalendarLegend({super.key});

  @override
  State<CalendarLegend> createState() => _CalendarLegendState();
}

class _CalendarLegendState extends State<CalendarLegend> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.calendarLegend,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Today indicator
                  _buildLegendItem(
                    context,
                    icon: Icons.circle,
                    color: theme.colorScheme.primaryContainer,
                    label: l10n.today,
                    description: 'Light background',
                  ),

                  const SizedBox(height: 8),

                  // Holiday indicator
                  _buildLegendItem(
                    context,
                    icon: Icons.circle,
                    color: Colors.red,
                    label: l10n.calendarHoliday,
                    description: 'Red dot',
                  ),

                  const SizedBox(height: 8),

                  // Event indicator
                  _buildLegendItem(
                    context,
                    icon: Icons.circle,
                    color: Colors.blue,
                    label: l10n.calendarEvent,
                    description: 'Blue dot / border',
                  ),

                  const SizedBox(height: 8),

                  // Reminder indicator
                  _buildLegendItem(
                    context,
                    icon: Icons.circle,
                    color: Colors.orange,
                    label: l10n.calendarReminder,
                    description: 'Orange dot / border',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Build a single legend item
  Widget _buildLegendItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Icon/color indicator
        Icon(
          icon,
          size: 12,
          color: color,
        ),

        const SizedBox(width: 8),

        // Label
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(width: 8),

        // Description
        Expanded(
          child: Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
