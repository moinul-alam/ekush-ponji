import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/calendar/models/calendar_day.dart';

class CalendarDayCell extends StatelessWidget {
  final CalendarDay day;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.onTap,
  });

  // Bangladesh weekends
  bool get _isWeekend =>
      day.gregorianDate.weekday == DateTime.friday ||
      day.gregorianDate.weekday == DateTime.saturday;

  bool get _isSpecial => _isWeekend || day.hasHoliday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isBengali = l10n.languageCode == 'bn';

    final gregorianText = l10n.localizeNumber(day.gregorianDay);
    final bengaliText =
        isBengali ? day.bengaliDate.dayBn : day.bengaliDay.toString();

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: day.isCurrentMonth ? 1.0 : 0.35,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(2),
          decoration: _buildDecoration(theme),
          child: Stack(
            children: [
              // Holiday left accent bar
              if (day.hasHoliday && !day.isToday && !day.isSelected)
                Positioned(
                  left: 0,
                  top: 4,
                  bottom: 4,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

              // Main content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gregorian date with circle for today/selected
                  _buildGregorianDate(theme, gregorianText),

                  const SizedBox(height: 1),

                  // Bengali date
                  Text(
                    bengaliText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: _bengaliTextColor(theme),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // Indicator dots
                  _buildIndicators(theme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------- Gregorian Date -------------------

  Widget _buildGregorianDate(ThemeData theme, String text) {
    if (day.isToday) {
      // Filled circle - primary color
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    if (day.isSelected) {
      // Outlined circle - primary color
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.primary,
            width: 2,
          ),
          color: theme.colorScheme.primary.withOpacity(0.08),
        ),
        child: Center(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    // Normal date
    return SizedBox(
      width: 28,
      height: 28,
      child: Center(
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight:
                _isSpecial ? FontWeight.w700 : FontWeight.w500,
            color: _gregorianTextColor(theme),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ------------------- Indicators -------------------

  Widget _buildIndicators(ThemeData theme) {
    if (!day.hasAnyItem) return const SizedBox(height: 5);

    final dots = <Widget>[];

    if (day.hasHoliday) dots.add(_dot(Colors.red.shade400));
    if (day.hasEvent) dots.add(_dot(Colors.blue.shade400));
    if (day.hasReminder) dots.add(_dot(Colors.orange.shade400));

    return SizedBox(
      height: 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: dots
            .take(3)
            .map((d) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: d,
                ))
            .toList(),
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }

  // ------------------- Decoration -------------------

  BoxDecoration _buildDecoration(ThemeData theme) {
    // Today and selected have no background box - circle handles it
    if (day.isToday || day.isSelected) {
      return const BoxDecoration(
        color: Colors.transparent,
      );
    }

    if (day.hasHoliday) {
      return BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
      );
    }

    if (_isWeekend) {
      return BoxDecoration(
        color: Colors.red.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
      );
    }

    return const BoxDecoration(color: Colors.transparent);
  }

  // ------------------- Colors -------------------

  Color _gregorianTextColor(ThemeData theme) {
    if (!day.isCurrentMonth) {
      return _isSpecial
          ? Colors.red.withOpacity(0.4)
          : theme.colorScheme.onSurface.withOpacity(0.3);
    }
    if (_isSpecial) return Colors.red.shade600;
    return theme.colorScheme.onSurface;
  }

  Color _bengaliTextColor(ThemeData theme) {
    if (!day.isCurrentMonth) {
      return theme.colorScheme.onSurface.withOpacity(0.25);
    }
    if (day.isToday) return theme.colorScheme.onPrimary.withOpacity(0.85);
    if (day.isSelected) return theme.colorScheme.primary.withOpacity(0.8);
    if (_isSpecial) return Colors.red.shade400;
    return theme.colorScheme.onSurface.withOpacity(0.45);
  }
}