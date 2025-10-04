/// Model for date duration calculation results
/// Contains all calculated duration formats
class DateCalculationResult {
  final int years;
  final int months;
  final int days;
  final int totalDays;
  final int weeks;
  final int remainingDays;

  DateCalculationResult({
    required this.years,
    required this.months,
    required this.days,
    required this.totalDays,
    required this.weeks,
    required this.remainingDays,
  });

  /// Format years/months/days as "X Years Y Months Z Days"
  String formatYearsMonthsDays() {
    final parts = <String>[];

    if (years > 0) {
      parts.add('$years ${years == 1 ? "Year" : "Years"}');
    }
    if (months > 0) {
      parts.add('$months ${months == 1 ? "Month" : "Months"}');
    }
    if (days > 0 || parts.isEmpty) {
      parts.add('$days ${days == 1 ? "Day" : "Days"}');
    }

    return parts.join(' ');
  }

  /// Format total days as "X Days"
  String formatTotalDays() {
    return '$totalDays ${totalDays == 1 ? "Day" : "Days"}';
  }

  /// Format weeks and days as "X Weeks Y Days"
  String formatWeeksAndDays() {
    final parts = <String>[];

    if (weeks > 0) {
      parts.add('$weeks ${weeks == 1 ? "Week" : "Weeks"}');
    }
    if (remainingDays > 0 || parts.isEmpty) {
      parts.add('$remainingDays ${remainingDays == 1 ? "Day" : "Days"}');
    }

    return parts.join(' ');
  }

  /// Check if result is empty (zero duration)
  bool get isEmpty => totalDays == 0;

  @override
  String toString() {
    return 'DateCalculationResult(years: $years, months: $months, days: $days, totalDays: $totalDays, weeks: $weeks, remainingDays: $remainingDays)';
  }
}
