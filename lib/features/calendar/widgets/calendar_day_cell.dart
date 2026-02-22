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

  // ─── Font Sizes ────────────────────────────────────────
  static const double gregorianFontSize = 18;
  static const double gregorianTodayFontSize = 20;
  static const double gregorianSelectedFontSize = 18;
  static const double bengaliFontSize = 12;

  // ─── Bengali Date Color Slots (from colorScheme) ───────
  // Change these to any colorScheme slot: primary, secondary,
  // tertiary, onSurface, etc.
  static const _BengaliColorSlot bengaliColorSlot = _BengaliColorSlot.primary;

  // ─── Gregorian Special Color ───────────────────────────
  // Used for weekends and holidays
  static const Color gregorianSpecialColor = Color(0xFFCC0000); // red shade 600 equivalent

  // ─── Cell Border Radius ────────────────────────────────
  static const double cellBorderRadius = 4;

  // ─── Today Glow Opacity ────────────────────────────────
  static const double todayGlowOpacity1 = 0.55;
  static const double todayGlowOpacity2 = 0.30;

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
                      color: gregorianSpecialColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

              // Main content
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top: Gregorian date
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: _buildGregorianDate(theme, gregorianText),
                    ),
                  ),

                  // Bottom: Bengali date centered
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      bengaliText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: bengaliFontSize,
                        color: _bengaliTextColor(theme),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

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
      return SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onPrimary,
              fontSize: gregorianTodayFontSize,
              letterSpacing: -0.5,
            ),
          ),
        ),
      );
    }

    if (day.isSelected) {
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
              fontSize: gregorianSelectedFontSize,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 28,
      height: 28,
      child: Center(
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: _isSpecial ? FontWeight.w700 : FontWeight.w500,
            color: _gregorianTextColor(theme),
            fontSize: gregorianFontSize,
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
    final isDark = theme.brightness == Brightness.dark;

    final tileShadows = [
      BoxShadow(
        color: isDark
            ? Colors.black.withOpacity(0.4)
            : Colors.black.withOpacity(0.12),
        offset: const Offset(2, 2),
        blurRadius: 0,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withOpacity(0.25)
            : Colors.black.withOpacity(0.07),
        offset: const Offset(1, 1),
        blurRadius: 2,
        spreadRadius: 0,
      ),
    ];

    if (day.isToday) {
      return BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(cellBorderRadius),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(todayGlowOpacity1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset.zero,
          ),
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(todayGlowOpacity2),
            blurRadius: 16,
            spreadRadius: 2,
            offset: Offset.zero,
          ),
          ...tileShadows,
        ],
      );
    }

    if (day.hasHoliday) {
      return BoxDecoration(
        color: gregorianSpecialColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(cellBorderRadius),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          width: 0.5,
        ),
        boxShadow: tileShadows,
      );
    }

    if (_isWeekend) {
      return BoxDecoration(
        color: gregorianSpecialColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(cellBorderRadius),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          width: 0.5,
        ),
        boxShadow: tileShadows,
      );
    }

    return BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(cellBorderRadius),
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withOpacity(0.3),
        width: 0.5,
      ),
      boxShadow: tileShadows,
    );
  }

  // ------------------- Colors -------------------
  Color _gregorianTextColor(ThemeData theme) {
    if (!day.isCurrentMonth) {
      return _isSpecial
          ? gregorianSpecialColor.withOpacity(0.4)
          : theme.colorScheme.onSurface.withOpacity(0.3);
    }
    if (_isSpecial) return gregorianSpecialColor;
    return theme.colorScheme.onSurface;
  }

  Color _bengaliTextColor(ThemeData theme) {
    final base = _resolveBengaliColor(theme);
    if (!day.isCurrentMonth) return base.withOpacity(0.3);
    if (day.isToday) return theme.colorScheme.onPrimary.withOpacity(0.85);
    if (day.isSelected) return base.withOpacity(0.9);
    if (_isSpecial) return base.withOpacity(0.7);
    return base;
  }

  Color _resolveBengaliColor(ThemeData theme) {
    switch (bengaliColorSlot) {
      case _BengaliColorSlot.primary:
        return theme.colorScheme.primary;
      case _BengaliColorSlot.secondary:
        return theme.colorScheme.secondary;
      case _BengaliColorSlot.tertiary:
        return theme.colorScheme.tertiary;
      case _BengaliColorSlot.onSurface:
        return theme.colorScheme.onSurface;
    }
  }
}

// ─── Bengali Color Slot Enum ───────────────────────────────
enum _BengaliColorSlot { primary, secondary, tertiary, onSurface }