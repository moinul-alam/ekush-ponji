import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

/// Bangla translations
class AppLocalizationsBn extends AppLocalizations {
  @override
  Locale get locale => const Locale('bn', 'BD');

  @override
  String translate(String key) {
    // You can implement a more sophisticated translation lookup here
    return key;
  }

  // App
  @override
  String get appName => 'একুশ পঞ্জি';

  @override
  String get appTitle => 'একুশ পঞ্জি';

  // Navigation
  @override
  String get navHome => 'হোম';

  @override
  String get navCalendar => 'ক্যালেন্ডার';

  @override
  String get navCalculator => 'ক্যালকুলেটর';

  @override
  String get navSettings => 'সেটিংস';

  // Common actions
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

  // Home Screen
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
  String get upcomingHolidays => 'আпредстоящий ছুটির দিন';

  @override
  String get upcomingEvents => 'আসন্ন ইভেন্ট';

  @override
  String get noUpcomingEvents => 'কোন আসন্ন ইভেন্ট নেই';

  @override
  String get quoteOfTheDay => 'আজকের উক্তি';

  @override
  String get wordOfTheDay => 'আজকের শব্দ';

  @override
  String get meaning => 'অর্থ';

  @override
  String get synonym => 'সমার্থক শব্দ';

  @override
  String get example => 'উদাহরণ';

  @override
  String get inDays => '%s দিনে';

  @override
  String get today => 'আজ';

  @override
  String get tomorrow => 'আগামীকাল';

  // Drawer
  @override
  String get profile => 'প্রোফাইল';

  @override
  String get about => 'সম্পর্কে';

  @override
  String get helpSupport => 'সাহায্য এবং সহায়তা';

  @override
  String get settings => 'সেটিংস';

  @override
  String get welcome => 'স্বাগতম!';

  // Settings
  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get language => 'ভাষা';

  @override
  String get theme => 'থিম';

  @override
  String get notifications => 'বিজ্ঞপ্তি';

  @override
  String get darkMode => 'ডার্ক মোড';

  @override
  String get lightMode => 'লাইট মোড';

  @override
  String get systemDefault => 'সিস্টেম ডিফল্ট';

  // Messages
  @override
  String get comingSoon => 'শীঘ্রই আসছে';

  @override
  String get featureComingSoon => 'এই ফিচারটি শীঘ্রই আসছে';

  @override
  String get loadingData => 'ডেটা লোড হচ্ছে...';

  @override
  String get failedToLoadData => 'ডেটা লোড করতে ব্যর্থ';

  @override
  String get noDataAvailable => 'কোন ডেটা উপলব্ধ নেই';

  // Days of week
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

  // Months
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

  // Bangla Months
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

  @override
  String get calculatorTitle => 'তারিখ ক্যালকুলেটর';

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
  String get reset => 'রিসেট';

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
}
