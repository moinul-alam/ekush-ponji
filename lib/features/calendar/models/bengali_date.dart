/// features/calendar/models/bengali_date.dart
/// Represents a date in the Bengali calendar system
class BengaliDate {
  final int day;
  final String monthName; // e.g., "Poush", "Magh"
  final int year;
  final int monthNumber; // 1-12

  BengaliDate({
    required this.day,
    required this.monthName,
    required this.year,
    required this.monthNumber,
  });

  /// Get Bengali month name in Bangla
  String get monthNameBn {
    switch (monthName.toLowerCase()) {
      case 'boishakh':
        return 'বৈশাখ';
      case 'jyoishtho':
        return 'জ্যৈষ্ঠ';
      case 'asharh':
        return 'আষাঢ়';
      case 'srabon':
        return 'শ্রাবণ';
      case 'bhadro':
        return 'ভাদ্র';
      case 'ashwin':
        return 'আশ্বিন';
      case 'kartik':
        return 'কার্তিক';
      case 'ogrohayon':
        return 'অগ্রহায়ণ';
      case 'poush':
        return 'পৌষ';
      case 'magh':
        return 'মাঘ';
      case 'falgun':
        return 'ফাল্গুন';
      case 'choitra':
        return 'চৈত্র';
      default:
        return monthName;
    }
  }

  /// Get Bengali day in Bangla numerals
  String get dayBn {
    return _convertToBengaliNumerals(day);
  }

  /// Get Bengali year in Bangla numerals
  String get yearBn {
    return _convertToBengaliNumerals(year);
  }

  /// Format as "DD MonthName YYYY"
  String format() {
    return '$day $monthName $year';
  }

  /// Format as "DD মাস বছর" (Bengali)
  String formatBn() {
    return '$dayBn $monthNameBn $yearBn';
  }

  /// Convert number to Bengali numerals
  String _convertToBengaliNumerals(int number) {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return number
        .toString()
        .split('')
        .map((digit) => bengaliDigits[int.parse(digit)])
        .join();
  }

  /// Check if this is the first day of Bengali year (Pohela Boishakh)
  bool get isPohelaBoishakh {
    return monthNumber == 1 && day == 1;
  }

  /// Copy with method
  BengaliDate copyWith({
    int? day,
    String? monthName,
    int? year,
    int? monthNumber,
  }) {
    return BengaliDate(
      day: day ?? this.day,
      monthName: monthName ?? this.monthName,
      year: year ?? this.year,
      monthNumber: monthNumber ?? this.monthNumber,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'monthName': monthName,
      'year': year,
      'monthNumber': monthNumber,
    };
  }

  /// Create from JSON
  factory BengaliDate.fromJson(Map<String, dynamic> json) {
    return BengaliDate(
      day: json['day'] as int,
      monthName: json['monthName'] as String,
      year: json['year'] as int,
      monthNumber: json['monthNumber'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BengaliDate &&
        other.day == day &&
        other.monthName == monthName &&
        other.year == year &&
        other.monthNumber == monthNumber;
  }

  @override
  int get hashCode {
    return Object.hash(day, monthName, year, monthNumber);
  }

  @override
  String toString() {
    return 'BengaliDate(day: $day, month: $monthName, year: $year)';
  }
}

/// Helper class for Bengali month information
class BengaliMonth {
  final String name;
  final int year;
  final DateTime startDate;
  final DateTime endDate;

  BengaliMonth({
    required this.name,
    required this.year,
    required this.startDate,
    required this.endDate,
  });

  /// Get month name in Bangla
  String get nameBn {
    switch (name.toLowerCase()) {
      case 'boishakh':
        return 'বৈশাখ';
      case 'jyoishtho':
        return 'জ্যৈষ্ঠ';
      case 'asharh':
        return 'আষাঢ়';
      case 'srabon':
        return 'শ্রাবণ';
      case 'bhadro':
        return 'ভাদ্র';
      case 'ashwin':
        return 'আশ্বিন';
      case 'kartik':
        return 'কার্তিক';
      case 'ogrohayon':
        return 'অগ্রহায়ণ';
      case 'poush':
        return 'পৌষ';
      case 'magh':
        return 'মাঘ';
      case 'falgun':
        return 'ফাল্গুন';
      case 'choitra':
        return 'চৈত্র';
      default:
        return name;
    }
  }

  /// Check if a Gregorian date falls within this Bengali month
  bool contains(DateTime gregorianDate) {
    return gregorianDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
        gregorianDate.isBefore(endDate.add(const Duration(days: 1)));
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'year': year,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  /// check again if fails
  // factory BengaliMonth.fromJson(Map<String, dynamic> json) {
  //   return BengaliMonth(
  //     name: json['name'] as String,
  //     year: json['bengaliYear'] as int, // Changed from 'year' to 'bengaliYear'
  //     startDate: DateTime.parse(json['startDate'] as String),
  //     endDate: DateTime.parse(json['endDate'] as String),
  //   );
  // }

  factory BengaliMonth.fromJson(Map<String, dynamic> json) {
    return BengaliMonth(
      name: json['name'] as String,
      year: json['year'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }

  @override
  String toString() {
    return 'BengaliMonth(name: $name, year: $year)';
  }
}
