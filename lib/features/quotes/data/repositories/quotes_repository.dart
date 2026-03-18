// lib/features/quotes/data/repositories/quotes_repository.dart

import 'package:ekush_ponji/features/quotes/data/datasources/local/quotes_local_datasource.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';

class QuotesRepository {
  final QuotesLocalDatasource _localDatasource;

  QuotesRepository({required QuotesLocalDatasource localDatasource})
      : _localDatasource = localDatasource;

  Future<void> init() => _localDatasource.init();
  Future<void> reload() => _localDatasource.reload();

  QuoteModel getDailyQuote() => _localDatasource.getDailyQuote();
  QuoteModel getDailyQuoteForDate(DateTime date) =>
      _localDatasource.getDailyQuoteForDate(date);

  List<QuoteModel> getAllQuotes() => _localDatasource.getAllQuotes();
  List<QuoteModel> getSavedQuotes() => _localDatasource.getSavedQuotes();

  Future<void> toggleSave(QuoteModel quote) async {
    if (_localDatasource.isQuoteSaved(quote)) {
      await _localDatasource.unsaveQuote(quote);
    } else {
      await _localDatasource.saveQuote(quote);
    }
  }

  bool isQuoteSaved(QuoteModel quote) => _localDatasource.isQuoteSaved(quote);
}
