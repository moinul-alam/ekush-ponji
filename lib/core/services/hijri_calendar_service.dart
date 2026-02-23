// lib/core/services/hijri_calendar_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/calendar/models/hijri_date.dart';

/// Hijri Calendar Service
///
/// Uses a verified Umm al-Qura lookup table for 2019–2030,
/// with a tabular fallback for dates outside that range.
/// The previous pure-algorithmic approach was off by ~3 days
/// because the tabular calendar doesn't match observed moon sightings.
class HijriCalendarService {
  // ── Lookup table ───────────────────────────────────────
  // Each entry: [julianDay, hijriYear, hijriMonth]
  // julianDay = JD of the 1st day of that Hijri month
  // Source: Umm al-Qura calendar (Saudi Arabia), the global standard
  // Coverage: 1 Muharram 1441 (1 Sep 2019) → end of 1451 (Apr 2030)
  static const List<List<int>> _monthStarts = [
    [2458728, 1441, 1],  // 01/09/2019
    [2458757, 1441, 2],  // 30/09/2019
    [2458786, 1441, 3],  // 29/10/2019
    [2458815, 1441, 4],  // 27/11/2019
    [2458844, 1441, 5],  // 26/12/2019
    [2458874, 1441, 6],  // 25/01/2020
    [2458903, 1441, 7],  // 23/02/2020
    [2458933, 1441, 8],  // 24/03/2020
    [2458963, 1441, 9],  // 23/04/2020
    [2458993, 1441, 10], // 23/05/2020
    [2459022, 1441, 11], // 21/06/2020
    [2459052, 1441, 12], // 21/07/2020
    [2459082, 1442, 1],  // 20/08/2020
    [2459111, 1442, 2],  // 18/09/2020
    [2459141, 1442, 3],  // 18/10/2020
    [2459170, 1442, 4],  // 16/11/2020
    [2459199, 1442, 5],  // 15/12/2020
    [2459228, 1442, 6],  // 13/01/2021
    [2459258, 1442, 7],  // 12/02/2021
    [2459287, 1442, 8],  // 13/03/2021
    [2459318, 1442, 9],  // 13/04/2021
    [2459347, 1442, 10], // 12/05/2021
    [2459377, 1442, 11], // 11/06/2021
    [2459406, 1442, 12], // 10/07/2021
    [2459436, 1443, 1],  // 09/08/2021
    [2459466, 1443, 2],  // 08/09/2021
    [2459495, 1443, 3],  // 07/10/2021
    [2459524, 1443, 4],  // 05/11/2021
    [2459554, 1443, 5],  // 05/12/2021
    [2459583, 1443, 6],  // 03/01/2022
    [2459613, 1443, 7],  // 02/02/2022
    [2459642, 1443, 8],  // 03/03/2022
    [2459672, 1443, 9],  // 02/04/2022
    [2459701, 1443, 10], // 01/05/2022
    [2459731, 1443, 11], // 31/05/2022
    [2459760, 1443, 12], // 29/06/2022
    [2459790, 1444, 1],  // 29/07/2022
    [2459820, 1444, 2],  // 28/08/2022
    [2459849, 1444, 3],  // 26/09/2022
    [2459878, 1444, 4],  // 25/10/2022
    [2459908, 1444, 5],  // 24/11/2022
    [2459938, 1444, 6],  // 24/12/2022
    [2459967, 1444, 7],  // 22/01/2023
    [2459996, 1444, 8],  // 20/02/2023
    [2460026, 1444, 9],  // 22/03/2023
    [2460056, 1444, 10], // 21/04/2023
    [2460085, 1444, 11], // 20/05/2023
    [2460115, 1444, 12], // 19/06/2023
    [2460145, 1445, 1],  // 19/07/2023
    [2460174, 1445, 2],  // 17/08/2023
    [2460204, 1445, 3],  // 16/09/2023
    [2460233, 1445, 4],  // 15/10/2023
    [2460262, 1445, 5],  // 13/11/2023
    [2460292, 1445, 6],  // 13/12/2023
    [2460321, 1445, 7],  // 11/01/2024
    [2460351, 1445, 8],  // 10/02/2024
    [2460381, 1445, 9],  // 11/03/2024
    [2460410, 1445, 10], // 09/04/2024
    [2460439, 1445, 11], // 08/05/2024
    [2460469, 1445, 12], // 07/06/2024
    [2460499, 1446, 1],  // 07/07/2024
    [2460528, 1446, 2],  // 05/08/2024
    [2460558, 1446, 3],  // 04/09/2024
    [2460587, 1446, 4],  // 03/10/2024
    [2460616, 1446, 5],  // 01/11/2024
    [2460646, 1446, 6],  // 01/12/2024
    [2460676, 1446, 7],  // 31/12/2024
    [2460705, 1446, 8],  // 29/01/2025
    [2460736, 1446, 9],  // 01/03/2025
    [2460765, 1446, 10], // 30/03/2025
    [2460795, 1446, 11], // 29/04/2025
    [2460824, 1446, 12], // 28/05/2025
    [2460854, 1447, 1],  // 27/06/2025
    [2460883, 1447, 2],  // 26/07/2025
    [2460913, 1447, 3],  // 25/08/2025
    [2460942, 1447, 4],  // 23/09/2025
    [2460972, 1447, 5],  // 23/10/2025
    [2461001, 1447, 6],  // 21/11/2025
    [2461031, 1447, 7],  // 21/12/2025
    [2461060, 1447, 8],  // 19/01/2026
    [2461091, 1447, 9],  // 19/02/2026  ← 1 Ramadan 1447
    [2461120, 1447, 10], // 20/03/2026
    [2461149, 1447, 11], // 18/04/2026
    [2461179, 1447, 12], // 18/05/2026
    [2461209, 1448, 1],  // 17/06/2026
    [2461238, 1448, 2],  // 16/07/2026
    [2461268, 1448, 3],  // 15/08/2026
    [2461297, 1448, 4],  // 13/09/2026
    [2461327, 1448, 5],  // 13/10/2026
    [2461356, 1448, 6],  // 11/11/2026
    [2461386, 1448, 7],  // 11/12/2026
    [2461415, 1448, 8],  // 09/01/2027
    [2461445, 1448, 9],  // 08/02/2027
    [2461474, 1448, 10], // 09/03/2027
    [2461504, 1448, 11], // 08/04/2027
    [2461533, 1448, 12], // 07/05/2027
    [2461563, 1449, 1],  // 06/06/2027
    [2461592, 1449, 2],  // 05/07/2027
    [2461622, 1449, 3],  // 04/08/2027
    [2461652, 1449, 4],  // 03/09/2027
    [2461681, 1449, 5],  // 02/10/2027
    [2461711, 1449, 6],  // 01/11/2027
    [2461740, 1449, 7],  // 30/11/2027
    [2461770, 1449, 8],  // 30/12/2027
    [2461799, 1449, 9],  // 28/01/2028
    [2461829, 1449, 10], // 27/02/2028
    [2461858, 1449, 11], // 27/03/2028
    [2461888, 1449, 12], // 26/04/2028
    [2461917, 1450, 1],  // 25/05/2028
    [2461947, 1450, 2],  // 24/06/2028
    [2461976, 1450, 3],  // 23/07/2028
    [2462006, 1450, 4],  // 22/08/2028
    [2462036, 1450, 5],  // 21/09/2028
    [2462065, 1450, 6],  // 20/10/2028
    [2462095, 1450, 7],  // 19/11/2028
    [2462124, 1450, 8],  // 18/12/2028
    [2462154, 1450, 9],  // 17/01/2029
    [2462183, 1450, 10], // 15/02/2029
    [2462213, 1450, 11], // 17/03/2029
    [2462242, 1450, 12], // 15/04/2029
    [2462272, 1451, 1],  // 15/05/2029
    [2462301, 1451, 2],  // 13/06/2029
    [2462331, 1451, 3],  // 13/07/2029
    [2462360, 1451, 4],  // 11/08/2029
    [2462390, 1451, 5],  // 10/09/2029
    [2462419, 1451, 6],  // 09/10/2029
    [2462449, 1451, 7],  // 08/11/2029
    [2462478, 1451, 8],  // 07/12/2029
    [2462508, 1451, 9],  // 06/01/2030
    [2462538, 1451, 10], // 05/02/2030
    [2462567, 1451, 11], // 06/03/2030
    [2462597, 1451, 12], // 05/04/2030
  ];

