// lib/features/calendar/widgets/calendar_day_cell.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/calendar/models/calendar_day.dart';
import 'package:ekush_ponji/features/calendar/models/hijri_date.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';

class CalendarDayCell extends StatelessWidget {
  final CalendarDay day;
  final HijriDate hijriDate;
  final bool showBengaliDate;
  final bool showHijriDate;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.hijriDate,
    required this.showBengaliDate,
    required this.showHijriDate,
    required this.onTap,
  });

  Color _holidayAccentColor(HolidayCategory category) {
    switch (category) {
      case HolidayCategory.national:
        return const Color(0xFF1565C0); // deep blue
      case HolidayCategory.islamic:
        return const Color(0xFF2E7D32); // green
      case HolidayCategory.hindu:
        return const Color(0xFFE65100); // deep orange
      case HolidayCategory.christian:
        return const Color(0xFF6A1B9A); // purple
      case HolidayCategory.buddhist:
        return const Color(0xFFF9A825); // amber
      case HolidayCategory.ethnicMinority:
        return const Color(0xFF00838F); // teal
      case HolidayCategory.cultural:
        return const Color(0xFFC62828); // deep red
    }
  }

  // ─── Font Sizes ────────────────────────────────────────
  static const double gregorianFontSize = 18;
  static const double gregorianTodayFontSize = 20;
  static const double gregorianSelectedFontSize = 18;
  static const double subDateFontSize = 14;

  // ─── Color Slots ───────────────────────────────────────
  static const _BengaliColorSlot bengaliColorSlot = _BengaliColorSlot.primary;
  static const _HijriColorSlot hijriColorSlot = _HijriColorSlot.tertiary;

  // Holiday background: fixed clean colors — no opacity mixing with surface
  static const Color _holidayBgLight = Color(0xFFFFF5F5); // barely-there blush
  static const Color _holidayBgDark = Color(0xFF251A1A); // very dark warm

  static const Color gregorianSpecialColor = Color(0xFFCC0000);
  static const double cellBorderRadius = 4;
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
    final isBn = l10n.languageCode == 'bn';

    final gregorianText = l10n.localizeNumber(day.gregorianDay);
    final bengaliText =
        isBn ? day.bengaliDate.dayBn : day.bengaliDay.toString();
    final hijriText = hijriDate.dayForLocale(l10n.languageCode);

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
              // ── Holiday left accent bar ─────────────────
              if (day.hasHoliday && !day.isToday && !day.isSelected)
                Positioned(
                  left: 0,
                  top: 4,
                  bottom: 4,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: _holidayAccentColor(day.firstHoliday!.category)
                          .withOpacity(0.85),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

              // ── Main content ────────────────────────────
              _buildContent(theme, gregorianText, bengaliText, hijriText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    ThemeData theme,
    String gregorianText,
    String bengaliText,
    String hijriText,
  ) {
    Widget? subDatesWidget;

    if (showBengaliDate && showHijriDate) {
      subDatesWidget = Padding(
        padding: const EdgeInsets.fromLTRB(3, 0, 3, 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              bengaliText,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: subDateFontSize,
                color: _bengaliTextColor(theme),
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            Text(
              hijriText,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: subDateFontSize,
                color: _hijriTextColor(theme),
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ],
        ),
      );
    } else if (showBengaliDate) {
      subDatesWidget = Padding(
        padding: const EdgeInsets.fromLTRB(3, 0, 3, 3),
        child: Center(
          child: Text(
            bengaliText,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: subDateFontSize,
              color: _bengaliTextColor(theme),
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      );
    } else if (showHijriDate) {
      subDatesWidget = Padding(
        padding: const EdgeInsets.fromLTRB(3, 0, 3, 3),
        child: Center(
          child: Text(
            hijriText,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: subDateFontSize,
              color: _hijriTextColor(theme),
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: _buildGregorianDate(theme, gregorianText),
          ),
        ),
        if (subDatesWidget != null) subDatesWidget,
        // Holiday dot removed — accent bar + background is sufficient.
        // Only event and reminder dots remain.
        _buildIndicators(theme),
      ],
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
          border: Border.all(color: theme.colorScheme.primary, width: 2),
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
  // Holiday dot removed — accent bar + tinted background signals holidays.
  // Only event (blue) and reminder (orange) dots remain.
  Widget _buildIndicators(ThemeData theme) {
    if (!day.hasEvent && !day.hasReminder) return const SizedBox(height: 5);

    final dots = <Widget>[];
    if (day.hasEvent) dots.add(_dot(Colors.blue.shade400));
    if (day.hasReminder) dots.add(_dot(Colors.orange.shade400));

    return SizedBox(
      height: 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: dots
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
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 2),
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
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withOpacity(0.25)
            : Colors.black.withOpacity(0.07),
        offset: const Offset(1, 1),
        blurRadius: 2,
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
          ),
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(todayGlowOpacity2),
            blurRadius: 16,
            spreadRadius: 2,
          ),
          ...tileShadows,
        ],
      );
    }

    if (day.hasHoliday) {
      return BoxDecoration(
        // Fixed solid color — no opacity blending with surface, always clean
        color: isDark ? _holidayBgDark : _holidayBgLight,
        borderRadius: BorderRadius.circular(cellBorderRadius),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.25),
          width: 0.5,
        ),
        boxShadow: tileShadows,
      );
    }

    if (_isWeekend) {
      return BoxDecoration(
        color: isDark ? _holidayBgDark : _holidayBgLight,
        borderRadius: BorderRadius.circular(cellBorderRadius),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.25),
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
    // Actual holidays: deep red to signal significance
    if (day.hasHoliday) return gregorianSpecialColor;
    // Weekends only: softer red — background tint is enough, text stays readable
    if (_isWeekend) return gregorianSpecialColor.withOpacity(0.65);
    return theme.colorScheme.onSurface;
  }

  Color _bengaliTextColor(ThemeData theme) {
    final base = _resolveBengaliColor(theme);
    if (!day.isCurrentMonth) return base.withOpacity(0.3);
    if (day.isToday) return theme.colorScheme.onPrimary.withOpacity(0.75);
    if (day.isSelected) return base.withOpacity(0.9);
    if (_isSpecial) return base.withOpacity(0.7);
    return base;
  }

  Color _hijriTextColor(ThemeData theme) {
    final base = _resolveHijriColor(theme);
    if (!day.isCurrentMonth) return base.withOpacity(0.3);
    if (day.isToday) return theme.colorScheme.onPrimary.withOpacity(0.75);
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

  Color _resolveHijriColor(ThemeData theme) {
    switch (hijriColorSlot) {
      case _HijriColorSlot.tertiary:
        return theme.colorScheme.tertiary;
      case _HijriColorSlot.secondary:
        return theme.colorScheme.secondary;
      case _HijriColorSlot.onSurfaceVariant:
        return theme.colorScheme.onSurfaceVariant;
    }
  }
}

// ─── Color Slot Enums ─────────────────────────────────────────
enum _BengaliColorSlot { primary, secondary, tertiary, onSurface }

enum _HijriColorSlot { tertiary, secondary, onSurfaceVariant }
