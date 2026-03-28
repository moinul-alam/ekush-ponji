// lib/features/quotes/quotes_viewmodel.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/services/app_review_service.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';
import 'package:ekush_ponji/features/quotes/data/datasources/local/quotes_local_datasource.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';
import 'package:ekush_ponji/features/quotes/data/repositories/quotes_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuotesViewModel extends BaseViewModel {
  late final QuotesRepository _repository;

  QuoteModel? _dailyQuote;
  List<QuoteModel> _allQuotes = [];
  List<QuoteModel> _savedQuotes = [];

  QuoteModel? get dailyQuote => _dailyQuote;
  List<QuoteModel> get allQuotes => _allQuotes;
  List<QuoteModel> get savedQuotes => _savedQuotes;

  @override
  void onSyncSetup() {
    _repository = QuotesRepository(
      localDatasource: QuotesLocalDatasource(
        savedBox: Hive.box<QuoteModel>(savedQuotesBoxName),
        settingsBox: Hive.box(settingsBoxName),
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    loadQuotes();
  }

  Future<void> loadQuotes() async {
    await executeAsync(
      operation: () async {
        await _repository.init();
        _dailyQuote = _repository.getDailyQuote();
        _allQuotes = _repository.getAllQuotes();
        _savedQuotes = _repository.getSavedQuotes();
      },
      loadingMessage: 'Loading quotes...',
      errorMessage: 'Failed to load quotes',
    );
  }

  Future<void> toggleSave(QuoteModel quote) async {
    await executeAsync(
      operation: () async {
        await _repository.toggleSave(quote);
        final isSaved = _repository.isQuoteSaved(quote);
        _allQuotes = _allQuotes.map((q) {
          return q == quote ? q.copyWith(isSaved: isSaved) : q;
        }).toList();
        if (_dailyQuote == quote) {
          _dailyQuote = _dailyQuote!.copyWith(isSaved: isSaved);
        }
        _savedQuotes = _repository.getSavedQuotes();

        // Record meaningful action when user saves a quote for the first time
        if (isSaved) {
          AppReviewService.recordMeaningfulAction();
        }
      },
      showLoading: false,
      errorMessage: 'Failed to update saved quotes',
    );
  }

  Future<void> refreshSavedQuotes() async {
    _savedQuotes = _repository.getSavedQuotes();
    setSuccess();
  }

  bool isQuoteSaved(QuoteModel quote) => _repository.isQuoteSaved(quote);
}

final quotesViewModelProvider =
    NotifierProvider<QuotesViewModel, ViewState>(QuotesViewModel.new);

final quotesRepositoryProvider = Provider<QuotesRepository>((ref) {
  return QuotesRepository(
    localDatasource: QuotesLocalDatasource(
      savedBox: Hive.box<QuoteModel>(savedQuotesBoxName),
      settingsBox: Hive.box(settingsBoxName),
    ),
  );
});
