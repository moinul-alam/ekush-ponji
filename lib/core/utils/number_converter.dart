// lib/core/utils/number_converter.dart

/// Converts numbers between English and Bengali numerals
///
/// English: 0123456789
/// Bengali: ০১২৩৪৫৬৭৮৯
class NumberConverter {
  // Private constructor to prevent instantiation
  NumberConverter._();

  /// Map of English to Bengali digits
  static const Map<String, String> _englishToBengali = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  /// Map of Bengali to English digits
  static const Map<String, String> _bengaliToEnglish = {
    '০': '0',
    '১': '1',
    '২': '2',
    '৩': '3',
    '৪': '4',
    '৫': '5',
    '৬': '6',
    '৭': '7',
    '৮': '8',
    '৯': '9',
  };

  /// Convert English numerals to Bengali numerals
  ///
  /// Example: "123" → "১২৩"
  static String toBengali(dynamic value) {
    if (value == null) return '';

    String text = value.toString();
    String result = text;

    _englishToBengali.forEach((english, bengali) {
      result = result.replaceAll(english, bengali);
    });

    return result;
  }

  /// Convert Bengali numerals to English numerals
  ///
  /// Example: "১২৩" → "123"
  static String toEnglish(String text) {
    if (text.isEmpty) return '';

    String result = text;

    _bengaliToEnglish.forEach((bengali, english) {
      result = result.replaceAll(bengali, english);
    });

    return result;
  }

  /// Convert number to localized string based on language code
  ///
  /// Example:
  /// - toBengali: convertToLocale(123, 'bn') → "১২৩"
  /// - toEnglish: convertToLocale(123, 'en') → "123"
  static String convertToLocale(dynamic value, String languageCode) {
    if (value == null) return '';

    return languageCode == 'bn' ? toBengali(value) : value.toString();
  }

  /// Check if string contains Bengali numerals
  static bool hasBengaliNumerals(String text) {
    return _bengaliToEnglish.keys.any((bengali) => text.contains(bengali));
  }

  /// Check if string contains English numerals
  static bool hasEnglishNumerals(String text) {
    return _englishToBengali.keys.any((english) => text.contains(english));
  }

  /// Parse Bengali numeral string to int
  ///
  /// Example: "১২৩" → 123
  static int? parseBengaliInt(String text) {
    try {
      String englishText = toEnglish(text);
      return int.parse(englishText);
    } catch (e) {
      return null;
    }
  }

  /// Parse Bengali numeral string to double
  ///
  /// Example: "১২৩.৪৫" → 123.45
  static double? parseBengaliDouble(String text) {
    try {
      String englishText = toEnglish(text);
      return double.parse(englishText);
    } catch (e) {
      return null;
    }
  }

  /// Format number with thousands separator (localized)
  ///
  /// Example:
  /// - Bengali: formatWithSeparator(1234567, 'bn') → "১২,৩৪,৫৬৭"
  /// - English: formatWithSeparator(1234567, 'en') → "1,234,567"
  static String formatWithSeparator(int number, String languageCode) {
    String numStr = number.toString();

    // Apply Indian numbering system (lakhs, crores) for Bengali
    if (languageCode == 'bn') {
      return _formatIndianNumbering(numStr, true);
    }

    // Apply Western numbering system (thousands) for English
    return _formatWesternNumbering(numStr, false);
  }

  /// Format with Indian numbering system (XX,XX,XXX)
  static String _formatIndianNumbering(String numStr, bool toBengali) {
    if (numStr.length <= 3) {
      return toBengali ? NumberConverter.toBengali(numStr) : numStr;
    }

    String result = '';
    int length = numStr.length;

    // Last 3 digits
    result = numStr.substring(length - 3);
    int remaining = length - 3;

    // Add groups of 2 digits
    while (remaining > 0) {
      int take = remaining >= 2 ? 2 : remaining;
      result = '${numStr.substring(remaining - take, remaining)},$result';
      remaining -= take;
    }

    return toBengali ? NumberConverter.toBengali(result) : result;
  }

  /// Format with Western numbering system (XXX,XXX,XXX)
  static String _formatWesternNumbering(String numStr, bool toBengali) {
    if (numStr.length <= 3) {
      return toBengali ? NumberConverter.toBengali(numStr) : numStr;
    }

    String result = '';
    int count = 0;

    for (int i = numStr.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = ',$result';
        count = 0;
      }
      result = numStr[i] + result;
      count++;
    }

    return toBengali ? NumberConverter.toBengali(result) : result;
  }
}
