import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/features/calendar/models/calendar_day.dart';
import 'package:ekush_ponji/features/calendar/models/month_data.dart';
// import 'package:ekush_ponji/features/calendar/models/bengali_date.dart';
import 'package:ekush_ponji/features/calendar/data/calendar_repository.dart';
import 'package:ekush_ponji/core/services/bengali_calendar_service.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/features/home/models/event.dart';
// import 'package:ekush_ponji/features/home/models/reminder.dart';

class CalendarViewModel extends BaseViewModel {
  late final CalendarRepository _repository;
  late final BengaliCalendarService _bengaliService;

  MonthData? _currentMonthData;
  DateTime? _selectedDate;
  bool _isDayDetailsPanelExpanded = false;

  /// Cache for months: 'year-month' -> MonthData
  final Map<String, MonthData> _monthCache = {};

  MonthData? get currentMonthData => _currentMonthData;
  DateTime? get selectedDate => _selectedDate;
  bool get isDayDetailsPanelExpanded => _isDayDetailsPanelExpanded;

  List<CalendarDay> get calendarDays => _currentMonthData?.days ?? [];
  String get bengaliMonthsDisplay => _currentMonthData?.getBengaliMonthsDisplay() ?? '';
  List<Holiday> get upcomingHolidays => _currentMonthData?.upcomingHolidays ?? [];
  List<Event> get upcomingEvents => _currentMonthData?.upcomingEvents ?? [];

  /// **Selected day getter for the screen**
  CalendarDay? get selectedDay {
    if (_selectedDate == null || _currentMonthData == null) return null;

    return _currentMonthData!.days.firstWhere(
      (day) => _isSameDay(day.gregorianDate, _selectedDate!),
      orElse: () => _currentMonthData!.days.first,
    );
  }

  @override
  void onInit() {
    super.onInit();
    _repository = ref.read(calendarRepositoryProvider);
    _bengaliService = ref.read(bengaliCalendarServiceProvider);
    loadCurrentMonth();
  }

  Future<void> loadCurrentMonth() async {
    final now = DateTime.now();
    await jumpToMonth(now.year, now.month);
    selectDate(now);
  }

  Future<void> jumpToMonth(int year, int month) async {
    await executeAsync(
      operation: () async {
        final cacheKey = '$year-$month';
        if (_monthCache.containsKey(cacheKey)) {
          _currentMonthData = _monthCache[cacheKey];
        } else {
          final monthData = await _generateMonthData(year, month);
          _monthCache[cacheKey] = monthData;
          _currentMonthData = monthData;

          _prefetchAdjacentMonths(year, month);
        }
      },
      loadingMessage: 'Loading calendar...',
      errorMessage: 'Failed to load calendar',
      successMessage: null,
    );
  }

  Future<void> goToPreviousMonth() async {
    if (_currentMonthData == null) return;

    int prevMonth = _currentMonthData!.gregorianMonth - 1;
    int prevYear = _currentMonthData!.gregorianYear;

    if (prevMonth < 1) {
      prevMonth = 12;
      prevYear--;
    }

    await jumpToMonth(prevYear, prevMonth);
  }

  Future<void> goToNextMonth() async {
    if (_currentMonthData == null) return;

    int nextMonth = _currentMonthData!.gregorianMonth + 1;
    int nextYear = _currentMonthData!.gregorianYear;

    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear++;
    }

    await jumpToMonth(nextYear, nextMonth);
  }

  void selectDate(DateTime date) {
    _selectedDate = date;

    if (_currentMonthData != null) {
      final updatedDays = _currentMonthData!.days.map((day) {
        return day.copyWith(
          isSelected: _isSameDay(day.gregorianDate, date),
        );
      }).toList();

      _currentMonthData = _currentMonthData!.copyWith(days: updatedDays);
      _isDayDetailsPanelExpanded = true;
      state = ViewStateSuccess();
    }
  }

  void toggleDayDetailsPanel() {
    _isDayDetailsPanelExpanded = !_isDayDetailsPanelExpanded;
    state = ViewStateSuccess();
  }

  Future<MonthData> _generateMonthData(int year, int month) async {
    final firstDate = DateTime(year, month, 1);
    final firstWeekday = firstDate.weekday % 7; // 0 = Sunday
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final totalCells = firstWeekday + daysInMonth;
    final numRows = (totalCells + 6) ~/ 7;
    final cellCount = numRows * 7;

    final gridStart = firstDate.subtract(Duration(days: firstWeekday));
    final days = <CalendarDay>[];
    final today = DateTime.now();

    final dateList = List.generate(
        cellCount, (i) => gridStart.add(Duration(days: i)));

    final holidaysMap = await _repository.getHolidaysForDates(dateList);
    final eventsMap = await _repository.getEventsForDates(dateList);
    final remindersMap = await _repository.getRemindersForDates(dateList);

    for (final date in dateList) {
      days.add(CalendarDay(
        gregorianDate: date,
        bengaliDate: _bengaliService.getBengaliDate(date),
        isCurrentMonth: date.month == month && date.year == year,
        isToday: _isSameDay(date, today),
        isSelected: _selectedDate != null && _isSameDay(date, _selectedDate!),
        holidays: holidaysMap[date] ?? [],
        events: eventsMap[date] ?? [],
        reminders: remindersMap[date] ?? [],
      ));
    }

    final bengaliMonths = _bengaliService.getBengaliMonthsForGregorianMonth(year, month);
    final monthHolidays = await _repository.getHolidaysForMonth(year, month);
    final monthEvents = await _repository.getEventsForMonth(year, month);
    final monthReminders = await _repository.getRemindersForMonth(year, month);

    return MonthData(
      gregorianYear: year,
      gregorianMonth: month,
      bengaliMonths: bengaliMonths,
      days: days,
      holidays: monthHolidays,
      events: monthEvents,
      reminders: monthReminders,
    );
  }

  void _prefetchAdjacentMonths(int year, int month) {
    Future.microtask(() async {
      try {
        for (int i = 1; i <= 2; i++) {
          int prevMonth = month - i;
          int prevYear = year;
          if (prevMonth < 1) {
            prevMonth += 12;
            prevYear--;
          }
          final key = '$prevYear-$prevMonth';
          if (!_monthCache.containsKey(key)) {
            _monthCache[key] = await _generateMonthData(prevYear, prevMonth);
          }

          int nextMonth = month + i;
          int nextYear = year;
          if (nextMonth > 12) {
            nextMonth -= 12;
            nextYear++;
          }
          final nextKey = '$nextYear-$nextMonth';
          if (!_monthCache.containsKey(nextKey)) {
            _monthCache[nextKey] = await _generateMonthData(nextYear, nextMonth);
          }
        }
      } catch (_) {}
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }


  @override
  void onDispose() {
    _monthCache.clear();
    super.onDispose();
  }
}

final calendarViewModelProvider =
    NotifierProvider<CalendarViewModel, ViewState>(() => CalendarViewModel());
