// lib/core/localization/app_localizations.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations_en.dart';
import 'package:ekush_ponji/core/localization/app_localizations_bn.dart';
import 'package:ekush_ponji/core/utils/string_formatter.dart';
import 'package:ekush_ponji/core/utils/number_converter.dart';

/// Base class for app localizations
/// Provides translation methods and language-specific functionality
abstract class AppLocalizations {
  /// Get the current locale
  Locale get locale;

  /// Get language code
  String get languageCode => locale.languageCode;

  /// Get translation by key (for future dynamic translations)
  String translate(String key);

  /// Static method to get localizations from context
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Factory method to create appropriate localization instance
  static AppLocalizations? load(Locale locale) {
    switch (locale.languageCode) {
      case 'bn':
        return AppLocalizationsBn();
      case 'en':
        return AppLocalizationsEn();
      default:
        return AppLocalizationsBn(); // Default to Bangla
    }
  }

  /// Check if locale is supported
  static bool isSupported(Locale locale) {
    return ['bn', 'en'].contains(locale.languageCode);
  }

  // ========================================
  // FORMATTING HELPERS
  // ========================================

  /// Format string with arguments
  ///
  /// Example:
  /// ```dart
  /// format("In %d days", [5])
  /// // Bengali: "৫ দিনে"
  /// // English: "In 5 days"
  /// ```
  String format(String template, List<dynamic> args) {
    return StringFormatter.formatString(
      template,
      args,
      languageCode: languageCode,
    );
  }

  /// Format with named arguments
  ///
  /// Example:
  /// ```dart
  /// formatNamed("Hello {name}", {'name': 'John'})
  /// ```
  String formatNamed(String template, Map<String, dynamic> args) {
    return StringFormatter.formatNamed(
      template,
      args,
      languageCode: languageCode,
    );
  }

  /// Convert number to localized string
  ///
  /// Example:
  /// ```dart
  /// localizeNumber(123)
  /// // Bengali: "১২৩"
  /// // English: "123"
  /// ```
  String localizeNumber(dynamic number) {
    return NumberConverter.convertToLocale(number, languageCode);
  }

  /// Format number with thousands separator
  ///
  /// Example:
  /// ```dart
  /// formatNumber(1234567)
  /// // Bengali: "১২,৩৪,৫৬৭"
  /// // English: "1,234,567"
  /// ```
  String formatNumber(int number) {
    return NumberConverter.formatWithSeparator(number, languageCode);
  }

  /// Format count with plural
  ///
  /// Example:
  /// ```dart
  /// formatCount(5, day, days)
  /// // Bengali: "৫ দিন"
  /// // English: "5 days"
  /// ```
  String formatCount(int count, String singular, String plural) {
    return StringFormatter.formatPlural(
      count,
      singular,
      plural,
      languageCode: languageCode,
    );
  }

  /// Format "X days ago" or "In X days"
  String formatDaysDistance(int days) {
    if (days == 0) return today;
    if (days == 1) return tomorrow;
    if (days == -1) return yesterday;

    String daysStr = localizeNumber(days.abs());

    if (days > 0) {
      return format(inDays, [daysStr]);
    } else {
      return format(daysAgo, [daysStr]);
    }
  }

  /// Format duration (years, months, days)
  String formatDuration({
    required int years,
    required int months,
    required int days,
  }) {
    return StringFormatter.formatDuration(
      years: years,
      months: months,
      days: days,
      yearWord: year,
      yearsWord: years > 1 ? this.years : year,
      monthWord: month,
      monthsWord: months > 1 ? this.months : month,
      dayWord: day,
      daysWord: days > 1 ? this.days : day,
      languageCode: languageCode,
    );
  }

  // ========================================
  // COMMON TRANSLATIONS
  // ========================================

  String get appName;
  String get appTitle;

  // Navigation
  String get navHome;
  String get navCalendar;
  String get navCalculator;
  String get navSettings;

  // Common actions
  String get ok;
  String get cancel;
  String get save;
  String get delete;
  String get edit;
  String get add;
  String get search;
  String get refresh;
  String get close;
  String get done;
  String get back;
  String get next;
  String get previous;
  String get loading;
  String get error;
  String get success;
  String get retry;

