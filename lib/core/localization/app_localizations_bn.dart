// lib/core/localization/app_localizations_bn.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

class AppLocalizationsBn extends AppLocalizations {
  @override
  Locale get locale => const Locale('bn', 'BD');

  @override
  String translate(String key) => key;

  // ═══════════════════════════════════════════════════════════
  // APP INFO
  // ═══════════════════════════════════════════════════════════

  @override
  String get appName => 'একুশ পঞ্জি';

  @override
  String get appTitle => 'একুশ পঞ্জি';

  @override
  String get welcomeToApp => '{appName}তে আপনাকে স্বাগতম';

  // ═══════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════

  @override
  String get navHome => 'হোম';

  @override
  String get navCalendar => 'ক্যালেন্ডার';

  @override
  String get navHolidays => 'ছুটি';

  @override
  String get navCalculator => 'ক্যালকুলেটর';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get navMore => 'আরও';

  @override
  String get navAddEvent => 'ইভেন্ট যোগ করুন';

  @override
  String get navAddReminder => 'রিমাইন্ডার যোগ করুন';

  @override
  String get navCalculatorFull => 'ক্যালকুলেটর';

  @override
  String get navSavedQuotes => 'সংরক্ষিত উক্তি';

  @override
  String get navSavedWords => 'সংরক্ষিত শব্দ';

  @override
  String get navAbout => 'আমাদের সম্পর্কে';

  // ═══════════════════════════════════════════════════════════
  // COMMON ACTIONS
  // ═══════════════════════════════════════════════════════════

  @override
  String get ok => 'ঠিক আছে';

  @override
  String get cancel => 'বাতিল';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get delete => 'মুছুন';

  @override
  String get edit => 'সম্পাদনা';

  @override
  String get add => 'যোগ করুন';

  @override
  String get search => 'খুঁজুন';

  @override
  String get refresh => 'রিফ্রেশ';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get done => 'সম্পন্ন';

  @override
  String get back => 'পিছনে';

  @override
  String get next => 'পরবর্তী';

  @override
  String get previous => 'পূর্ববর্তী';

  @override
  String get loading => 'লোড হচ্ছে...';

  @override
  String get error => 'ত্রুটি';

  @override
  String get success => 'সফল';

  @override
  String get retry => 'পুনরায় চেষ্টা করুন';

  @override
  String get confirm => 'নিশ্চিত করুন';

  @override
  String get reset => 'রিসেট';

  @override
  String get share => 'শেয়ার';

  @override
  String get sync => 'আপডেট';

  // ═══════════════════════════════════════════════════════════
  // CALENDAR SYSTEM LABELS
  // ═══════════════════════════════════════════════════════════

  @override
  String get calendarShortGregorian => 'খ্রিস্টাব্দ';

  @override
  String get calendarShortBangla => 'বঙ্গাব্দ';

  @override
  String get calendarShortHijri => 'হিজরি';

  // ═══════════════════════════════════════════════════════════
  // MESSAGES
  // ═══════════════════════════════════════════════════════════

  @override
  String get comingSoon => 'শীঘ্রই আসছে';

  @override
  String get featureComingSoon => 'এই ফিচারটি শীঘ্রই আসছে';

  @override
  String get loadingData => 'ডেটা লোড হচ্ছে...';

  @override
  String get failedToLoadData => 'ডেটা লোড করতে ব্যর্থ';

  @override
  String get noDataAvailable => 'কোন ইভেন্ট বা রিমাইন্ডার যোগ করা হয়নি';

  @override
  String get pageNotFound => 'পাতা খুঁজে পাওয়া যায়নি';

  @override
  String get goToHome => 'হোমে যান';

  @override
  String get backToHome => 'হোমে ফিরে যান';

  // ═══════════════════════════════════════════════════════════
  // HOME SCREEN
  // ═══════════════════════════════════════════════════════════

  @override
  String get homeTitle => 'হোম';

  @override
  String get goodMorning => 'সুপ্রভাত!';

  @override
  String get goodAfternoon => 'শুভ অপরাহ্ন!';

  @override
  String get goodEvening => 'শুভ সন্ধ্যা!';

