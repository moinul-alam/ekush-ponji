// lib/core/localization/app_localizations.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations_en.dart';
import 'package:ekush_ponji/core/localization/app_localizations_bn.dart';
import 'package:ekush_ponji/core/utils/string_formatter.dart';
import 'package:ekush_ponji/core/utils/number_converter.dart';

abstract class AppLocalizations {
  Locale get locale;
  String get languageCode => locale.languageCode;
  String translate(String key);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static AppLocalizations? load(Locale locale) {
    switch (locale.languageCode) {
      case 'bn':
        return AppLocalizationsBn();
      case 'en':
        return AppLocalizationsEn();
      default:
        return AppLocalizationsBn();
    }
  }

  static bool isSupported(Locale locale) {
    return ['bn', 'en'].contains(locale.languageCode);
  }

  // ═══════════════════════════════════════════════════════════
  // FORMATTING HELPERS
  // ═══════════════════════════════════════════════════════════

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

  String formatDaysDistance(int days) {
    if (days == 0) return today;
    if (days == 1) return tomorrow;
    if (days == -1) return yesterday;
    final daysStr = localizeNumber(days.abs());
    return days > 0
        ? formatNamed(inDays, {'count': daysStr})
        : formatNamed(daysAgo, {'count': daysStr});
  }

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

  String formatDate(DateTime date) {
    final d = localizeNumber(date.day);
    final m = getMonthName(date.month);
    final y = localizeNumber(date.year);
    return '$d $m $y';
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return goodMorning;
    if (hour < 17) return goodAfternoon;
    if (hour < 21) return goodEvening;
    return goodNight;
  }

  // ═══════════════════════════════════════════════════════════
  // APP INFO
  // ═══════════════════════════════════════════════════════════

  String get appName;
  String get appTitle;
  String get welcomeToApp;

  // ═══════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════

  String get navHome;
  String get navCalendar;
  String get navHolidays;
  String get navCalculator;
  String get navSettings;
  String get navMore;
  String get navAddEvent;
  String get navAddReminder;
  String get navCalculatorFull;
  String get navSavedQuotes;
  String get navSavedWords;
  String get navAbout;

  // ═══════════════════════════════════════════════════════════
  // COMMON ACTIONS
  // ═══════════════════════════════════════════════════════════

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
  String get confirm;
  String get reset;
  String get share;
  String get sync;

  // ═══════════════════════════════════════════════════════════
  // CALENDAR SYSTEM LABELS
  // ═══════════════════════════════════════════════════════════

  String get calendarShortGregorian;
  String get calendarShortBangla;
  String get calendarShortHijri;

  // ═══════════════════════════════════════════════════════════
  // MESSAGES
  // ═══════════════════════════════════════════════════════════

  String get comingSoon;
  String get featureComingSoon;
  String get loadingData;
  String get failedToLoadData;
  String get noDataAvailable;
  String get pageNotFound;
  String get goToHome;
  String get backToHome;

  // ═══════════════════════════════════════════════════════════
  // HOME SCREEN
  // ═══════════════════════════════════════════════════════════

  String get homeTitle;
  String get goodMorning;
  String get goodAfternoon;
  String get goodEvening;
  String get goodNight;
  String get todayDate;
  String get today;
  String get tomorrow;
  String get yesterday;
  String get inDays;
  String get daysAgo;
  String get upcomingHolidays;
  String get upcomingEvents;
  String get noUpcomingEvents;
  String get noUpcomingHolidays;
  String get quoteOfTheDay;
  String get wordOfTheDay;
  String get meaningEnglish;
  String get meaningBengali;
  String get synonym;
  String get example;
  String get todayIsDayName;
  String get dayDetails;

  // ═══════════════════════════════════════════════════════════
  // DRAWER
  // ═══════════════════════════════════════════════════════════

  String get welcome;
  String get profile;
  String get about;
  String get helpSupport;
  String get settings;

  // ═══════════════════════════════════════════════════════════
  // SETTINGS
  // ═══════════════════════════════════════════════════════════

  String get settingsTitle;
  String get appearance;
  String get language;
  String get languageBangla;
  String get languageEnglish;
  String get languageChanged;
  String get theme;
  String get lightMode;
  String get darkMode;
  String get systemDefault;
  String get themeChanged;
  String get appVersionSubtitle;
  String get privacyPolicy;
  String get privacyPolicySubtitle;
  String get termsOfService;
  String get termsOfServiceSubtitle;
  String get resetSettings;
  String get resetSettingsSubtitle;
  String get resetSettingsConfirmMessage;
  String get resetSettingsSuccessMessage;
  String get deleteAllData;
  String get deleteAllDataSubtitle;
  String get deleteAllDataConfirmMessage;
  String get deleteAllDataSuccessMessage;
  String get dataAndStorage;
  String get autoBackup;
  String get autoBackupSubtitle;

  // ═══════════════════════════════════════════════════════════
  // DATA SYNC
  // ═══════════════════════════════════════════════════════════

  String get dataUpdate;
  String get updateAllData;
  String get updateAllDataSubtitle;
  String get syncFailed;
  String get syncOffline;
  String get syncUpToDate;
  String syncUpdated(String list);
  String get syncDatasetHolidays;
  String get syncDatasetQuotes;
  String get syncDatasetWords;
  String get lastSynced;
  String get lastSyncedNever;
  String get lastSyncedJustNow;
  String lastSyncedMinutesAgo(int n);
  String lastSyncedHoursAgo(int n);
  String lastSyncedDaysAgo(int n);
  String get lastSyncedYesterday;
  String get lastSyncedUnknown;