  // ── Public API ─────────────────────────────────────────

  /// Convert a Gregorian [DateTime] to a [HijriDate].
  HijriDate getHijriDate(DateTime gDate) {
    final jd = _gregorianToJulian(gDate.year, gDate.month, gDate.day);
    return _julianToHijri(jd);
  }

  /// Returns a display string of Hijri month(s) overlapping a Gregorian month.
  /// e.g. "Shaban – Ramadan 1447 AH" or "রমজান ১৪৪৭ হিজরি"
  String getHijriMonthsDisplay({
    required int gregorianYear,
    required int gregorianMonth,
    required String languageCode,
  }) {
    final lastDay = DateTime(gregorianYear, gregorianMonth + 1, 0).day;
    final first = getHijriDate(DateTime(gregorianYear, gregorianMonth, 1));
    final last = getHijriDate(DateTime(gregorianYear, gregorianMonth, lastDay));

    if (first.monthNumber == last.monthNumber) {
      return '${first.monthNameForLocale(languageCode)} '
          '${first.yearForLocale(languageCode)}';
    }

    final firstName = first.monthNameForLocale(languageCode);
    final lastName = last.monthNameForLocale(languageCode);
    final yearStr = first.year == last.year
        ? last.yearForLocale(languageCode)
        : '${first.yearForLocale(languageCode)}–${last.yearForLocale(languageCode)}';

    return '$firstName – $lastName $yearStr';
  }

