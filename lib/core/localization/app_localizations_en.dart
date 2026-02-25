// lib/core/localization/app_localizations_en.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

/// English translations
class AppLocalizationsEn extends AppLocalizations {
  @override
  Locale get locale => const Locale('en', 'US');

  @override
  String translate(String key) {
    // Future: implement dynamic translation lookup
    return key;
  }

  // ========================================
  // APP INFO
  // ========================================

  @override
  String get appName => 'Ekush Ponji';

  @override
  String get appTitle => 'Ekush Ponji';

  @override
  String get welcomeToApp => 'Welcome to {appName}';

  // ========================================
  // NAVIGATION
  // ========================================

  @override
  String get navHome => 'Home';

  @override
  String get navCalendar => 'Calendar';


  @override
  String get navPrayerTimes => 'Prayer Times';

  @override
  String get navCalculator => 'Calculator';

  @override
  String get navSettings => 'Settings';

  // ========================================
  // COMMON ACTIONS
  // ========================================

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get refresh => 'Refresh';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get retry => 'Retry';

  // ========================================
  // HOME SCREEN
  // ========================================

  @override
  String get homeTitle => 'Home';

  @override
  String get goodMorning => 'Good Morning!';

  @override
  String get goodAfternoon => 'Good Afternoon!';

  @override
  String get goodEvening => 'Good Evening!';

  @override
  String get goodNight => 'Good Night!';

  @override
  String get todayDate => 'Today\'s Date';

  @override
  String get upcomingHolidays => 'Upcoming Holidays';

  @override
  String get upcomingEvents => 'Upcoming Events';

  @override
  String get noUpcomingEvents => 'No upcoming events';

  @override
  String get noUpcomingHolidays => 'No upcoming holidays';

  @override
  String get quoteOfTheDay => 'Quote of the Day';

  @override
  String get wordOfTheDay => 'Word of the Day';

  @override
  String get meaning => 'Meaning';

  @override
  String get synonym => 'Synonym';

  @override
  String get example => 'Example';

  @override
  String get inDays => 'In %d days';

  @override
  String get daysAgo => '%d days ago';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  // ========================================
  // DRAWER
  // ========================================

  @override
  String get profile => 'Profile';

  @override
  String get about => 'About';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get settings => 'Settings';

  @override
  String get welcome => 'Welcome!';

  // ========================================
  // SETTINGS
  // ========================================

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get notifications => 'Notifications';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemDefault => 'System Default';

  @override
  String get languageChanged => 'Language changed';

  @override
  String get themeChanged => 'Theme changed';

  @override
  String get notificationSubtitle => 'Enable notifications to receive updates about holidays and prayer times';

  @override
  String get dataAndStorage => 'Data & Storage';

  @override
  String get autoBackup => 'Auto Backup';

  @override
  String get autoBackupSubtitle => 'Automatically backup your data';

  @override
  String get deleteAllData => 'Clear All Data';

  @override
  String get deleteAllDataSubtitle => 'Reset app to default settings';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'Read our privacy policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get termsOfServiceSubtitle => 'Read our terms of service';

  @override
  String get appVersionSubtitle => 'App version and information';

  @override
  String get deleteAllDataConfirmMessage =>
    'This will reset all settings to their defaults and erase all stored data. '
    'This action cannot be undone.';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get resetSettingsConfirmMessage =>
    'This will reset all settings to their defaults. '
    'This action cannot be undone.';

  @override
  String get resetSettingsSubtitle => 'Reset all app settings to default values';

  // ========================================
  // MESSAGES
  // ========================================

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get featureComingSoon => 'This feature is coming soon';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get failedToLoadData => 'Failed to load data';

  @override
  String get noDataAvailable => 'No data available';

  // ========================================
  // CALENDAR
  // ========================================

  @override
  String get selectMonth => 'Select Month';

  @override
  String get selectYear => 'Select Year';

  @override
  String get calendarLegend => 'Legend';

