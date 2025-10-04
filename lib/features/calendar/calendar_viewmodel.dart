import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/features/calendar/models/bengali_date.dart';
import 'package:ekush_ponji/features/calendar/models/calendar_day.dart';
import 'package:ekush_ponji/features/calendar/models/month_data.dart';
import 'package:ekush_ponji/features/calendar/data/calendar_repository.dart';
import 'package:ekush_ponji/core/services/bengali_calendar_service.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/features/home/models/event.dart';
import 'package:ekush_ponji/features/home/models/reminder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ViewModel for Calendar Screen
/// Orchestrates calendar state management with composed providers
/// Handles month navigation, date selection, and data loading
class CalendarViewModel extends BaseViewModel<ViewState> {
  // Dependencies
  late final CalendarRepository _repository;
  late final BengaliCalendarService _bengaliService;

  // State variables
  MonthData? _currentMonthData;
  DateTime? _selectedDate;
  bool _isDayDetailsPanelExpanded = false;
  
  // Cache for prefetched months (±2 months)
  final Map<String, MonthData> _monthCache = {};

  // Getters
  MonthData? get currentMonthData => _currentMonthData;
  DateTime? get selectedDate => _selectedDate;
  bool get isDayDetailsPanelExpanded => _isDayDetailsPanelExpanded;
  
  List<CalendarDay> get calendarDays => _currentMonthData?.days ?? [];
  String get bengaliMonthsDisplay => 
      _currentMonthData?.getBengaliMonthsDisplay() ?? '';
  List<Holiday> get upcomingHolidays => 
      _currentMonthData?.upcomingHolidays ?? [];
  List<Event> get upcomingEvents => 
      _currentMonthData?.upcomingEvents ?? [];

  @override
  void onInit() {
    super.onInit();
    
    // Get dependencies from ref
    _repository = ref.read(calendarRepositoryProvider);
    _bengaliService = ref.read(bengaliCalendarServiceProvider);
    
    // Load current month data
    loadCurrentMonth();
  }

  /// Load current month (today's month)
  Future<void> loadCurrentMonth() async {
    final now = DateTime.now();
    await loadMonth(now.year, now.month);
    
    // Auto-select today
    selectDate(now);
  }

  /// Load a specific month
  Future<void> loadMonth(int year, int month) async {
    try {
      setLoading('Loading calendar...');

      // Check cache first
      final cacheKey = '$year-$month';
      if (_monthCache.containsKey(cacheKey)) {
        _currentMonthData = _monthCache[cacheKey];
        setSuccess();
        return;
      }

      // Generate month data
      final monthData = await _generateMonthData(year, month);
      
      // Cache the data
      _monthCache[cacheKey] = monthData;
      _currentMonthData = monthData;

      // Prefetch adjacent months for smooth navigation
      _prefetchAdjacentMonths(year, month);

      setSuccess();
    } catch (e, stackTrace) {
      handleError(e, stackTrace, customMessage: 'Failed to load calendar');
    }
  }

  /// Navigate to previous month
  Future<void> goToPreviousMonth() async {
    if (_currentMonthData == null) return;

    final currentYear = _currentMonthData!.gregorianYear;
    final currentMonth = _currentMonthData!.gregorianMonth;

    final previousMonth = currentMonth == 1 ? 12 : currentMonth - 1;
    final previousYear = currentMonth == 1 ? currentYear - 1 : currentYear;

    await loadMonth(previousYear, previousMonth);
  }

  /// Navigate to next month
  Future<void> goToNextMonth() async {
    if (_currentMonthData == null) return;

    final currentYear = _currentMonthData!.gregorianYear;
    final currentMonth = _currentMonthData!.gregorianMonth;

    final nextMonth = currentMonth == 12 ? 1 : currentMonth + 1;
    final nextYear = currentMonth == 12 ? currentYear + 1 : currentYear;

    await loadMonth(nextYear, nextMonth);
  }

  /// Jump to a specific month (from month picker)
  Future<void> jumpToMonth(int year, int month) async {
    await loadMonth(year, month);
  }

  /// Select a date
  void selectDate(DateTime date) {
    _selectedDate = date;
    
    // Update selected state in calendar days
    if (_currentMonthData != null) {
      final updatedDays = _currentMonthData!.days.map((day) {
        return day.copyWith(
          isSelected: _isSameDay(day.gregorianDate, date),
        );
      }).toList();

      _currentMonthData = _currentMonthData!.copyWith(days: updatedDays);
      
      // Auto-expand details panel when selecting a date
      _isDayDetailsPanelExpanded = true;
      
      // Notify listeners
      state = ViewStateSuccess();
    }
  }

