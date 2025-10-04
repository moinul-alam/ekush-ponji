import 'package:ekush_ponji/features/calendar/models/bengali_date.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fast Bengali Calendar Service using algorithmic conversion
/// Based on Bangladesh Revised Bengali Calendar (1987 reform)
/// Accurate for dates from 1987 onwards
class BengaliCalendarService {
  // Bengali month transition dates (approximate, based on solar calendar)
  // These are the standard dates for month transitions
  static const Map<int, List<int>> _monthTransitions = {
    1: [4, 14], // Boishakh starts April 14/15
    2: [5, 15], // Jyoishtho starts May 15
    3: [6, 15], // Asharh starts June 15
    4: [7, 16], // Srabon starts July 16
    5: [8, 16], // Bhadro starts August 16
    6: [9, 16], // Ashwin starts September 16
    7: [10, 17], // Kartik starts October 17
    8: [11, 16], // Ogrohayon starts November 16
    9: [12, 16], // Poush starts December 16
    10: [1, 15], // Magh starts January 15
    11: [2, 14], // Falgun starts February 14
    12: [3, 15], // Choitra starts March 15
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

  /// Convert Gregorian date to Bengali date (fast, synchronous)
  BengaliDate getBengaliDate(DateTime gregorianDate) {
    final year = gregorianDate.year;
    final month = gregorianDate.month;
    final day = gregorianDate.day;

    // Calculate Bengali year
    // Bengali year changes on April 14/15
    int bengaliYear;
    if (month < 4 || (month == 4 && day < 14)) {
      bengaliYear = year - 594;
    } else {
      bengaliYear = year - 593;
    }

    // Find which Bengali month this date falls into
    int bengaliMonth = 1;
    int bengaliDay = 1;

    // Check each month transition
    for (int i = 1; i <= 12; i++) {
      final transition = _monthTransitions[i]!;
      final transitionMonth = transition[0];
      final transitionDay = transition[1];

      // Get next month's transition
      final nextMonthIndex = i == 12 ? 1 : i + 1;
      final nextTransition = _monthTransitions[nextMonthIndex]!;
      final nextMonth = nextTransition[0];
      final nextDay = nextTransition[1];

      // Check if current date falls in this Bengali month
      if (_isDateInRange(
        month,
        day,
        transitionMonth,
        transitionDay,
        nextMonth,
        nextDay,
      )) {
        bengaliMonth = i;

        // Calculate day within the Bengali month
        if (month == transitionMonth) {
          bengaliDay = day - transitionDay + 1;
        } else {
          // Handle month crossing
          final daysInTransitionMonth = _getDaysInMonth(year, transitionMonth);
          final daysFromTransitionMonth =
              daysInTransitionMonth - transitionDay + 1;

          int totalDays = daysFromTransitionMonth;
          int currentMonth = transitionMonth + 1;

          while (currentMonth < month) {
            totalDays += _getDaysInMonth(year, currentMonth);
            currentMonth++;
          }

          bengaliDay = totalDays + day;
        }

        // Adjust for year boundary
        if (i >= 10 && month <= 3) {
          bengaliYear--;
        }

        break;
      }
    }

    return BengaliDate(
      day: bengaliDay,
      monthName: _monthNames[bengaliMonth - 1],
      year: bengaliYear,
      monthNumber: bengaliMonth,
    );
  }

  /// Get Bengali months that span a Gregorian month
  List<BengaliMonth> getBengaliMonthsForGregorianMonth(int year, int month) {
    final firstDate = DateTime(year, month, 1);
    final lastDate = DateTime(year, month + 1, 0);

    final firstBengali = getBengaliDate(firstDate);
    final lastBengali = getBengaliDate(lastDate);

    final months = <BengaliMonth>[];

    if (firstBengali.monthNumber == lastBengali.monthNumber) {
      // Single Bengali month
      months.add(BengaliMonth(
        name: firstBengali.monthName,
        year: firstBengali.year,
        startDate: firstDate,
        endDate: lastDate,
      ));
    } else {
      // Two Bengali months
      // Find transition date
      DateTime? transitionDate;
      for (int day = 1; day <= lastDate.day; day++) {
        final date = DateTime(year, month, day);
        final bengali = getBengaliDate(date);
        if (bengali.monthNumber != firstBengali.monthNumber) {
          transitionDate = date;
          break;
        }
      }

      if (transitionDate != null) {
        // First Bengali month
        months.add(BengaliMonth(
          name: firstBengali.monthName,
          year: firstBengali.year,
          startDate: firstDate,
          endDate: transitionDate.subtract(const Duration(days: 1)),
        ));

        // Second Bengali month
        months.add(BengaliMonth(
          name: lastBengali.monthName,
          year: lastBengali.year,
          startDate: transitionDate,
          endDate: lastDate,
        ));
      }
    }

    return months;
  }

  /// Check if a date falls within a range
  bool _isDateInRange(
    int month,
    int day,
    int startMonth,
    int startDay,
    int endMonth,
    int endDay,
  ) {
    if (startMonth == endMonth) {
      return month == startMonth && day >= startDay && day < endDay;
    }

    // Handle year boundary
    if (startMonth > endMonth) {
      // Range crosses year boundary (e.g., Dec to Jan)
      if (month == startMonth) {
        return day >= startDay;
      } else if (month == endMonth) {
        return day < endDay;
      } else if (month > startMonth || month < endMonth) {
        return true;
      }
      return false;
    }

    // Normal range
    if (month == startMonth) {
      return day >= startDay;
    } else if (month == endMonth) {
      return day < endDay;
    } else if (month > startMonth && month < endMonth) {
      return true;
    }

    return false;
  }

  /// Get number of days in a Gregorian month
  int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      return _isLeapYear(year) ? 29 : 28;
    }
    if (month == 4 || month == 6 || month == 9 || month == 11) {
      return 30;
    }
    return 31;
  }

  /// Check if a year is a leap year
  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Get all Bengali month names
  List<String> getBengaliMonthNames() {
    return List.unmodifiable(_monthNames);
  }

  /// Get Bengali month name in Bangla
  String getBengaliMonthNameBn(String englishName) {
    const nameMap = {
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

    return nameMap[englishName] ?? englishName;
  }
}

/// Provider for BengaliCalendarService
final bengaliCalendarServiceProvider = Provider<BengaliCalendarService>((ref) {
  return BengaliCalendarService();
});
