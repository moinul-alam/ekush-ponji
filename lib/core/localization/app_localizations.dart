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

  String format(String template, List<dynamic> args) {
    return StringFormatter.formatString(
      template,
      args,
      languageCode: languageCode,
    );
  }

  String formatNamed(String template, Map<String, dynamic> args) {
    return StringFormatter.formatNamed(
      template,
      args,
      languageCode: languageCode,
    );
  }

  
  String localizeNumber(dynamic number) {
    return NumberConverter.convertToLocale(number, languageCode);
  }


  String formatNumber(int number) {
    return NumberConverter.formatWithSeparator(number, languageCode);
  }

  
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
      return formatNamed(
        inDays,
        {'count': daysStr},
      );
    } else {
      return formatNamed(
        daysAgo,
        {'count': daysStr},
      );
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
  String get welcomeToApp;

  // Navigation
  String get navHome;
  String get navCalendar;
  String get navPrayerTimes;
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
  String get noUpcomingHolidays;
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
  String get eventTitle;
  String get eventSubtitle;
  String get reminderTitle;
  String get reminderSubtitle;
  String get location;
  String get locationSubtitle;
  String get description;
  String get descriptionSubtitle;
  String get notes;
  String get notesSubtitle;
  String get savedQuotes; 
  String get savedWords;
  String get share;
  String get adjustFontSize;
  String get notificationsPermissionRequired;


  // Drawer
  String get profile;
  String get about;
  String get helpSupport;
  String get settings;
  String get welcome;
  String get allHolidays;


  // Settings
  String get settingsTitle;
  String get appearance;
  String get language;
  String get theme;
  String get notifications;
  String get darkMode;
  String get lightMode;
  String get systemDefault;
  String get languageChanged;
  String get themeChanged;
  String get notificationSubtitle;
  String get dataAndStorage;
  String get autoBackup;
  String get autoBackupSubtitle;
  String get deleteAllData;
  String get deleteAllDataSubtitle;
  String get appVersionSubtitle;
  String get privacyPolicy;
  String get privacyPolicySubtitle;
  String get termsOfService;
  String get termsOfServiceSubtitle;
  String get deleteAllDataConfirmMessage;
  String get resetSettings;
  String get resetSettingsConfirmMessage;
  String get resetSettingsSubtitle;
  String get languageBangla;
  String get languageEnglish;
  String get pageNotFound;
  String get goToHome;
  String get backToHome;
  String get deleteEvent;
  String get deleteReminder;
  String get confirm;

  // Calendar Types
  String get calendarShortGregorian;
  String get calendarShortBangla;
  String get calendarShortHijri;

  // Messages
  String get comingSoon;
  String get featureComingSoon;
  String get loadingData;
  String get failedToLoadData;
  String get noDataAvailable;

  // Calendar
  String get selectMonth;
  String get selectYear;
  String get calendarLegend;
  String get calendarHoliday;
  String get calendarEvent;
  String get calendarReminder;
  String get sectionHolidays;
  String get sectionEvents;
  String get sectionReminders;
  String get showDetails;
  String get addEvent;
  String get addReminder;
  String get editEvent;
  String get editReminder;
  String get allDay;
  String get passed;
  String formatUpcomingEventsInMonth(String monthName);
  String formatUpcomingHolidaysInMonth(String monthName);

  // GPS
  String get updateLocation;
  String get detectingLocation;
  String get updatingLocation;
  String get calculatingPrayerTimes;
  String get localtionServicesDisabled;
  String get locationPermissionRequired;
  String get locationPermissionDenied;
  String get enableLocationServicesForPrayerTimes;
  String get localtionServiceRequiredForPrayerTimes;
  String get locationServiceUsageForPrayerTimes;
  String get openSettings;
  String get getPrayerTimes;
  String get prayerSettingsTitle;
  String get prayerCalculationMethod;
  String get prayerMadhab;
  String get prayerMadhabHanafi;
  String get prayerMadhabShafii;
  String get prayerNotificationsTitle;
  String get prayerEnableNotifications;
  String get prayerNotificationsSubtitle;
  String get prayerPerPrayerTitle;
  String get prayerNotifyBeforeTitle;
  String get prayerNotifyOnTime;
  String get prayerNotifyMinutesBefore;
  String get prayerSectionSun;
  String get prayerSectionPrayers;
  String get sunrise;
  String get sunset;
  String get currentPrayer;
  String get nextPrayer;
  String get remainingTime;
  String get prayerSectionForbiddenTimes;
  String get forbiddenTimeSunrise;
  String get forbiddenTimeZenith;
  String get forbiddenTimeSunset;
  String get allPrayersCompletedToday;
  String get dayProgressTitle;

  // Event categories (for calendar event labels)
  String get categoryWork;
  String get categoryPersonal;
  String get categoryFamily;
  String get categoryHealth;
  String get categoryEducation;
  String get categorySocial;
  String get categoryOther;

  // Reminder priority
  String get priorityLow;
  String get priorityMedium;
  String get priorityHigh;
  String get priorityUrgent;
  String get priority;

  // Days of week
  String get monday;
  String get tuesday;
  String get wednesday;
  String get thursday;
  String get friday;
  String get saturday;
  String get sunday;

  // Short day names for calendar header (Sun, Mon, ... / রবি, সোম, ...)
  String get shortSunday;
  String get shortMonday;
  String get shortTuesday;
  String get shortWednesday;
  String get shortThursday;
  String get shortFriday;
  String get shortSaturday;

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

  // Seasons (Bengali calendar + Gregorian)
  String get seasonGrishmo;
  String get seasonBorsha;
  String get seasonSharat;
  String get seasonHemonto;
  String get seasonSheet;
  String get seasonBosonto;
  String get seasonSpring;
  String get seasonSummer;
  String get seasonAutumn;
  String get seasonWinter;

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

  /// Get abbreviated month name (for date badges in lists)
  String getMonthAbbreviation(int month) {
    final name = getMonthName(month);
    if (name.isEmpty) return '';
    if (name.length <= 4) return name;
    return name.substring(0, 4);
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

  /// Bengali calendar season name (Ritu) by month number 1-12
  String getBengaliSeasonName(int monthNumber) {
    if (monthNumber >= 1 && monthNumber <= 2) return seasonGrishmo;
    if (monthNumber >= 3 && monthNumber <= 4) return seasonBorsha;
    if (monthNumber >= 5 && monthNumber <= 6) return seasonSharat;
    if (monthNumber >= 7 && monthNumber <= 8) return seasonHemonto;
    if (monthNumber >= 9 && monthNumber <= 10) return seasonSheet;
    return seasonBosonto;
  }

  /// Gregorian season name by month 1-12
  String getGregorianSeasonName(int month) {
    if (month >= 3 && month <= 5) return seasonSpring;
    if (month >= 6 && month <= 8) return seasonSummer;
    if (month >= 9 && month <= 11) return seasonAutumn;
    return seasonWinter;
  }

  
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
