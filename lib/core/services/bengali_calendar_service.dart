// lib/core/services/bengali_calendar_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/calendar/models/bengali_date.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

/// Converts Gregorian dates to Bengali (Bangla Academy standard).
///
/// Year rule:
///   On/after April 14 → Gregorian year − 593
///   Before April 14   → Gregorian year − 594
class BengaliCalendarService {
  // Bengali month number → [Gregorian month, Gregorian day] it starts on.
  static const Map<int, List<int>> _monthStartDates = {
    1:  [4,  14], // Boishakh
    2:  [5,  15], // Jyoishtho
    3:  [6,  15], // Asharh
    4:  [7,  16], // Srabon
    5:  [8,  16], // Bhadro
    6:  [9,  16], // Ashwin
    7:  [10, 17], // Kartik
    8:  [11, 16], // Ogrohayon
    9:  [12, 16], // Poush
    10: [1,  15], // Magh
    11: [2,  14], // Falgun
    12: [3,  15], // Choitra
  };

  static const List<String> _monthNamesEn = [
    'Boishakh', 'Jyoishtho', 'Asharh',    'Srabon',
    'Bhadro',   'Ashwin',    'Kartik',     'Ogrohayon',
    'Poush',    'Magh',      'Falgun',     'Choitra',
  ];

  BengaliDate getBengaliDate(DateTime gDate, {AppLocalizations? localizations}) {
    final bMonth = _findBengaliMonth(gDate.month, gDate.day);
    return BengaliDate(
      day: _bengaliDayOfMonth(gDate.year, gDate.month, gDate.day, bMonth),
      monthName: localizations?.getBanglaMonthName(bMonth) ?? _monthNamesEn[bMonth - 1],
      year: _bengaliYear(gDate.year, gDate.month, gDate.day),
      monthNumber: bMonth,
    );
  }

  /// Returns the 1–2 Bengali months that overlap a given Gregorian month.
  List<BengaliMonth> getBengaliMonthsForGregorianMonth(
    int year,
    int month, {
    AppLocalizations? localizations,
  }) {
    final lastDay = DateTime(year, month + 1, 0);
    final first = getBengaliDate(DateTime(year, month, 1), localizations: localizations);
    final last  = getBengaliDate(lastDay, localizations: localizations);

    if (first.monthNumber == last.monthNumber) {
      return [
        BengaliMonth(
          name: first.monthName,
          year: first.year,
          startDate: DateTime(year, month, 1),
          endDate: lastDay,
        ),
      ];
    }

    DateTime? transition;
    for (int d = 2; d <= lastDay.day; d++) {
      final b = getBengaliDate(DateTime(year, month, d), localizations: localizations);
      if (b.monthNumber != first.monthNumber) {
        transition = DateTime(year, month, d);
        break;
      }
    }

    if (transition == null) return [];

    return [
      BengaliMonth(
        name: first.monthName,
        year: first.year,
        startDate: DateTime(year, month, 1),
        endDate: transition.subtract(const Duration(days: 1)),
      ),
      BengaliMonth(
        name: last.monthName,
        year: last.year,
        startDate: transition,
        endDate: lastDay,
      ),
    ];
  }

  List<String> getBengaliMonthNames({AppLocalizations? localizations}) {
    if (localizations == null) return List.unmodifiable(_monthNamesEn);
    return List.generate(12, (i) => localizations.getBanglaMonthName(i + 1));
  }

  static int _bengaliYear(int year, int month, int day) {
    final afterNewYear = month > 4 || (month == 4 && day >= 14);
    return year - (afterNewYear ? 593 : 594);
  }

  int _findBengaliMonth(int month, int day) {
    for (int bm = 1; bm <= 12; bm++) {
      final start = _monthStartDates[bm]!;
      final end   = _monthStartDates[bm == 12 ? 1 : bm + 1]!;
      if (_inRange(month, day, start[0], start[1], end[0], end[1])) return bm;
    }
    return 1;
  }

  /// Handles ranges that wrap around the year boundary (e.g. Poush: Dec 16 – Jan 14).
  bool _inRange(int month, int day, int sm, int sd, int em, int ed) {
    final date  = month * 100 + day;
    final start = sm * 100 + sd;
    final end   = em * 100 + ed;
    return start < end
        ? date >= start && date < end
        : date >= start || date < end;
  }

  int _bengaliDayOfMonth(int gYear, int gMonth, int gDay, int bMonth) {
    final start = _monthStartDates[bMonth]!;
    if (gMonth == start[0]) return gDay - start[1] + 1;

    int days = _daysInMonth(gYear, start[0]) - start[1] + 1;
    int m = start[0] + 1;
    while (true) {
      if (m > 12) m = 1;
      if (m == gMonth) break;
      days += _daysInMonth(gYear, m);
      m++;
    }
    return days + gDay;
  }

  int _daysInMonth(int year, int month) {
    if (month == 2) return _isLeapYear(year) ? 29 : 28;
    if (const [4, 6, 9, 11].contains(month)) return 30;
    return 31;
  }

  bool _isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
}

final bengaliCalendarServiceProvider = Provider<BengaliCalendarService>((ref) {
  return BengaliCalendarService();
});