  @override
  String get calendarHoliday => 'Holiday';

  @override
  String get calendarEvent => 'Event';

  @override
  String get calendarReminder => 'Reminder';

  @override
  String get sectionHolidays => 'Holidays';

  @override
  String get sectionEvents => 'Events';

  @override
  String get sectionReminders => 'Reminders';

  @override
  String get showDetails => 'Show Details';

  @override
  String get addEvent => 'Add Event';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get allDay => 'All day';

  @override
  String get passed => 'Passed';

  @override
  String formatUpcomingEventsInMonth(String monthName) =>
      'Upcoming Events in $monthName';

  @override
  String formatUpcomingHolidaysInMonth(String monthName) =>
      'Upcoming Holidays in $monthName';

  @override
  String get categoryWork => 'Work';

  @override
  String get categoryPersonal => 'Personal';

  @override
  String get categoryFamily => 'Family';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categorySocial => 'Social';

  @override
  String get categoryOther => 'Other';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String getMonthAbbreviation(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  // ========================================
  // DAYS OF WEEK
  // ========================================

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get shortSunday => 'Sun';

  @override
  String get shortMonday => 'Mon';

  @override
  String get shortTuesday => 'Tue';

  @override
  String get shortWednesday => 'Wed';

  @override
  String get shortThursday => 'Thu';

  @override
  String get shortFriday => 'Fri';

  @override
  String get shortSaturday => 'Sat';

  // ========================================
  // MONTHS (ENGLISH CALENDAR)
  // ========================================

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  // ========================================
  // BANGLA MONTHS
  // ========================================

  @override
  String get boishakh => 'Boishakh';

  @override
  String get jyoishtho => 'Jyoishtho';

  @override
  String get asharh => 'Asharh';

  @override
  String get srabon => 'Srabon';

  @override
  String get bhadro => 'Bhadro';

  @override
  String get ashwin => 'Ashwin';

  @override
  String get kartik => 'Kartik';

  @override
  String get ogrohayon => 'Ogrohayon';

  @override
  String get poush => 'Poush';

  @override
  String get magh => 'Magh';

  @override
  String get falgun => 'Falgun';

  @override
  String get choitra => 'Choitra';

  // ========================================
  // SEASONS
  // ========================================

  @override
  String get seasonGrishmo => 'Summer';

  @override
  String get seasonBorsha => 'Monsoon';

  @override
  String get seasonSharat => 'Autumn';

  @override
  String get seasonHemonto => 'Late Autumn';

  @override
  String get seasonSheet => 'Winter';

  @override
  String get seasonBosonto => 'Spring';

  @override
  String get seasonSpring => 'Spring';

  @override
  String get seasonSummer => 'Summer';

  @override
  String get seasonAutumn => 'Autumn';

  @override
  String get seasonWinter => 'Winter';

  // ========================================
  // CALCULATOR
  // ========================================

  @override
  String get calculatorTitle => 'Date Calculator';

  @override
  String get fromDate => 'From Date';

  @override
  String get toDate => 'To Date';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectFromDate => 'Select From Date';

  @override
  String get selectToDate => 'Select To Date';

  @override
  String get reset => 'Reset';

  @override
  String get copyResult => 'Copy';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get invalidDateRange => 'From date cannot be after To date';

  @override
  String get selectDatesToSeeResults => 'Select dates to see results';

  @override
  String get calculationResults => 'Calculation Results';

  @override
  String get yearsMonthsDays => 'Years Months Days';

  @override
  String get totalDays => 'Total Days';

  @override
  String get weeksAndDays => 'Weeks and Days';

  // ========================================
  // TIME UNITS
  // ========================================

  @override
  String get year => 'Year';

  @override
  String get years => 'Years';

  @override
  String get month => 'Month';

  @override
  String get months => 'Months';

  @override
  String get day => 'Day';

  @override
  String get days => 'Days';

  @override
  String get week => 'Week';

  @override
  String get weeks => 'Weeks';
}