  // ── Core conversion ────────────────────────────────────

  HijriDate _julianToHijri(int jd) {
    // Try lookup table first (accurate, covers 2019–2030)
    final result = _lookupHijri(jd);
    if (result != null) return result;

    // Fallback: tabular algorithm for out-of-range dates (±1 day accuracy)
    return _tabularHijri(jd);
  }

  /// Binary search the lookup table for the Hijri month containing [jd].
  HijriDate? _lookupHijri(int jd) {
    final first = _monthStarts.first[0];
    final last = _monthStarts.last[0];

    // Out of range — let fallback handle it
    if (jd < first) return null;

    // Find the last entry whose JD start ≤ jd
    int lo = 0;
    int hi = _monthStarts.length - 1;
    int found = -1;

    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (_monthStarts[mid][0] <= jd) {
        found = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }

    if (found < 0) return null;

    // If beyond the last entry's month end, let fallback handle it
    // (last entry covers up to ~30 days past its JD start)
    if (found == _monthStarts.length - 1 && jd > last + 30) return null;

    final entry = _monthStarts[found];
    final day = jd - entry[0] + 1;
    return HijriDate(day: day, monthNumber: entry[2], year: entry[1]);
  }

  /// Tabular (civil) Hijri algorithm — fallback for out-of-range dates.
  /// Uses Friday epoch (JD 1948438). Accurate to ±1–2 days.
  HijriDate _tabularHijri(int jd) {
    final d = jd - 1948438;
    final year = (30 * d + 10646) ~/ 10631;
    final month = (11 * (d - (10631 * year - 10617) ~/ 30) + 330) ~/ 325;
    final day = d -
        (29 * month - 29 + (6 * month - 1) ~/ 11) -
        (10631 * year - 10617) ~/ 30 +
        1;

    return HijriDate(
      day: day.clamp(1, 30),
      monthNumber: month.clamp(1, 12),
      year: year,
    );
  }

  /// Gregorian date → Julian Day Number
  int _gregorianToJulian(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
  }
}

/// Provider
final hijriCalendarServiceProvider = Provider<HijriCalendarService>((ref) {
  return HijriCalendarService();
});