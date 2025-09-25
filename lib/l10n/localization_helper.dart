import 'package:flutter/material.dart';
import 'app_localizations_en.dart';
import 'app_localizations_bn.dart';

/// Helper class to get localized strings based on current locale
class LocalizationHelper {
  static bool isBengali(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'bn';
  }
  
  static String getAppName(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.appName : AppLocalizationsEn.appName;
  }
  
  static List<String> getMonths(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.months : AppLocalizationsEn.months;
  }
  
  static List<String> getNumbers(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.numbers : AppLocalizationsEn.numbers;
  }
  
  static List<String> getWeekdays(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.weekdays : AppLocalizationsEn.weekdays;
  }
  
  static List<String> getWeekdaysShort(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.weekdaysShort : AppLocalizationsEn.weekdaysShort;
  }
  
  static String getEventType(BuildContext context, String eventType) {
    final eventTypes = isBengali(context) ? AppLocalizationsBn.eventTypes : AppLocalizationsEn.eventTypes;
    return eventTypes[eventType] ?? eventType;
  }
  
  static String getSpecialDay(BuildContext context, String dayKey) {
    final specialDays = isBengali(context) ? AppLocalizationsBn.specialDays : AppLocalizationsEn.specialDays;
    return specialDays[dayKey] ?? dayKey;
  }
  
  // Common UI texts
  static String getToday(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.today : AppLocalizationsEn.today;
  }
  
  static String getTomorrow(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.tomorrow : AppLocalizationsEn.tomorrow;
  }
  
  static String getYesterday(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.yesterday : AppLocalizationsEn.yesterday;
  }
  
  // Actions
  static String getAdd(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.add : AppLocalizationsEn.add;
  }
  
  static String getEdit(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.edit : AppLocalizationsEn.edit;
  }
  
  static String getDelete(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.delete : AppLocalizationsEn.delete;
  }
  
  static String getSave(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.save : AppLocalizationsEn.save;
  }
  
  static String getCancel(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.cancel : AppLocalizationsEn.cancel;
  }
  
  static String getClose(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.close : AppLocalizationsEn.close;
  }
  
  // Navigation
  static String getHome(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.home : AppLocalizationsEn.home;
  }
  
  static String getCalendar(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.calendar : AppLocalizationsEn.calendar;
  }
  
  static String getReminders(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.reminders : AppLocalizationsEn.reminders;
  }
  
  static String getSettings(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.settings : AppLocalizationsEn.settings;
  }
  
  // Features
  static String getAddReminder(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.addReminder : AppLocalizationsEn.addReminder;
  }
  
  static String getReminderTitle(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.reminderTitle : AppLocalizationsEn.reminderTitle;
  }
  
  static String getSelectDate(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.selectDate : AppLocalizationsEn.selectDate;
  }
  
  static String getSelectTime(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.selectTime : AppLocalizationsEn.selectTime;
  }
  
  // Messages
  static String getNoRemindersFound(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.noRemindersFound : AppLocalizationsEn.noRemindersFound;
  }
  
  static String getReminderAdded(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.reminderAdded : AppLocalizationsEn.reminderAdded;
  }
  
  static String getError(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.error : AppLocalizationsEn.error;
  }
  
  static String getLoading(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.loading : AppLocalizationsEn.loading;
  }
  
  // Validation
  static String getTitleRequired(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.titleRequired : AppLocalizationsEn.titleRequired;
  }
  
  static String getDateRequired(BuildContext context) {
    return isBengali(context) ? AppLocalizationsBn.dateRequired : AppLocalizationsEn.dateRequired;
  }
  
  // Utility methods
  
  /// Convert English numbers to Bengali if current locale is Bengali
  static String formatNumber(BuildContext context, int number) {
    if (!isBengali(context)) return number.toString();
    
    final bengaliNumbers = AppLocalizationsBn.numbers;
    return number.toString().split('').map((digit) {
      final index = int.tryParse(digit);
      return index != null ? bengaliNumbers[index] : digit;
    }).join();
  }
  
  /// Format price with currency symbol
  static String formatPrice(BuildContext context, int amount) {
    final symbol = isBengali(context) ? AppLocalizationsBn.currencySymbol : AppLocalizationsEn.currencySymbol;
    final formattedAmount = formatNumber(context, amount);
    return '$symbol$formattedAmount';
  }
  
  /// Get month name by index (0-11)
  static String getMonthName(BuildContext context, int monthIndex) {
    final months = getMonths(context);
    return monthIndex >= 0 && monthIndex < months.length ? months[monthIndex] : '';
  }
  
  /// Get weekday name by index (0-6, where 0 is Monday)
  static String getWeekdayName(BuildContext context, int weekdayIndex, {bool short = false}) {
    final weekdays = short ? getWeekdaysShort(context) : getWeekdays(context);
    return weekdayIndex >= 0 && weekdayIndex < weekdays.length ? weekdays[weekdayIndex] : '';
  }
}