  @override
  String get goodNight => 'শুভ রাত্রি!';

  @override
  String get todayDate => 'আজকের তারিখ';

  @override
  String get today => 'আজ';

  @override
  String get tomorrow => 'আগামীকাল';

  @override
  String get yesterday => 'গতকাল';

  @override
  String get inDays => '{count} দিন পর';

  @override
  String get daysAgo => '{count} দিন আগে';

  @override
  String get upcomingHolidays => 'আসন্ন ছুটির দিন';

  @override
  String get upcomingEvents => 'আসন্ন ইভেন্ট';

  @override
  String get noUpcomingEvents => 'কোন আসন্ন ইভেন্ট নেই';

  @override
  String get noUpcomingHolidays => 'এই মাসে কোন আসন্ন ছুটির দিন নেই';

  @override
  String get quoteOfTheDay => 'আজকের উক্তি';

  @override
  String get wordOfTheDay => 'আজকের শব্দ';

  @override
  String get meaningEnglish => 'ইংরেজি অর্থ';

  @override
  String get meaningBengali => 'বাংলা অর্থ';

  @override
  String get synonym => 'সমার্থক শব্দ';

  @override
  String get example => 'উদাহরণ';

  @override
  String get todayIsDayName => 'আজ';

  @override
  String get dayDetails => 'দিনের বিবরণ';

  // ═══════════════════════════════════════════════════════════
  // DRAWER
  // ═══════════════════════════════════════════════════════════

  @override
  String get welcome => 'স্বাগতম!';

  @override
  String get profile => 'প্রোফাইল';

  @override
  String get about => 'আমাদের সম্পর্কে';

  @override
  String get helpSupport => 'সাহায্য এবং সহায়তা';

  @override
  String get settings => 'সেটিংস';

  // ═══════════════════════════════════════════════════════════
  // SETTINGS
  // ═══════════════════════════════════════════════════════════

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get appearance => 'এপিয়ারেন্স';

  @override
  String get language => 'ভাষা';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get languageEnglish => 'ইংরেজি';

  @override
  String get languageChanged => 'ভাষা পরিবর্তিত হয়েছে';

  @override
  String get theme => 'থিম';

  @override
  String get lightMode => 'লাইট মোড';

  @override
  String get darkMode => 'ডার্ক মোড';

  @override
  String get systemDefault => 'সিস্টেম ডিফল্ট';

  @override
  String get themeChanged => 'থিম পরিবর্তিত হয়েছে';

  @override
  String get appVersionSubtitle => 'অ্যাপ ভার্সন এবং তথ্য';

  @override
  String get privacyPolicy => 'গোপনীয়তা নীতি';

  @override
  String get privacyPolicySubtitle => 'আমাদের গোপনীয়তা নীতি পড়ুন';

  @override
  String get termsOfService => 'সার্ভিসের শর্তাবলী';

  @override
  String get termsOfServiceSubtitle => 'আমাদের সার্ভিসের শর্তাবলী পড়ুন';

  @override
  String get resetSettings => 'রিসেট সেটিংস';

  @override
  String get resetSettingsSubtitle => 'অ্যাপের সকল সেটিংস ডিফল্টে রিসেট করুন';

  @override
  String get resetSettingsConfirmMessage =>
      'এটি সমস্ত সেটিংস ডিফল্টে ফিরিয়ে দেবে। '
      'এই কাজটি পূর্বাবস্থায় ফেরানো যাবে না।';

  @override
  String get resetSettingsSuccessMessage => 'সেটিংস সফলভাবে রিসেট হয়েছে';

  @override
  String get deleteAllData => 'সকল তথ্য রিসেট';

  @override
  String get deleteAllDataSubtitle =>
      'অ্যাপে সংরক্ষিত সকল তথ্য এবং সেটিংস মুছে ফেলুন';

  @override
  String get deleteAllDataConfirmMessage =>
      'এটি সমস্ত সেটিংস ডিফল্টে ফিরিয়ে দেবে এবং সংরক্ষিত সব ডেটা মুছে ফেলবে। '
      'এই কাজটি পূর্বাবস্থায় ফেরানো যাবে না।';