  // ═══════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════

  String get notifications;
  String get notificationSubtitle;
  String get notificationsPermissionRequired;
  String get notificationPermissionTitle;
  String get notificationPermissionMessage;
  String get notificationPermissionDeniedBanner;
  String get openSettings;
  String get notificationsOn;
  String get notificationsOff;
  String get holidayNotifications;
  String get holidayNotificationsSubtitle;
  String get holidayNotificationsTitle;
  String get holidayNotifOnMessage;
  String get holidayNotifOffMessage;
  String get turnOn;
  String get turnOff;
  String get notNow;
  String get enable;
  String get quoteNotifications;
  String get quoteNotificationsSubtitle;
  String get wordNotifications;
  String get wordNotificationsSubtitle;

  // ═══════════════════════════════════════════════════════════
  // HOLIDAYS SCREEN
  // ═══════════════════════════════════════════════════════════

  String get allHolidays;
  String get noHolidaysForYear;
  String get byHolidayTypes;
  String get byMonth;
  String get showLess;
  String showMore(int count);

  // ═══════════════════════════════════════════════════════════
  // CALENDAR SCREEN
  // ═══════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════
  // EVENTS & REMINDERS
  // ═══════════════════════════════════════════════════════════

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
  String get deleteEvent;
  String get deleteEventConfirmMessage;
  String get deleteReminder;
  String get deleteReminderConfirmMessage;
  String get eventAddedSuccess;
  String get eventUpdatedSuccess;
  String get eventDeletedSuccess;
  String get reminderAddedSuccess;
  String get reminderUpdatedSuccess;
  String get reminderDeletedSuccess;
  String get allEvents;
  String get allReminders;

  // ═══════════════════════════════════════════════════════════
  // EVENT CATEGORIES
  // ═══════════════════════════════════════════════════════════

  String get categoryWork;
  String get categoryPersonal;
  String get categoryFamily;
  String get categoryHealth;
  String get categoryEducation;
  String get categorySocial;
  String get categoryOther;

  // ═══════════════════════════════════════════════════════════
  // REMINDER PRIORITY
  // ═══════════════════════════════════════════════════════════

  String get priority;
  String get priorityLow;
  String get priorityMedium;
  String get priorityHigh;
  String get priorityUrgent;

  // ═══════════════════════════════════════════════════════════
  // QUOTES & WORDS
  // ═══════════════════════════════════════════════════════════

  String get savedQuotes;
  String get savedWords;
  String get adjustFontSize;
  String get noSavedQuotes;
  String get noSavedWords;

  // ═══════════════════════════════════════════════════════════
  // CALCULATOR
  // ═══════════════════════════════════════════════════════════

  String get calculatorTitle;
  String get fromDate;
  String get toDate;
  String get selectDate;
  String get selectFromDate;
  String get selectToDate;
  String get copyResult;
  String get copiedToClipboard;
  String get invalidDateRange;
  String get selectDatesToSeeResults;
  String get calculationResults;
  String get yearsMonthsDays;
  String get totalDays;
  String get weeksAndDays;

  // ═══════════════════════════════════════════════════════════
  // TIME UNITS
  // ═══════════════════════════════════════════════════════════

  String get year;
  String get years;
  String get month;
  String get months;
  String get day;
  String get days;
  String get week;
  String get weeks;

  // ═══════════════════════════════════════════════════════════
  // DAYS OF WEEK
  // ═══════════════════════════════════════════════════════════

  String get monday;
  String get tuesday;
  String get wednesday;
  String get thursday;
  String get friday;
  String get saturday;
  String get sunday;
  String get shortSunday;
  String get shortMonday;
  String get shortTuesday;
  String get shortWednesday;
  String get shortThursday;
  String get shortFriday;
  String get shortSaturday;

  // ═══════════════════════════════════════════════════════════
  // MONTHS — GREGORIAN
  // ═══════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════
  // MONTHS — BENGALI
  // ═══════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════
  // SEASONS
  // ═══════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════

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

  String getMonthAbbreviation(int month) {
    final name = getMonthName(month);
    if (name.isEmpty) return '';
    if (name.length <= 4) return name;
    return name.substring(0, 4);
  }

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

  String getBengaliSeasonName(int monthNumber) {
    if (monthNumber >= 1 && monthNumber <= 2) return seasonGrishmo;
    if (monthNumber >= 3 && monthNumber <= 4) return seasonBorsha;
    if (monthNumber >= 5 && monthNumber <= 6) return seasonSharat;
    if (monthNumber >= 7 && monthNumber <= 8) return seasonHemonto;
    if (monthNumber >= 9 && monthNumber <= 10) return seasonSheet;
    return seasonBosonto;
  }

  String getGregorianSeasonName(int bengaliMonthNumber) {
    if (bengaliMonthNumber >= 1 && bengaliMonthNumber <= 2) return 'Summer';
    if (bengaliMonthNumber >= 3 && bengaliMonthNumber <= 4)
      return 'Rainy Season';
    if (bengaliMonthNumber >= 5 && bengaliMonthNumber <= 6) return 'Autumn';
    if (bengaliMonthNumber >= 7 && bengaliMonthNumber <= 8)
      return 'Late Autumn';
    if (bengaliMonthNumber >= 9 && bengaliMonthNumber <= 10) return 'Winter';
    return 'Spring';
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations.load(locale)!;

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