  // Home Screen
  String get homeTitle;
  String get goodMorning;
  String get goodAfternoon;
  String get goodEvening;
  String get goodNight;
  String get todayDate;
  String get upcomingHolidays;
  String get upcomingEvents;
  String get noUpcomingEvents;
  String get quoteOfTheDay;
  String get wordOfTheDay;
  String get meaning;
  String get synonym;
  String get example;
  String get inDays;
  String get daysAgo;
  String get today;
  String get tomorrow;
  String get yesterday;

  // Drawer
  String get profile;
  String get about;
  String get helpSupport;
  String get settings;
  String get welcome;

  // Settings
  String get settingsTitle;
  String get language;
  String get theme;
  String get notifications;
  String get darkMode;
  String get lightMode;
  String get systemDefault;
  String get languageChanged;
  String get themeChanged;

  // Messages
  String get comingSoon;
  String get featureComingSoon;
  String get loadingData;
  String get failedToLoadData;
  String get noDataAvailable;

  // Days of week
  String get monday;
  String get tuesday;
  String get wednesday;
  String get thursday;
  String get friday;
  String get saturday;
  String get sunday;

  // Months (English Calendar)
  String get january;
  String get february;
  String get march;
  String get april;
  String get may;
  String get june;
  String get july;
  String get august;
  String get september;
  String get october;
  String get november;
  String get december;

  // Bangla Months
  String get boishakh;
  String get jyoishtho;
  String get asharh;
  String get srabon;
  String get bhadro;
  String get ashwin;
  String get kartik;
  String get ogrohayon;
  String get poush;
  String get magh;
  String get falgun;
  String get choitra;

  // Calculator
  String get calculatorTitle;
  String get fromDate;
  String get toDate;
  String get selectDate;
  String get selectFromDate;
  String get selectToDate;
  String get reset;
  String get copyResult;
  String get copiedToClipboard;
  String get invalidDateRange;
  String get selectDatesToSeeResults;
  String get calculationResults;
  String get yearsMonthsDays;
  String get totalDays;
  String get weeksAndDays;
  String get year;
  String get years;
  String get month;
  String get months;
  String get day;
  String get days;
  String get week;
  String get weeks;

  // ========================================
  // HELPER METHODS
  // ========================================

  /// Get month name by number (1-12)
  String getMonthName(int month) {
    switch (month) {
      case 1:
        return january;
      case 2:
        return february;
      case 3:
        return march;
      case 4:
        return april;
      case 5:
        return may;
      case 6:
        return june;
      case 7:
        return july;
      case 8:
        return august;
      case 9:
        return september;
      case 10:
        return october;
      case 11:
        return november;
      case 12:
        return december;
      default:
        return '';
    }
  }

  /// Get Bangla month name by number (1-12)
  String getBanglaMonthName(int month) {
    switch (month) {
      case 1:
        return boishakh;
      case 2:
        return jyoishtho;
      case 3:
        return asharh;
      case 4:
        return srabon;
      case 5:
        return bhadro;
      case 6:
        return ashwin;
      case 7:
        return kartik;
      case 8:
        return ogrohayon;
      case 9:
        return poush;
      case 10:
        return magh;
      case 11:
        return falgun;
      case 12:
        return choitra;
      default:
        return '';
    }
  }

  /// Get day of week name
  String getDayName(int day) {
    switch (day) {
      case 1:
        return monday;
      case 2:
        return tuesday;
      case 3:
        return wednesday;
      case 4:
        return thursday;
      case 5:
        return friday;
      case 6:
        return saturday;
      case 7:
        return sunday;
      default:
        return '';
    }
  }

  /// Format date to localized string
  ///
  /// Example:
  /// ```dart
  /// formatDate(DateTime(2025, 1, 5))
  /// // Bengali: "৫ জানুয়ারি ২০২৫"
  /// // English: "5 January 2025"
  /// ```
  String formatDate(DateTime date) {
    String day = localizeNumber(date.day);
    String month = getMonthName(date.month);
    String year = localizeNumber(date.year);
    return '$day $month $year';
  }

  /// Get greeting based on time
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return goodMorning;
    if (hour < 17) return goodAfternoon;
    if (hour < 21) return goodEvening;
    return goodNight;
  }
}

/// Localizations Delegate
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.isSupported(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations.load(locale)!;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