  @override
  String get deleteAllDataSuccessMessage => 'সব ডেটা সফলভাবে মুছে ফেলা হয়েছে';

  @override
  String get dataAndStorage => 'ডেটা এবং স্টোরেজ';

  @override
  String get autoBackup => 'অটো ব্যাকআপ';

  @override
  String get autoBackupSubtitle => 'আপনার ডেটা স্বয়ংক্রিয়ভাবে ব্যাকআপ করুন';

  // ═══════════════════════════════════════════════════════════
  // DATA SYNC
  // ═══════════════════════════════════════════════════════════

  @override
  String get dataUpdate => 'ডেটা আপডেট';

  @override
  String get updateAllData => 'সব ডেটা আপডেট করুন';

  @override
  String get updateAllDataSubtitle => 'ছুটির তালিকা, উদ্ধৃতি ও শব্দ';

  @override
  String get syncFailed => 'সিঙ্ক ব্যর্থ — ইন্টারনেট সংযোগ পরীক্ষা করুন';

  @override
  String get syncOffline => 'অফলাইন — স্থানীয় ডেটা ব্যবহার করা হচ্ছে';

  @override
  String get syncUpToDate => 'সব কিছু আপডেট আছে';

  @override
  String syncUpdated(String list) => '$list আপডেট হয়েছে';

  @override
  String get syncDatasetHolidays => 'ছুটির তালিকা';

  @override
  String get syncDatasetQuotes => 'উদ্ধৃতি';

  @override
  String get syncDatasetWords => 'শব্দ';

  @override
  String get lastSynced => 'সর্বশেষ আপডেট: ';

  @override
  String get lastSyncedNever => 'কখনো আপডেট করা হয়নি';

  @override
  String get lastSyncedJustNow => 'এইমাত্র';

  @override
  String lastSyncedMinutesAgo(int n) => '${localizeNumber(n)} মিনিট আগে';

  @override
  String lastSyncedHoursAgo(int n) => '${localizeNumber(n)} ঘণ্টা আগে';

  @override
  String lastSyncedDaysAgo(int n) => '${localizeNumber(n)} দিন আগে';

  @override
  String get lastSyncedYesterday => 'গতকাল';

  @override
  String get lastSyncedUnknown => 'অজানা';

  // ═══════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════

  @override
  String get notifications => 'নোটিফিকেশন';

  @override
  String get notificationSubtitle => 'নোটিফিকেশন পেতে এনাবল করুন';

  @override
  String get notificationsPermissionRequired =>
      'চালু করতে নোটিফিকেশন অনুমতি দিন।';

  @override
  String get notificationPermissionTitle => 'নোটিফিকেশন অনুমতি';

  @override
  String get notificationPermissionMessage =>
      'নোটিফিকেশন পাঠাতে অনুমতি প্রয়োজন।';

  @override
  String get notificationPermissionDeniedBanner =>
      'নোটিফিকেশন অনুমতি নেই। নিচের টগলগুলো কাজ করবে না।';

  @override
  String get openSettings => 'সেটিংস খুলুন';

  @override
  String get notificationsOn => 'নোটিফিকেশন চালু আছে';

  @override
  String get notificationsOff => 'নোটিফিকেশন বন্ধ আছে';

  @override
  String get holidayNotifications => 'ছুটির দিনের নোটিফিকেশন';

  @override
  String get holidayNotificationsSubtitle =>
      'ছুটির দিনের নোটিফিকেশন চালু/বন্ধ করুন';

  @override
  String get holidayNotificationsTitle => 'ছুটির নোটিফিকেশন';

  @override
  String get holidayNotifOnMessage =>
      'ছুটির নোটিফিকেশন চালু আছে, বন্ধ করতে চান?';

  @override
  String get holidayNotifOffMessage =>
      'ছুটির নোটিফিকেশন বন্ধ আছে, চালু করতে চান?';

  @override
  String get turnOn => 'চালু করুন';

  @override
  String get turnOff => 'বন্ধ করুন';

  @override
  String get enable => 'চালু করুন';

