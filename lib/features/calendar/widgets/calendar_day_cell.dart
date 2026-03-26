// lib/features/calendar/widgets/calendar_day_cell.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/calendar/models/calendar_day.dart';
import 'package:ekush_ponji/features/calendar/models/hijri_date.dart';
import 'package:ekush_ponji/core/themes/app_theme_extensions.dart';

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

  // ─── Font Sizes ────────────────────────────────────────
  static const double gregorianFontSize = 18;
  static const double gregorianTodayFontSize = 19;
  static const double gregorianSelectedFontSize = 18;
  static const double subDateFontSize = 11;

  // ─── Holiday colors (solid fill, white text) ───────────
  // Holidays always win over weekends visually
  static const Color _holidayBgLight = Color(0xFFB83232);
  static const Color _holidayBgDark = Color(0xFF8B2020);
  static const Color _holidayTextColor = Colors.white;

  // ─── Weekend-only colors (soft tint, red text) ─────────
  // Only applied when Fri/Sat has no mandatory holiday
  static const Color _weekendBgLight = Color(0xFFFFDDDD);
  static const Color _weekendBgDark = Color(0xFF2A1515);
  static const Color _weekendTextLight = Color(0xFFB83232);
  static const Color _weekendTextDark = Color(0xFFE57373);

  // Sub-date opacities
  static const double _subDateNormalOpacity = 0.80;
  static const double _subDateHolidayOpacity = 0.75;
  static const double _subDateWeekendOpacity = 0.65;

  static const _BengaliColorSlot bengaliColorSlot = _BengaliColorSlot.primary;

  static const double cellBorderRadius = 4;
  static const double todayGlowOpacity1 = 0.55;
  static const double todayGlowOpacity2 = 0.30;

  // ─── Day type helpers ───────────────────────────────────
  bool get _isWeekend =>
      day.gregorianDate.weekday == DateTime.friday ||
      day.gregorianDate.weekday == DateTime.saturday;

  bool get _isHoliday => day.isCurrentMonth && day.hasHoliday;

  bool get _isWeekendOnly =>
      day.isCurrentMonth && _isWeekend && !day.hasHoliday;

  bool get _isSpecial => _isHoliday || _isWeekendOnly;

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
          child: _buildContent(theme, gregorianText, bengaliText, hijriText),
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
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              bengaliText,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: subDateFontSize,
                color: _bengaliTextColor(theme),
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
            Text(
              hijriText,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: subDateFontSize,
                color: _hijriTextColor(theme),
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ],
        ),
      );
    } else if (showBengaliDate) {
      subDatesWidget = Padding(
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
        child: Center(
          child: Text(
            bengaliText,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: subDateFontSize,
              color: _bengaliTextColor(theme),
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
      );
    } else if (showHijriDate) {
      subDatesWidget = Padding(
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
        child: Center(
          child: Text(
            hijriText,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: subDateFontSize,
              color: _hijriTextColor(theme),
              fontWeight: FontWeight.w600,
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
        _buildIndicators(theme),
      ],
    );
  }

  // ─── Gregorian Date ────────────────────────────────────
  Widget _buildGregorianDate(ThemeData theme, String text) {
    if (day.isToday) {
      return SizedBox(
        width: 30,
        height: 30,
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
      final Color selectionColor;
      if (_isHoliday) {
        selectionColor = const Color(0xFFFFD600); // yellow ring on red
      } else if (_isWeekendOnly) {
        selectionColor = _weekendTextLight; // red ring on tint
      } else {
        selectionColor = theme.colorScheme.primary;
      }

      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: selectionColor, width: 2),
          color: selectionColor.withValues(alpha: 0.15),
        ),
        child: Center(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: selectionColor,
              fontSize: gregorianSelectedFontSize,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 26,
      height: 26,
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

  // ─── Indicators ────────────────────────────────────────
  Widget _buildIndicators(ThemeData theme) {
    if (!day.hasEvent && !day.hasReminder) return const SizedBox(height: 4);

    final dots = <Widget>[];
    if (day.hasEvent) dots.add(_dot(Colors.blue.shade400));
    if (day.hasReminder) dots.add(_dot(Colors.orange.shade400));

    return SizedBox(
      height: 4,
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
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 2),
        ],
      ),
    );
  }

  // ─── Decoration ────────────────────────────────────────
  BoxDecoration _buildDecoration(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    final tileShadows = [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.4)
            : Colors.black.withValues(alpha: 0.12),
        offset: const Offset(2, 2),
        blurRadius: 0,
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.25)
            : Colors.black.withValues(alpha: 0.07),
        offset: const Offset(1, 1),
        blurRadius: 2,
      ),
    ];

    // Today — primary green, always highest priority
    if (day.isToday) {
      return BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(cellBorderRadius),
        boxShadow: [
          BoxShadow(
            color:
                theme.colorScheme.primary.withValues(alpha: todayGlowOpacity1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          BoxShadow(
            color:
                theme.colorScheme.primary.withValues(alpha: todayGlowOpacity2),
            blurRadius: 16,
            spreadRadius: 2,
          ),
          ...tileShadows,
        ],
      );
    }

    // Holiday — solid red fill
    if (_isHoliday) {
      return BoxDecoration(
        color: isDark ? _holidayBgDark : _holidayBgLight,
        borderRadius: BorderRadius.circular(cellBorderRadius),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
          width: 0.5,
        ),
        boxShadow: tileShadows,
      );
    }

    // Weekend-only — barely-there blush tint
    if (_isWeekendOnly) {
      return BoxDecoration(
        color: isDark ? _weekendBgDark : _weekendBgLight,
        borderRadius: BorderRadius.circular(cellBorderRadius),
        border: Border.all(
          color: isDark
              ? _weekendTextDark.withValues(alpha: 0.15)
              : _weekendTextLight.withValues(alpha: 0.20),
          width: 0.5,
        ),
        boxShadow: tileShadows,
      );
    }

    // Normal day
    return BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(cellBorderRadius),
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        width: 0.5,
      ),
      boxShadow: tileShadows,
    );
  }

  // ─── Text Colors ───────────────────────────────────────
  Color _gregorianTextColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    if (!day.isCurrentMonth) {
      if (_isWeekend) {
        return (isDark ? _weekendTextDark : _weekendTextLight)
            .withValues(alpha: 0.35);
      }
      return theme.colorScheme.onSurface.withValues(alpha: 0.3);
    }

    if (_isHoliday) return _holidayTextColor;
    if (_isWeekendOnly) return isDark ? _weekendTextDark : _weekendTextLight;
    return theme.colorScheme.onSurface;
  }

  Color _bengaliTextColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final base = _resolveBengaliColor(theme);
    if (!day.isCurrentMonth) return base.withValues(alpha: 0.3);
    if (day.isToday) return theme.colorScheme.onPrimary.withValues(alpha: 0.80);
    if (_isHoliday)
      return _holidayTextColor.withValues(alpha: _subDateHolidayOpacity);
    if (_isWeekendOnly) {
      return (isDark ? _weekendTextDark : _weekendTextLight)
          .withValues(alpha: _subDateWeekendOpacity);
    }
    if (day.isSelected) return base.withValues(alpha: 0.9);
    return base.withValues(alpha: _subDateNormalOpacity);
  }

  Color _hijriTextColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final ext = theme.extension<AppThemeExtension>();
    final base = ext?.hijriColor ?? theme.colorScheme.onSurfaceVariant;
    if (!day.isCurrentMonth) return base.withValues(alpha: 0.3);
    if (day.isToday) return theme.colorScheme.onPrimary.withValues(alpha: 0.75);
    if (_isHoliday) {
      return ext?.hijriColorOnSpecial ??
          _holidayTextColor.withValues(alpha: _subDateHolidayOpacity);
    }
    if (_isWeekendOnly) {
      return (isDark ? _weekendTextDark : _weekendTextLight)
          .withValues(alpha: _subDateWeekendOpacity);
    }
    if (day.isSelected) return base.withValues(alpha: 0.9);
    return base.withValues(alpha: _subDateNormalOpacity);
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

// ─── Color Slot Enums ─────────────────────────────────────────
enum _BengaliColorSlot { primary, secondary, tertiary, onSurface }
