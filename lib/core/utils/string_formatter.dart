// lib/core/utils/string_formatter.dart

import 'package:ekush_ponji/core/utils/number_converter.dart';

/// Handles string formatting with dynamic values and localization
///
/// Supports:
/// - Placeholder replacement (%s, %d, %1$s, %2$d)
/// - Number localization (Bengali/English numerals)
/// - Plural handling
class StringFormatter {
  // Private constructor
  StringFormatter._();

  /// Format string with positional arguments
  ///
  /// Supports placeholders:
  /// - %s : String
  /// - %d : Number (will be localized)
  /// - %1$s, %2$d : Positional arguments
  ///
  /// Example:
  /// ```dart
  /// formatString("Hello %s", ["World"]) → "Hello World"
  /// formatString("%d days", [5], 'bn') → "৫ days"
  /// formatString("%1$s has %2$d items", ["Cart", 3]) → "Cart has 3 items"
  /// ```
  static String formatString(
    String template,
    List<dynamic> args, {
    String? languageCode,
  }) {
    if (args.isEmpty) return template;

    String result = template;

    // Handle positional placeholders (%1$s, %2$d, etc.)
    for (int i = 0; i < args.length; i++) {
      int position = i + 1;
      String value = _formatValue(args[i], languageCode);

      // Replace positional placeholders
      result = result.replaceAll('%$position\$s', value);
      result = result.replaceAll('%$position\$d', value);
    }

    // Handle simple placeholders (%s, %d)
    for (var arg in args) {
      String value = _formatValue(arg, languageCode);

      if (result.contains('%d')) {
        result = result.replaceFirst('%d', value);
      } else if (result.contains('%s')) {
        result = result.replaceFirst('%s', value);
      }
    }

    return result;
  }

  /// Format value based on type and locale
  static String _formatValue(dynamic value, String? languageCode) {
    if (value == null) return '';

    String strValue = value.toString();

    // Localize numbers if language code provided
    if (languageCode != null && (value is int || value is double)) {
      return NumberConverter.convertToLocale(value, languageCode);
    }

    return strValue;
  }

  /// Format string with named arguments
  ///
  /// Example:
  /// ```dart
  /// formatNamed(
  ///   "Hello {name}, you have {count} messages",
  ///   {'name': 'John', 'count': 5},
  ///   'en'
  /// ) → "Hello John, you have 5 messages"
  /// ```
  static String formatNamed(
    String template,
    Map<String, dynamic> args, {
    String? languageCode,
  }) {
    String result = template;

    args.forEach((key, value) {
      String formattedValue = _formatValue(value, languageCode);
      result = result.replaceAll('{$key}', formattedValue);
    });

    return result;
  }

  /// Handle pluralization
  ///
  /// Example:
  /// ```dart
  /// plural(1, 'day', 'days') → "day"
  /// plural(5, 'day', 'days') → "days"
  /// plural(0, 'item', 'items', zeroForm: 'no items') → "no items"
  /// ```
  static String plural(
    int count,
    String singular,
    String plural, {
    String? zeroForm,
    String? languageCode,
  }) {
    if (count == 0 && zeroForm != null) {
      return zeroForm;
    }
    return count == 1 ? singular : plural;
  }

  /// Format count with plural
  ///
  /// Example:
  /// ```dart
  /// formatPlural(5, 'day', 'days', 'bn') → "৫ days"
  /// formatPlural(1, 'item', 'items', 'en') → "1 item"
  /// ```
  static String formatPlural(
    int count,
    String singular,
    String plural, {
    String? zeroForm,
    String? languageCode,
  }) {
    String countStr = languageCode != null
        ? NumberConverter.convertToLocale(count, languageCode)
        : count.toString();

    String word = StringFormatter.plural(
      count,
      singular,
      plural,
      zeroForm: zeroForm,
    );

    return '$countStr $word';
  }

  /// Format duration (years, months, days)
  ///
  /// Example:
  /// ```dart
  /// formatDuration(2, 5, 10, yearWord: 'year', monthWord: 'month', dayWord: 'day')
  /// → "2 years 5 months 10 days"
  /// ```
  static String formatDuration({
    required int years,
    required int months,
    required int days,
    required String yearWord,
    required String yearsWord,
    required String monthWord,
    required String monthsWord,
    required String dayWord,
    required String daysWord,
    String? languageCode,
    String separator = ' ',
  }) {
    List<String> parts = [];

    if (years > 0) {
      String yearStr = languageCode != null
          ? NumberConverter.convertToLocale(years, languageCode)
          : years.toString();
      String word = plural(years, yearWord, yearsWord);
      parts.add('$yearStr $word');
    }

    if (months > 0) {
      String monthStr = languageCode != null
          ? NumberConverter.convertToLocale(months, languageCode)
          : months.toString();
      String word = plural(months, monthWord, monthsWord);
      parts.add('$monthStr $word');
    }

    if (days > 0) {
      String dayStr = languageCode != null
          ? NumberConverter.convertToLocale(days, languageCode)
          : days.toString();
      String word = plural(days, dayWord, daysWord);
      parts.add('$dayStr $word');
    }

    return parts.isEmpty ? '0 $daysWord' : parts.join(separator);
  }

  /// Format large numbers with K, M, B suffixes
  ///
  /// Example:
  /// ```dart
  /// formatCompact(1500, 'en') → "1.5K"
  /// formatCompact(1000000, 'bn') → "১০L" (10 Lakh)
  /// ```
  static String formatCompact(int number, String languageCode) {
    if (languageCode == 'bn') {
      // Indian system: Thousand, Lakh, Crore
      if (number >= 10000000) {
        return '${NumberConverter.toBengali((number / 10000000).toStringAsFixed(1))}Cr';
      } else if (number >= 100000) {
        return '${NumberConverter.toBengali((number / 100000).toStringAsFixed(1))}L';
      } else if (number >= 1000) {
        return '${NumberConverter.toBengali((number / 1000).toStringAsFixed(1))}K';
      }
      return NumberConverter.toBengali(number);
    } else {
      // Western system: K, M, B
      if (number >= 1000000000) {
        return '${(number / 1000000000).toStringAsFixed(1)}B';
      } else if (number >= 1000000) {
        return '${(number / 1000000).toStringAsFixed(1)}M';
      } else if (number >= 1000) {
        return '${(number / 1000).toStringAsFixed(1)}K';
      }
      return number.toString();
    }
  }

  /// Replace multiple placeholders at once
  ///
  /// Example:
  /// ```dart
  /// replaceAll(
  ///   "In {days} days on {date}",
  ///   {'{days}': '5', '{date}': 'Monday'}
  /// ) → "In 5 days on Monday"
  /// ```
  static String replaceAll(String template, Map<String, String> replacements) {
    String result = template;
    replacements.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Title case (capitalize each word)
  static String titleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }
}
