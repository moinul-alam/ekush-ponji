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
  static const double gregorianTodayFontSize = 20;
  static const double gregorianSelectedFontSize = 18;
  static const double subDateFontSize = 14;

  // ─── Special Day Colors ─────────────────────────────────
// Change these two to try different holiday/weekend color schemes.
  static const Color _specialBgLight = Color(0xFFB83232); // warm crimson
  static const Color _specialBgDark = Color(0xFF8B2020); // deep crimson
  static const Color _specialTextColor = Colors.white;
  static const double _specialTextOpacity = 0.90;

  // ─── Color Slots ───────────────────────────────────────
  static const _BengaliColorSlot bengaliColorSlot = _BengaliColorSlot.primary;
  static const _HijriColorSlot hijriColorSlot =
      _HijriColorSlot.onSurfaceVariant;

  // // Holiday background: fixed clean colors — no opacity mixing with surface
  // static const Color _holidayBgLight = Color(0xFFFFF5F5); // barely-there blush
  // static const Color _holidayBgDark = Color(0xFF251A1A); // very dark warm

  static const Color gregorianSpecialColor = Color(0xFFCC0000);
  static const double cellBorderRadius = 4;
  static const double todayGlowOpacity1 = 0.55;
  static const double todayGlowOpacity2 = 0.30;

  bool get _isWeekend =>
      day.gregorianDate.weekday == DateTime.friday ||
      day.gregorianDate.weekday == DateTime.saturday;

  bool get _isSpecial => day.isCurrentMonth && (_isWeekend || day.hasHoliday);

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
      final selectionColor =
          _isSpecial ? const Color(0xFFFFD600) : theme.colorScheme.primary;
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: selectionColor, width: 2),
          color: selectionColor.withOpacity(0.15),
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

    if (_isSpecial) {
      return BoxDecoration(
        color: isDark ? _specialBgDark : _specialBgLight,
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
          ? const Color.fromARGB(255, 138, 3, 3).withOpacity(0.4)
          : theme.colorScheme.onSurface.withOpacity(0.3);
    }

    if (_isSpecial) return _specialTextColor;
    return theme.colorScheme.onSurface;
  }

  Color _bengaliTextColor(ThemeData theme) {
    final base = _resolveBengaliColor(theme);
    if (!day.isCurrentMonth) return base.withOpacity(0.3);
    if (_isSpecial) return _specialTextColor.withOpacity(_specialTextOpacity);
    if (day.isSelected) return base.withOpacity(0.9);
    if (_isSpecial) return base.withOpacity(0.7);
    return base;
  }

  Color _hijriTextColor(ThemeData theme) {
    final ext = theme.extension<AppThemeExtension>();
    if (!day.isCurrentMonth)
      return (ext?.hijriColor ?? theme.colorScheme.onSurfaceVariant)
          .withOpacity(0.3);
    if (day.isToday) return theme.colorScheme.onPrimary.withOpacity(0.75);
    if (_isSpecial)
      return ext?.hijriColorOnSpecial ??
          _specialTextColor.withOpacity(_specialTextOpacity);
    if (day.isSelected)
      return (ext?.hijriColor ?? theme.colorScheme.onSurfaceVariant)
          .withOpacity(0.9);
    return ext?.hijriColor ?? theme.colorScheme.onSurfaceVariant;
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

enum _HijriColorSlot { onSurfaceVariant }
