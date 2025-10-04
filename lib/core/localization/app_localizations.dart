import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations_en.dart';
import 'package:ekush_ponji/core/localization/app_localizations_bn.dart';

/// Base class for app localizations
/// Provides translation methods and language-specific functionality
abstract class AppLocalizations {
  /// Get the current locale
  Locale get locale;

  /// Get translation by key
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

  // Common translations that all implementations must provide
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
  String get today;
  String get tomorrow;

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

  // Months
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

  // Calculator (NEW)
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