  /// Toggle day details panel expansion
  void toggleDayDetailsPanel() {
    _isDayDetailsPanelExpanded = !_isDayDetailsPanelExpanded;
    state = ViewStateSuccess();
  }

  /// Get selected day data
  CalendarDay? getSelectedDay() {
    if (_selectedDate == null || _currentMonthData == null) return null;
    
    return _currentMonthData!.days.firstWhere(
      (day) => _isSameDay(day.gregorianDate, _selectedDate!),
      orElse: () => _currentMonthData!.days.first,
    );
  }

  // ==================== Private Methods ====================

  /// Generate month data with all 42 cells
  Future<MonthData> _generateMonthData(int year, int month) async {
    // Get first day of month
    final firstDate = DateTime(year, month, 1);
    final lastDate = DateTime(year, month + 1, 0);

    // Calculate grid start (Sunday of the week containing first day)
    final firstWeekday = firstDate.weekday % 7; // 0 = Sunday
    final gridStart = firstDate.subtract(Duration(days: firstWeekday));

    // Generate 42 days (6 weeks)
    final days = <CalendarDay>[];
    final today = DateTime.now();

    for (int i = 0; i < 42; i++) {
      final date = gridStart.add(Duration(days: i));
      final isCurrentMonth = date.month == month && date.year == year;
      final isToday = _isSameDay(date, today);

      // Get Bengali date
      final bengaliDate = await _bengaliService.getBengaliDate(date);

      // Get holidays, events, reminders for this date
      final holidays = await _repository.getHolidaysForDate(date);
      final events = await _repository.getEventsForDate(date);
      final reminders = await _repository.getRemindersForDate(date);

      final calendarDay = CalendarDay(
        gregorianDate: date,
        bengaliDate: bengaliDate ?? _getFallbackBengaliDate(date),
        isCurrentMonth: isCurrentMonth,
        isToday: isToday,
        isSelected: _selectedDate != null && _isSameDay(date, _selectedDate!),
        holidays: holidays,
        events: events,
        reminders: reminders,
      );

      days.add(calendarDay);
    }

    // Get Bengali months for this Gregorian month
    final bengaliMonths = await _bengaliService
        .getBengaliMonthsForGregorianMonth(year, month);

    // Get all holidays/events/reminders for the month
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

  /// Prefetch adjacent months (±2 months) for smooth navigation
  void _prefetchAdjacentMonths(int year, int month) {
    // Prefetch in background without blocking
    Future.microtask(() async {
      try {
        // Previous 2 months
        for (int i = 1; i <= 2; i++) {
          final targetMonth = month - i;
          final targetYear = targetMonth <= 0 
              ? year - 1 
              : year;
          final adjustedMonth = targetMonth <= 0 
              ? 12 + targetMonth 
              : targetMonth;
          
          final cacheKey = '$targetYear-$adjustedMonth';
          if (!_monthCache.containsKey(cacheKey)) {
            final data = await _generateMonthData(targetYear, adjustedMonth);
            _monthCache[cacheKey] = data;
          }
        }

        // Next 2 months
        for (int i = 1; i <= 2; i++) {
          final targetMonth = month + i;
          final targetYear = targetMonth > 12 
              ? year + 1 
              : year;
          final adjustedMonth = targetMonth > 12 
              ? targetMonth - 12 
              : targetMonth;
          
          final cacheKey = '$targetYear-$adjustedMonth';
          if (!_monthCache.containsKey(cacheKey)) {
            final data = await _generateMonthData(targetYear, adjustedMonth);
            _monthCache[cacheKey] = data;
          }
        }
      } catch (e) {
        // Silently fail prefetch - not critical
      }
    });
  }

  /// Check if two dates are the same day (ignoring time)
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Fallback Bengali date if mapping not available
  BengaliDate _getFallbackBengaliDate(DateTime gregorianDate) {
    // Simple fallback - use approximate conversion
    // In production, this should never be used if JSON is complete
    return BengaliDate(
      day: gregorianDate.day,
      monthName: 'Unknown',
      year: 1432, // Approximate
      monthNumber: 1,
    );
  }

  @override
  void onDispose() {
    // Clear cache on dispose
    _monthCache.clear();
    super.onDispose();
  }
}

/// Provider for CalendarViewModel
final calendarViewModelProvider =
    NotifierProvider<CalendarViewModel, ViewState>(
  () => CalendarViewModel(),
);