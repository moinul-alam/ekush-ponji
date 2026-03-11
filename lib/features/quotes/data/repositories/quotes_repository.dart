// lib/features/quotes/data/repositories/quotes_repository.dart

import 'package:ekush_ponji/features/quotes/data/datasources/local/quotes_local_datasource.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';

class QuotesRepository {
  final QuotesLocalDatasource _localDatasource;

  QuotesRepository({required QuotesLocalDatasource localDatasource})
      : _localDatasource = localDatasource;

  /// Must be called once before any other method.
  Future<void> init() => _localDatasource.init();

  /// Reload quotes from Hive after a sync — call when sync returns true.
  Future<void> reload() => _localDatasource.reload();

  QuoteModel getDailyQuote() => _localDatasource.getDailyQuote();

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