  @override
  String get notNow => 'এখন নয়';

  @override
  String get quoteNotifications => 'দৈনিক উক্তি';

  @override
  String get quoteNotificationsSubtitle =>
      'প্রতিদিন নতুন নতুন উক্তি পেতে নোটিফিকেশন চালু করুন';

  @override
  String get wordNotifications => 'আজকের শব্দ';

  @override
  String get wordNotificationsSubtitle =>
      'প্রতিদিন সকালে নতুন শব্দ শিখতে নোটিফিকেশন চালু করুন';

  // ═══════════════════════════════════════════════════════════
  // HOLIDAYS SCREEN
  // ═══════════════════════════════════════════════════════════

  @override
  String get allHolidays => 'সকল ছুটির দিন';

  @override
  String get noHolidaysForYear => 'এই বছরে কোনো ছুটির তথ্য পাওয়া যায়নি';

  @override
  String get byHolidayTypes => 'ছুটির ধরণভিত্তিক তালিকা';

  @override
  String get byMonth => 'মাসভিত্তিক ছুটির তালিকা';

  @override
  String get showLess => 'কম দেখুন';

  @override
  String showMore(int count) => 'আরও ${localizeNumber(count)}টি দেখাও';

  // ═══════════════════════════════════════════════════════════
  // CALENDAR SCREEN
  // ═══════════════════════════════════════════════════════════

  @override
  String get selectMonth => 'মাস নির্বাচন করুন';

  @override
  String get selectYear => 'বছর নির্বাচন করুন';

  @override
  String get calendarLegend => 'চিহ্নের অর্থ';

  @override
  String get calendarHoliday => 'ছুটি';

  @override
  String get calendarEvent => 'ইভেন্ট';

  @override
  String get calendarReminder => 'রিমাইন্ডার';

  @override
  String get sectionHolidays => 'ছুটির দিন';

  @override
  String get sectionEvents => 'ইভেন্ট';

  @override
  String get sectionReminders => 'রিমাইন্ডার';

  @override
  String get showDetails => 'বিস্তারিত দেখুন';

  @override
  String get addEvent => 'ইভেন্ট যোগ করুন';

  @override
  String get addReminder => 'রিমাইন্ডার যোগ করুন';

  @override
  String get editEvent => 'এডিট ইভেন্ট';

  @override
  String get editReminder => 'এডিট রিমাইন্ডার';

  @override
  String get allDay => 'সারাদিন';

  @override
  String get passed => 'গত';

  @override
  String formatUpcomingEventsInMonth(String monthName) =>
      '$monthName মাসে আসন্ন ইভেন্ট';

  @override
  String formatUpcomingHolidaysInMonth(String monthName) =>
      '$monthName মাসে আসন্ন ছুটি';

  // ═══════════════════════════════════════════════════════════
  // EVENTS & REMINDERS
  // ═══════════════════════════════════════════════════════════

  @override
  String get eventTitle => 'ইভেন্টের বিষয়';

  @override
  String get eventSubtitle => 'ইভেন্টের বিষয় যোগ করুন';

  @override
  String get reminderTitle => 'রিমাইন্ডারের বিষয়';

  @override
  String get reminderSubtitle => 'রিমাইন্ডারের বিষয় যোগ করুন';

  @override
  String get location => 'লোকেশন';

  @override
  String get locationSubtitle => 'ইভেন্টের লোকেশন যোগ করুন';

  @override
  String get description => 'বিবরণ';

  @override
  String get descriptionSubtitle => 'ইভেন্টের বিস্তারিত বিবরণ যোগ করুন';

  @override
  String get notes => 'নোট';

  @override
  String get notesSubtitle => 'ইভেন্টের জন্য অতিরিক্ত নোট যোগ করুন';

  @override
  String get deleteEvent => 'ইভেন্ট মুছুন';

  @override
  String get deleteEventConfirmMessage =>
      'আপনি কি নিশ্চিত যে আপনি এই ইভেন্টটি মুছে ফেলতে চান?';

  @override
  String get deleteReminder => 'রিমাইন্ডার মুছুন';

