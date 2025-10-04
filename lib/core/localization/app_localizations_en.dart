import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

/// English translations
class AppLocalizationsEn extends AppLocalizations {
  @override
  Locale get locale => const Locale('en', 'US');

  @override
  String translate(String key) {
    // You can implement a more sophisticated translation lookup here
    return key;
  }

  // App
  @override
  String get appName => 'Ekush Ponji';

  @override
  String get appTitle => 'Ekush Ponji';

  // Navigation
  @override
  String get navHome => 'Home';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navCalculator => 'Calculator';

  @override
  String get navSettings => 'Settings';

  // Common actions
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

  // Home Screen
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
  String get inDays => 'In %s days';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  // Drawer
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

  // Settings
  @override
  String get settingsTitle => 'Settings';

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

  // Messages
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

  // Days of week
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

  // Months
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

  // Bangla Months
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
