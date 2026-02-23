// lib/features/calendar/models/hijri_date.dart

/// Represents a date in the Hijri (Islamic) calendar system
class HijriDate {
  final int day;
  final int monthNumber; // 1–12
  final int year;

  HijriDate({
    required this.day,
    required this.monthNumber,
    required this.year,
  });

  // ── Month names ────────────────────────────────────────

  static const List<String> _monthNamesEn = [
    'Muharram',
    'Safar',
    'Rabi al-Awwal',
    'Rabi al-Thani',
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    "Sha'ban",
    'Ramadan',
    'Shawwal',
    'Dhu al-Qadah',
    'Dhu al-Hijjah',
  ];

  static const List<String> _monthNamesBn = [
    'মুহাররম',
    'সফর',
    'রবিউল আউয়াল',
    'রবিউল আখির',
    'জমাদিউল আউয়াল',
    'জমাদিউল আখির',
    'রজব',
    'শাবান',
    'রমজান',
    'শাওয়াল',
    'জিলকদ',
    'জিলহজ',
  ];

  /// English transliterated month name
  String get monthName => _monthNamesEn[monthNumber - 1];

  /// Bangla transliterated month name
  String get monthNameBn => _monthNamesBn[monthNumber - 1];

  /// Localized month name by language code
  String monthNameForLocale(String languageCode) {
    return languageCode == 'bn' ? monthNameBn : monthName;
  }

  // ── Numeral helpers ────────────────────────────────────

  static String _toBengaliNumerals(int number) {
    const digits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return number.toString().split('').map((d) => digits[int.parse(d)]).join();
  }

  String get dayBn => _toBengaliNumerals(day);
  String get yearBn => _toBengaliNumerals(year);

  String dayForLocale(String languageCode) =>
      languageCode == 'bn' ? dayBn : day.toString();

  String yearForLocale(String languageCode) =>
      languageCode == 'bn' ? yearBn : year.toString();

  // ── Short month abbreviation (for calendar cells) ──────

  /// Up to 3-char abbreviation, e.g. "Muh", "Ram", "Raj"
  String get monthAbbr {
    final name = monthName;
    return name.length <= 3 ? name : name.substring(0, 3);
  }

  // ── Notable days ───────────────────────────────────────

  bool get isNewYear => monthNumber == 1 && day == 1;
  bool get isAshura => monthNumber == 1 && day == 10;
  bool get isIsraMiraj => monthNumber == 7 && day == 27;
  bool get isShabEBarat => monthNumber == 8 && day == 15;
  bool get isFirstRamadan => monthNumber == 9 && day == 1;
  bool get isEidAlFitr => monthNumber == 10 && day == 1;
  bool get isEidAlAdha => monthNumber == 12 && day == 10;

  // ── Formatting ─────────────────────────────────────────

  String format() => '$day $monthName $year AH';

  String formatBn() => '$dayBn $monthNameBn $yearBn হিজরি';

  String formatForLocale(String languageCode) =>
      languageCode == 'bn' ? formatBn() : format();

  // ── Equality & JSON ────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'day': day,
        'monthNumber': monthNumber,
        'year': year,
      };

  factory HijriDate.fromJson(Map<String, dynamic> json) => HijriDate(
        day: json['day'] as int,
        monthNumber: json['monthNumber'] as int,
        year: json['year'] as int,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HijriDate &&
          other.day == day &&
          other.monthNumber == monthNumber &&
          other.year == year;

  @override
  int get hashCode => Object.hash(day, monthNumber, year);

  @override
  String toString() => 'HijriDate(day: $day, month: $monthName, year: $year AH)';
}