  @override
  String get deleteReminderConfirmMessage =>
      'আপনি কি নিশ্চিত যে আপনি এই রিমাইন্ডারটি মুছে ফেলতে চান?';

  @override
  String get eventAddedSuccess => 'ইভেন্ট সফলভাবে যোগ হয়েছে';

  @override
  String get eventUpdatedSuccess => 'ইভেন্ট সফলভাবে আপডেট হয়েছে';

  @override
  String get eventDeletedSuccess => 'ইভেন্ট সফলভাবে মুছে ফেলা হয়েছে';

  @override
  String get reminderAddedSuccess => 'রিমাইন্ডার সফলভাবে যোগ হয়েছে';

  @override
  String get reminderUpdatedSuccess => 'রিমাইন্ডার সফলভাবে আপডেট হয়েছে';

  @override
  String get reminderDeletedSuccess => 'রিমাইন্ডার সফলভাবে মুছে ফেলা হয়েছে';

  @override
  String get allEvents => 'সকল ইভেন্ট';

  @override
  String get allReminders => 'সকল রিমাইন্ডার';

  // ═══════════════════════════════════════════════════════════
  // EVENT CATEGORIES
  // ═══════════════════════════════════════════════════════════

  @override
  String get categoryWork => 'কর্ম';

  @override
  String get categoryPersonal => 'ব্যক্তিগত';

  @override
  String get categoryFamily => 'পরিবার';

  @override
  String get categoryHealth => 'স্বাস্থ্য';

  @override
  String get categoryEducation => 'শিক্ষা';

  @override
  String get categorySocial => 'সামাজিক';

  @override
  String get categoryOther => 'অন্যান্য';

  // ═══════════════════════════════════════════════════════════
  // REMINDER PRIORITY
  // ═══════════════════════════════════════════════════════════

  @override
  String get priority => 'অগ্রাধিকার';

  @override
  String get priorityLow => 'নিম্ন';

  @override
  String get priorityMedium => 'মাঝারি';

  @override
  String get priorityHigh => 'উচ্চ';

  @override
  String get priorityUrgent => 'জরুরি';

  // ═══════════════════════════════════════════════════════════
  // QUOTES & WORDS
  // ═══════════════════════════════════════════════════════════

  @override
  String get savedQuotes => 'সংরক্ষিত উক্তি';

  @override
  String get savedWords => 'সংরক্ষিত শব্দ';

  @override
  String get noSavedQuotes => 'কোন ফেভারিট উক্তি নেই';

  @override
  String get noSavedWords => 'কোন ফেভারিট শব্দ নেই';

  @override
  String get adjustFontSize => 'ফন্ট সাইজ পরিবর্তন করুন';

  // ═══════════════════════════════════════════════════════════
  // CALCULATOR
  // ═══════════════════════════════════════════════════════════

  @override
  String get calculatorTitle => 'বয়স ক্যালকুলেটর';

  @override
  String get fromDate => 'শুরুর তারিখ';

  @override
  String get toDate => 'শেষ তারিখ';

  @override
  String get selectDate => 'তারিখ নির্বাচন করুন';

  @override
  String get selectFromDate => 'শুরুর তারিখ নির্বাচন করুন';

  @override
  String get selectToDate => 'শেষ তারিখ নির্বাচন করুন';

  @override
  String get copyResult => 'কপি';

  @override
  String get copiedToClipboard => 'কপি হয়েছে';

  @override
  String get invalidDateRange => 'শুরুর তারিখ শেষ তারিখের পরে হতে পারবে না';

  @override
  String get selectDatesToSeeResults => 'ফলাফল দেখতে তারিখ নির্বাচন করুন';

  @override
  String get calculationResults => 'গণনার ফলাফল';

  @override
  String get yearsMonthsDays => 'বছর মাস দিন';

  @override
  String get totalDays => 'মোট দিন';

  @override
  String get weeksAndDays => 'সপ্তাহ এবং দিন';

  // ═══════════════════════════════════════════════════════════
  // TIME UNITS
  // ═══════════════════════════════════════════════════════════

  @override
  String get year => 'বছর';

  @override
  String get years => 'বছর';

  @override
  String get month => 'মাস';

