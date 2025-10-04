import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/calendar/models/calendar_day.dart';

/// Individual calendar day cell widget
/// Displays Gregorian and Bengali dates with decorators
/// Shows indicators for holidays, events, and reminders
class CalendarDayCell extends StatelessWidget {
  final CalendarDay day;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _getBackgroundColor(theme),
          border: _getBorder(theme),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gregorian date (larger)
            Text(
              day.gregorianDay.toString(),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: day.isToday ? FontWeight.bold : FontWeight.w500,
                color: _getTextColor(theme),
                fontSize: day.isToday ? 18 : 16,
              ),
            ),

            const SizedBox(height: 2),

            // Bengali date (smaller, green)
            Opacity(
              opacity: day.opacity,
              child: Text(
                day.bengaliDay.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green.shade700,
                  fontSize: 11,
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Indicators (dots)
            if (day.hasAnyItem) _buildIndicators(theme),
          ],
        ),
      ),
    );
  }

  /// Get background color based on priority
  /// Priority: Today > Selected > Holiday > Default
  Color _getBackgroundColor(ThemeData theme) {
    if (day.isToday) {
      return theme.colorScheme.primaryContainer.withOpacity(0.3);
    }
    if (day.isSelected) {
      return theme.colorScheme.primary.withOpacity(0.2);
    }
    if (day.hasHoliday) {
      return Colors.red.withOpacity(0.1);
    }
    return Colors.transparent;
  }

  /// Get border based on events/reminders
  /// Priority: Both > Events > Reminders > None
  BoxBorder? _getBorder(ThemeData theme) {
    if (day.hasEvent && day.hasReminder) {
      // Both: solid border takes priority
      return Border.all(
        color: Colors.blue,
        width: 2,
      );
    }
    if (day.hasEvent) {
      return Border.all(
        color: Colors.blue,
        width: 2,
      );
    }
    if (day.hasReminder) {
      return Border.all(
        color: Colors.orange,
        width: 2,
        style: BorderStyle
            .solid, // Note: Flutter doesn't support dashed in Border.all
      );
    }
    return null;
  }

  /// Get text color based on state
  Color _getTextColor(ThemeData theme) {
    if (!day.isCurrentMonth) {
      return theme.colorScheme.onSurface.withOpacity(0.4);
    }
    if (day.isSelected) {
      return theme.colorScheme.primary;
    }
    return theme.colorScheme.onSurface;
  }

  /// Build indicator dots at the bottom of the cell
  Widget _buildIndicators(ThemeData theme) {
    final indicators = <Widget>[];

    // Add holiday indicator (red)
    if (day.hasHoliday) {
      indicators.add(_buildDot(Colors.red));
    }

    // Add event indicator (blue)
    if (day.hasEvent) {
      indicators.add(_buildDot(Colors.blue));
    }

    // Add reminder indicator (orange)
    if (day.hasReminder) {
      indicators.add(_buildDot(Colors.orange));
    }

    // Show max 3 dots or "3+" text
    if (day.totalIndicators > 3) {
      return Text(
        '3+',
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: indicators.take(3).toList(),
    );
  }

  /// Build a single indicator dot
  Widget _buildDot(Color color) {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
