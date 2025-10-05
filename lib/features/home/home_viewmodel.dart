// lib/features/home/home_viewmodel.dart

import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/home/widgets/upcoming_holidays_widget.dart';
import 'package:ekush_ponji/features/home/widgets/upcoming_events_widget.dart';
import 'package:ekush_ponji/features/home/widgets/daily_quote_widget.dart';
import 'package:ekush_ponji/features/home/widgets/daily_word_widget.dart';

class HomeViewModel extends BaseViewModel {
  List<Holiday> _holidays = [];
  List<Event> _events = [];
  Quote? _dailyQuote;
  DailyWord? _dailyWord;
  String? _userName;

  List<Holiday> get holidays => _holidays;
  List<Event> get events => _events;
  Quote? get dailyQuote => _dailyQuote;
  DailyWord? get dailyWord => _dailyWord;
  String? get userName => _userName;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    await executeAsync(
      operation: () async {
        _userName = 'User';
        _holidays = _getSampleHolidays();
        _events = _getSampleEvents();
        _dailyQuote = _getSampleQuote();
        _dailyWord = _getSampleWord();
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
        _userName = 'User';
        _holidays = _getSampleHolidays();
        _events = _getSampleEvents();
        _dailyQuote = _getSampleQuote();
        _dailyWord = _getSampleWord();
      },
      showLoading: false,
      setSuccessState: false,
    );
  }

  List<Holiday> _getSampleHolidays() {
    return [
      Holiday(
        name: 'Victory Day',
        namebn: 'বিজয় দিবস',
        date: DateTime(2025, 12, 16),
        type: HolidayType.national,
        description: 'Commemorates the victory in the Liberation War',
      ),
      Holiday(
        name: 'Eid ul-Fitr',
        namebn: 'ঈদুল ফিতর',
        date: DateTime(2026, 3, 31),
        type: HolidayType.religious,
        description: 'Festival of breaking the fast',
      ),
      Holiday(
        name: 'Pohela Boishakh',
        namebn: 'পহেলা বৈশাখ',
        date: DateTime(2026, 4, 14),
        type: HolidayType.cultural,
        description: 'Bengali New Year',
      ),
    ];
  }

  List<Event> _getSampleEvents() {
    return [
      Event(
        title: 'Team Meeting',
        description: 'Monthly team sync-up',
        startTime: DateTime.now().add(const Duration(days: 2, hours: 10)),
        endTime: DateTime.now().add(const Duration(days: 2, hours: 11)),
        location: 'Conference Room A',
        category: EventCategory.work,
      ),
      Event(
        title: 'Birthday Party',
        description: 'Celebrating Ahmed\'s birthday',
        startTime: DateTime.now().add(const Duration(days: 5, hours: 18)),
        endTime: DateTime.now().add(const Duration(days: 5, hours: 21)),
        location: 'Home',
        category: EventCategory.personal,
      ),
    ];
  }

  Quote _getSampleQuote() {
    final quotes = [
      Quote(
        text: 'The only way to do great work is to love what you do.',
        author: 'Steve Jobs',
        category: 'Motivation',
      ),
      Quote(
        text:
            'Success is not final, failure is not fatal: it is the courage to continue that counts.',
        author: 'Winston Churchill',
        category: 'Success',
      ),
      Quote(
        text: 'Believe you can and you\'re halfway there.',
        author: 'Theodore Roosevelt',
        category: 'Inspiration',
      ),
    ];

    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return quotes[dayOfYear % quotes.length];
  }

  DailyWord _getSampleWord() {
    final words = [
      DailyWord(
        word: 'Serendipity',
        pronunciation: '/ˌserənˈdipədē/',
        partOfSpeech: 'noun',
        meaning:
            'The occurrence of events by chance in a happy or beneficial way.',
        synonym: 'Luck, fortune, chance',
        example:
            'A fortunate stroke of serendipity brought the two old friends together after many years.',
      ),
      DailyWord(
        word: 'Eloquent',
        pronunciation: '/ˈeləkwənt/',
        partOfSpeech: 'adjective',
        meaning: 'Fluent or persuasive in speaking or writing.',
        synonym: 'Articulate, expressive, fluent',
        example:
            'The lawyer made an eloquent plea for his client\'s innocence.',
      ),
    ];

    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return words[dayOfYear % words.length];
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, ViewState>(
  () => HomeViewModel(),
);