  @override
  String get months => 'মাস';

  @override
  String get day => 'দিন';

  @override
  String get days => 'দিন';

  @override
  String get week => 'সপ্তাহ';

  @override
  String get weeks => 'সপ্তাহ';

  // ═══════════════════════════════════════════════════════════
  // DAYS OF WEEK
  // ═══════════════════════════════════════════════════════════

  @override
  String get monday => 'সোমবার';

  @override
  String get tuesday => 'মঙ্গলবার';

  @override
  String get wednesday => 'বুধবার';

  @override
  String get thursday => 'বৃহস্পতিবার';

  @override
  String get friday => 'শুক্রবার';

  @override
  String get saturday => 'শনিবার';

  @override
  String get sunday => 'রবিবার';

  @override
  String get shortSunday => 'রবি';

  @override
  String get shortMonday => 'সোম';

  @override
  String get shortTuesday => 'মঙ্গল';

  @override
  String get shortWednesday => 'বুধ';

  @override
  String get shortThursday => 'বৃহ';

  @override
  String get shortFriday => 'শুক্র';

  @override
  String get shortSaturday => 'শনি';

  // ═══════════════════════════════════════════════════════════
  // MONTHS — GREGORIAN
  // ═══════════════════════════════════════════════════════════

  @override
  String get january => 'জানুয়ারি';

  @override
  String get february => 'ফেব্রুয়ারি';

  @override
  String get march => 'মার্চ';

  @override
  String get april => 'এপ্রিল';

  @override
  String get may => 'মে';

  @override
  String get june => 'জুন';

  @override
  String get july => 'জুলাই';

  @override
  String get august => 'আগস্ট';

  @override
  String get september => 'সেপ্টেম্বর';

  @override
  String get october => 'অক্টোবর';

  @override
  String get november => 'নভেম্বর';

  @override
  String get december => 'ডিসেম্বর';

  // ═══════════════════════════════════════════════════════════
  // MONTHS — BENGALI
  // ═══════════════════════════════════════════════════════════

  @override
  String get boishakh => 'বৈশাখ';

  @override
  String get jyoishtho => 'জ্যৈষ্ঠ';

  @override
  String get asharh => 'আষাঢ়';

  @override
  String get srabon => 'শ্রাবণ';

  @override
  String get bhadro => 'ভাদ্র';

  @override
  String get ashwin => 'আশ্বিন';

  @override
  String get kartik => 'কার্তিক';

  @override
  String get ogrohayon => 'অগ্রহায়ণ';

  @override
  String get poush => 'পৌষ';

  @override
  String get magh => 'মাঘ';

  @override
  String get falgun => 'ফাল্গুন';

  @override
  String get choitra => 'চৈত্র';

  // ═══════════════════════════════════════════════════════════
  // SEASONS
  // ═══════════════════════════════════════════════════════════

  @override
  String get seasonGrishmo => 'গ্রীষ্ম';

  @override
  String get seasonBorsha => 'বর্ষা';

  @override
  String get seasonSharat => 'শরৎ';

  @override
  String get seasonHemonto => 'হেমন্ত';

  @override
  String get seasonSheet => 'শীত';

  @override
  String get seasonBosonto => 'বসন্ত';

  @override
  String get seasonSpring => 'বসন্ত';

  @override
  String get seasonSummer => 'গ্রীষ্ম';

  @override
  String get seasonAutumn => 'শরৎ';

  @override
  String get seasonWinter => 'শীত';

  // ═══════════════════════════════════════════════════════════
  // MONTH ABBREVIATIONS (override base)
  // ═══════════════════════════════════════════════════════════

  @override
  String getMonthAbbreviation(int month) {
    const abbreviations = {
      1: 'জানু',
      2: 'ফেব্রু',
      3: 'মার্চ',
      4: 'এপ্রি',
      5: 'মে',
      6: 'জুন',
      7: 'জুলা',
      8: 'আগস্ট',
      9: 'সেপ্টে',
      10: 'অক্টো',
      11: 'নভে',
      12: 'ডিসে',
    };
    return abbreviations[month] ?? '';
  }
}
