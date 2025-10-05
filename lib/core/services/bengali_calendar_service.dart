// lib/core/services/bengali_calendar_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/calendar/models/bengali_date.dart';

/// Bengali Calendar Service
/// Fast, algorithmic conversion for Gregorian → Bengali
/// Accurate from 1987 onwards (Bangladesh revised calendar)
class BengaliCalendarService {
  // Month start dates (Gregorian) for Bengali months
  static const Map<int, List<int>> _monthTransitions = {
    1: [4, 14],   // Boishakh starts April 14
    2: [5, 15],   // Jyoishtho starts May 15
    3: [6, 15],   // Asharh starts June 15
    4: [7, 16],   // Srabon starts July 16
    5: [8, 16],   // Bhadro starts August 16
    6: [9, 16],   // Ashwin starts September 16
    7: [10, 17],  // Kartik starts October 17
    8: [11, 16],  // Ogrohayon starts November 16
    9: [12, 16],  // Poush starts December 16
    10: [1, 15],  // Magh starts January 15
    11: [2, 14],  // Falgun starts February 14
    12: [3, 15],  // Choitra starts March 15
  };

  static const List<String> _monthNames = [
    'Boishakh',
    'Jyoishtho',
    'Asharh',
    'Srabon',
    'Bhadro',
    'Ashwin',
    'Kartik',
    'Ogrohayon',
    'Poush',
    'Magh',
    'Falgun',
    'Choitra',
  ];

  /// Convert Gregorian date → BengaliDate
  BengaliDate getBengaliDate(DateTime gDate) {
    final year = gDate.year;
    final month = gDate.month;
    final day = gDate.day;

    int bYear = (month < 4 || (month == 4 && day < 14)) ? year - 594 : year - 593;
    int bMonth = 1;
    int bDay = 1;

    for (int i = 1; i <= 12; i++) {
      final start = _monthTransitions[i]!;
      final nextIndex = i == 12 ? 1 : i + 1;
      final end = _monthTransitions[nextIndex]!;

      if (_isInRange(month, day, start[0], start[1], end[0], end[1])) {
        bMonth = i;

        if (month == start[0]) {
          bDay = day - start[1] + 1;
        } else {
          // Calculate days from start month to current date
          int days = _daysInMonth(year, start[0]) - start[1] + 1;
          for (int m = start[0] + 1; m < month; m++) {
            days += _daysInMonth(year, m);
          }
          bDay = days + day;
        }

        // Year adjustment for Magh/Falgun/Choitra
        if (i >= 10 && month <= 3) bYear--;

        break;
      }
    }

    return BengaliDate(
      day: bDay,
      monthName: _monthNames[bMonth - 1],
      year: bYear,
      monthNumber: bMonth,
    );
  }

  /// Check if date is in Bengali month range
  bool _isInRange(int month, int day, int startMonth, int startDay, int endMonth, int endDay) {
    if (startMonth == endMonth) return month == startMonth && day >= startDay && day < endDay;
    if (startMonth > endMonth) {
      // Range crosses year boundary
      if (month == startMonth) return day >= startDay;
      if (month == endMonth) return day < endDay;
      return month > startMonth || month < endMonth;
    }
    return (month == startMonth && day >= startDay) || (month == endMonth && day < endDay) || (month > startMonth && month < endMonth);
  }

  /// Days in Gregorian month
  int _daysInMonth(int year, int month) {
    if (month == 2) return _isLeapYear(year) ? 29 : 28;
    if ([4, 6, 9, 11].contains(month)) return 30;
    return 31;
  }

  /// Leap year check
  bool _isLeapYear(int year) => (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

  /// Bengali months that span a Gregorian month
  List<BengaliMonth> getBengaliMonthsForGregorianMonth(int year, int month) {
    final first = getBengaliDate(DateTime(year, month, 1));
    final last = getBengaliDate(DateTime(year, month + 1, 0));
    final months = <BengaliMonth>[];

    if (first.monthNumber == last.monthNumber) {
      months.add(BengaliMonth(
        name: first.monthName,
        year: first.year,
        startDate: DateTime(year, month, 1),
        endDate: DateTime(year, month + 1, 0),
      ));
    } else {
      // Find transition
      DateTime? transition;
      for (int d = 1; d <= DateTime(year, month + 1, 0).day; d++) {
        final b = getBengaliDate(DateTime(year, month, d));
        if (b.monthNumber != first.monthNumber) {
          transition = DateTime(year, month, d);
          break;
        }
      }
      if (transition != null) {
        months.add(BengaliMonth(name: first.monthName, year: first.year, startDate: DateTime(year, month, 1), endDate: transition.subtract(const Duration(days: 1))));
        months.add(BengaliMonth(name: last.monthName, year: last.year, startDate: transition, endDate: DateTime(year, month + 1, 0)));
      }
    }

    return months;
  }

  /// All Bengali month names
  List<String> getBengaliMonthNames() => List.unmodifiable(_monthNames);

  /// English → Bangla month name
  String getBengaliMonthNameBn(String englishName) {
    const map = {
      'Boishakh': 'বৈশাখ',
      'Jyoishtho': 'জ্যৈষ্ঠ',
      'Asharh': 'আষাঢ়',
      'Srabon': 'শ্রাবণ',
      'Bhadro': 'ভাদ্র',
      'Ashwin': 'আশ্বিন',
      'Kartik': 'কার্তিক',
      'Ogrohayon': 'অগ্রহায়ণ',
      'Poush': 'পৌষ',
      'Magh': 'মাঘ',
      'Falgun': 'ফাল্গুন',
      'Choitra': 'চৈত্র',
    };
    return map[englishName] ?? englishName;
  }
}

/// Provider
final bengaliCalendarServiceProvider = Provider<BengaliCalendarService>((ref) {
  return BengaliCalendarService();
});
