// lib/core/localization/app_localizations_en.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  @override
  Locale get locale => const Locale('en', 'US');

  @override
  String translate(String key) => key;

  // ═══════════════════════════════════════════════════════════
  // APP INFO
  // ═══════════════════════════════════════════════════════════

  @override
  String get appName => 'Ekush Ponji';

  @override
  String get appTitle => 'Ekush Ponji';

  @override
  String get welcomeToApp => 'Welcome to {appName}';

  // ═══════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════

  @override
  String get navHome => 'Home';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navHolidays => 'Holidays';

  @override
  String get navCalculator => 'Calculator';

  @override
  String get navSettings => 'Settings';

  @override
  String get navMore => 'More';

  @override
  String get navAddEvent => 'Add Event';

  @override
  String get navAddReminder => 'Add Reminder';

  @override
  String get navCalculatorFull => 'Calculator';

  @override
  String get navSavedQuotes => 'Saved Quotes';

  @override
  String get navSavedWords => 'Saved Words';

  @override
  String get navAbout => 'About';

  // ═══════════════════════════════════════════════════════════
  // COMMON ACTIONS
  // ═══════════════════════════════════════════════════════════

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

  @override
  String get confirm => 'Confirm';

  @override
  String get reset => 'Reset';

  @override
  String get share => 'Share';

  @override
  String get sync => 'Sync';

  // ═══════════════════════════════════════════════════════════
  // CALENDAR SYSTEM LABELS
  // ═══════════════════════════════════════════════════════════

  @override
  String get calendarShortGregorian => 'AD';

  @override
  String get calendarShortBangla => 'BS';

  @override
  String get calendarShortHijri => 'AH';

  // ═══════════════════════════════════════════════════════════
  // MESSAGES
  // ═══════════════════════════════════════════════════════════

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get featureComingSoon => 'This feature is coming soon';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get failedToLoadData => 'Failed to load data';

  @override
  String get noDataAvailable => 'No events or reminders added yet';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get goToHome => 'Go to Home';

  @override
  String get backToHome => 'Back to Home';

  // ═══════════════════════════════════════════════════════════
  // HOME SCREEN
  // ═══════════════════════════════════════════════════════════

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
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get inDays => 'In {count} days';

  @override
  String get daysAgo => '{count} days ago';

  @override
  String get upcomingHolidays => 'Upcoming Holidays';

  @override
  String get upcomingEvents => 'Upcoming Events';

  @override
  String get noUpcomingEvents => 'No upcoming events';

  @override
  String get noUpcomingHolidays => 'No upcoming holidays in this month';

  @override
  String get quoteOfTheDay => 'Quote of the Day';

  @override
  String get wordOfTheDay => 'Word of the Day';

  @override
  String get meaningEnglish => 'Meaning in English';

  @override
  String get meaningBengali => 'Meaning in Bengali';

  @override
  String get synonym => 'Synonym';

  @override
  String get example => 'Example';

  @override
  String get todayIsDayName => 'Today is';

  @override
  String get dayDetails => 'Day Details';

  // ═══════════════════════════════════════════════════════════
  // DRAWER
  // ═══════════════════════════════════════════════════════════

  @override
  String get welcome => 'Welcome!';

  @override
  String get profile => 'Profile';

  @override
  String get about => 'About';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get settings => 'Settings';

  // ═══════════════════════════════════════════════════════════
  // SETTINGS
  // ═══════════════════════════════════════════════════════════

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get languageBangla => 'Bangla';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChanged => 'Language changed';

  @override
  String get theme => 'Theme';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get systemDefault => 'System Default';

  @override
  String get themeChanged => 'Theme changed';

  @override
  String get appVersionSubtitle => 'App version and information';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'Read our privacy policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get termsOfServiceSubtitle => 'Read our terms of service';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get resetSettingsSubtitle =>
      'Reset all app settings to default values';

  @override
  String get resetSettingsConfirmMessage =>
      'This will reset all settings to their defaults. '
      'This action cannot be undone.';

  @override
  String get resetSettingsSuccessMessage => 'Settings reset successfully';

  @override
  String get deleteAllData => 'Clear All Data';

  @override
  String get deleteAllDataSubtitle => 'Reset app to default settings';

  @override
  String get deleteAllDataConfirmMessage =>
      'This will reset all settings to their defaults and erase all stored data. '
      'This action cannot be undone.';

  @override
  String get deleteAllDataSuccessMessage => 'All data cleared successfully';

  @override
  String get dataAndStorage => 'Data & Storage';

  @override
  String get autoBackup => 'Auto Backup';

  @override
  String get autoBackupSubtitle => 'Automatically backup your data';

  // ═══════════════════════════════════════════════════════════
  // DATA SYNC
  // ═══════════════════════════════════════════════════════════

  @override
  String get dataUpdate => 'Data Update';

  @override
  String get updateAllData => 'Update All Data';

  @override
  String get updateAllDataSubtitle => 'Holidays, quotes & words';

  @override
  String get syncFailed => 'Sync failed — check your connection';

  @override
  String get syncOffline => 'Offline — using local data';

  @override
  String get syncUpToDate => 'Everything is up to date';

  @override
  String syncUpdated(String list) => '$list updated';

  @override
  String get syncDatasetHolidays => 'Holidays';

  @override
  String get syncDatasetQuotes => 'Quotes';

  @override
  String get syncDatasetWords => 'Words';

  @override
  String get lastSynced => 'Last synced: ';

  @override
  String get lastSyncedNever => 'Never';

  @override
  String get lastSyncedJustNow => 'Just now';

  @override
  String lastSyncedMinutesAgo(int n) => '$n minutes ago';

  @override
  String lastSyncedHoursAgo(int n) => '$n hours ago';

  @override
  String lastSyncedDaysAgo(int n) => '$n days ago';

  @override
  String get lastSyncedYesterday => 'Yesterday';

  @override
  String get lastSyncedUnknown => 'Unknown';

  // ═══════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSubtitle => 'Enable notifications to receive updates';

  @override
  String get notificationsPermissionRequired =>
      'Please allow notification permission';

  @override
  String get notificationPermissionTitle => 'Notification Permission';

  @override
  String get notificationPermissionMessage =>
      'Notification permission is required. Please enable it in Settings.';

  @override
  String get notificationPermissionDeniedBanner =>
      'Notification permission denied. Toggles below won\'t work.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get notificationsOn => 'Notifications on';

  @override
  String get notificationsOff => 'Notifications off';

  @override
  String get holidayNotifications => 'Holiday Notifications';

  @override
  String get holidayNotificationsSubtitle =>
      'Turn holiday notifications on/off';

  @override
  String get holidayNotificationsTitle => 'Holiday Notifications';

  @override
  String get holidayNotifOnMessage =>
      'You\'re receiving morning notifications for holidays. Turn off?';

  @override
  String get holidayNotifOffMessage =>
      'Holiday notifications are off. Turn on?';

  @override
  String get turnOn => 'Turn On';

  @override
  String get turnOff => 'Turn Off';

  @override
  String get enable => 'Enable';

  @override
  String get notNow => 'Not Now';

  @override
  String get quoteNotifications => 'Daily Quote';

  @override
  String get quoteNotificationsSubtitle =>
      'Enable notification to get new quotes every morning';

  @override
  String get wordNotifications => 'Word of the Day';

  @override
  String get wordNotificationsSubtitle =>
      'Enable notification to learn new words every morning';

  // ═══════════════════════════════════════════════════════════
  // HOLIDAYS SCREEN
  // ═══════════════════════════════════════════════════════════

  @override
  String get allHolidays => 'All Holidays';

  @override
  String get noHolidaysForYear => 'No holidays found for this year';

  @override
  String get byHolidayTypes => 'By Holiday Types';

  @override
  String get byMonth => 'By Month';

  @override
  String get showLess => 'Show less';

  @override
  String showMore(int count) => 'Show $count more';

  // ═══════════════════════════════════════════════════════════
  // CALENDAR SCREEN
  // ═══════════════════════════════════════════════════════════

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
  String get editEvent => 'Edit Event';

  @override
  String get editReminder => 'Edit Reminder';

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

  // ═══════════════════════════════════════════════════════════
  // EVENTS & REMINDERS
  // ═══════════════════════════════════════════════════════════

  @override
  String get eventTitle => 'Event Title';

  @override
  String get eventSubtitle => 'Add an event for this day';

  @override
  String get reminderTitle => 'Reminder Title';

  @override
  String get reminderSubtitle => 'Set a reminder for this event';

  @override
  String get location => 'Location';

  @override
  String get locationSubtitle => 'Where is the event taking place?';

  @override
  String get description => 'Description';

  @override
  String get descriptionSubtitle => 'Add more details about the event';

  @override
  String get notes => 'Notes';

  @override
  String get notesSubtitle => 'Additional notes or comments about the event';

  @override
  String get deleteEvent => 'Delete Event';

  @override
  String get deleteEventConfirmMessage =>
      'Are you sure you want to delete this event?';

  @override
  String get deleteReminder => 'Delete Reminder';

  @override
  String get deleteReminderConfirmMessage =>
      'Are you sure you want to delete this reminder?';

  @override
  String get eventAddedSuccess => 'Event added successfully';

  @override
  String get eventUpdatedSuccess => 'Event updated successfully';

  @override
  String get eventDeletedSuccess => 'Event deleted successfully';

  @override
  String get reminderAddedSuccess => 'Reminder added successfully';

  @override
  String get reminderUpdatedSuccess => 'Reminder updated successfully';

  @override
  String get reminderDeletedSuccess => 'Reminder deleted successfully';

  @override
  String get allEvents => 'All Events';

  @override
  String get allReminders => 'All Reminders';

  // ═══════════════════════════════════════════════════════════
  // EVENT CATEGORIES
  // ═══════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════
  // REMINDER PRIORITY
  // ═══════════════════════════════════════════════════════════

  @override
  String get priority => 'Priority';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityUrgent => 'Urgent';

  // ═══════════════════════════════════════════════════════════
  // QUOTES & WORDS
  // ═══════════════════════════════════════════════════════════

  @override
  String get savedQuotes => 'Saved Quotes';

  @override
  String get savedWords => 'Saved Words';

  @override
  String get noSavedQuotes => 'No Saved Quotes Yet';

  @override
  String get noSavedWords => 'No Saved Words Yet';

  @override
  String get adjustFontSize => 'Adjust font size';

  // ═══════════════════════════════════════════════════════════
  // CALCULATOR
  // ═══════════════════════════════════════════════════════════

  @override
  String get calculatorTitle => 'Age Calculator';

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

  // ═══════════════════════════════════════════════════════════
  // TIME UNITS
  // ═══════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════
  // DAYS OF WEEK
  // ═══════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════
  // MONTHS — GREGORIAN
  // ═══════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════
  // MONTHS — BENGALI
  // ═══════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════
  // SEASONS
  // ═══════════════════════════════════════════════════════════

  @override
  String get seasonGrishmo => 'Summer';

  @override
  String get seasonBorsha => 'Rainy Season';

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

  // ═══════════════════════════════════════════════════════════
  // MONTH ABBREVIATIONS (override base)
  // ═══════════════════════════════════════════════════════════

  @override
  String getMonthAbbreviation(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }
}
