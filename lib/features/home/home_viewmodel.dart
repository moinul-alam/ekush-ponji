// lib/features/home/home_viewmodel.dart

import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/features/events/models/event.dart';
import 'package:ekush_ponji/features/calendar/data/calendar_repository.dart';
import 'package:ekush_ponji/features/events/data/event_repository.dart';

class HomeViewModel extends BaseViewModel {
  final CalendarRepository _calendarRepository;
  final EventRepository _eventRepository;

  HomeViewModel({
    CalendarRepository? calendarRepository,
    EventRepository? eventRepository,
  })  : _calendarRepository = calendarRepository ?? CalendarRepository(),
        _eventRepository = eventRepository ?? EventRepository();

  List<Holiday> _holidays = [];
  List<Event> _events = [];
  String? _userName;

  List<Holiday> get holidays => _holidays;
  List<Event> get events => _events;
  String? get userName => _userName;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    await executeAsync(
      operation: () async {
        final now = DateTime.now();
        final monthHolidays = await _calendarRepository.getHolidaysForMonth(
          now.year,
          now.month,
        );
        _holidays = monthHolidays.where((h) => h.daysUntil >= 0).toList();
        _events = await _eventRepository.getEventsForDate(now);
      },
      loadingMessage: 'Loading home data...',
      successMessage: null,
      showLoading: true,
      setSuccessState: true,
    );
  }

  @override
  Future<bool> refresh() async {
    return await executeAsync(
      operation: () async {
        final now = DateTime.now();
        final monthHolidays = await _calendarRepository.getHolidaysForMonth(
          now.year,
          now.month,
        );
        _holidays = monthHolidays.where((h) => h.daysUntil >= 0).toList();
        _events = await _eventRepository.getEventsForDate(now);
      },
      showLoading: false,
      setSuccessState: true,
    );
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, ViewState>(
  () => HomeViewModel(),
);
