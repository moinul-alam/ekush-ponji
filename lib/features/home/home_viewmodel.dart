import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';
import 'package:ekush_ponji/features/home/models/event.dart';
import 'package:ekush_ponji/features/calendar/data/calendar_repository.dart';

class HomeViewModel extends BaseViewModel {
  final CalendarRepository _calendarRepository;

  HomeViewModel({CalendarRepository? calendarRepository})
      : _calendarRepository = calendarRepository ?? CalendarRepository();

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
        _userName = 'User';

        // Sync holidays from Firestore if needed
        final now = DateTime.now();
        await _calendarRepository.syncHolidaysIfNeeded(now.year);

        // Load upcoming holidays (next 30 days)
        _holidays = await _calendarRepository.getUpcomingHolidays(days: 30);

        // Events — real data coming later
        _events = [];
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

        final now = DateTime.now();
        await _calendarRepository.syncHolidaysIfNeeded(now.year);
        _holidays = await _calendarRepository.getUpcomingHolidays(days: 30);
        _events = [];
      },
      showLoading: false,
      setSuccessState: false,
    );
  }

  // ------------------- Sample Data (quote & word — kept until models ready) -------------------

  Map<String, String> get dailyQuote {
    final quotes = [
      {
        'text': 'The only way to do great work is to love what you do.',
        'author': 'Steve Jobs',
        'category': 'Motivation',
      },
      {
        'text':
            'Success is not final, failure is not fatal: it is the courage to continue that counts.',
        'author': 'Winston Churchill',
        'category': 'Success',
      },
      {
        'text': 'Believe you can and you\'re halfway there.',
        'author': 'Theodore Roosevelt',
        'category': 'Inspiration',
      },
    ];

    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return quotes[dayOfYear % quotes.length];
  }

  Map<String, String> get dailyWord {
    final words = [
      {
        'word': 'Serendipity',
        'pronunciation': '/ˌserənˈdipədē/',
        'partOfSpeech': 'noun',
        'meaning':
            'The occurrence of events by chance in a happy or beneficial way.',
        'synonym': 'Luck, fortune, chance',
        'example':
            'A fortunate stroke of serendipity brought the two old friends together after many years.',
      },
      {
        'word': 'Eloquent',
        'pronunciation': '/ˈeləkwənt/',
        'partOfSpeech': 'adjective',
        'meaning': 'Fluent or persuasive in speaking or writing.',
        'synonym': 'Articulate, expressive, fluent',
        'example':
            'The lawyer made an eloquent plea for his client\'s innocence.',
      },
    ];

    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return words[dayOfYear % words.length];
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, ViewState>(
  () => HomeViewModel(),
);