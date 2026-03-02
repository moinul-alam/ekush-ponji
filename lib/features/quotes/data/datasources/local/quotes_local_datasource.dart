// lib/data/datasources/local/quotes_local_datasource.dart

import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekush_ponji/core/data/dailyQuotesEn.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';

const String savedQuotesBoxName = 'saved_quotes';

class QuotesLocalDatasource {
  final Box<QuoteModel> _savedBox;

  QuotesLocalDatasource({required Box<QuoteModel> savedBox})
      : _savedBox = savedBox;

  /// Returns today's quote seeded by date so it's consistent all day
  QuoteModel getDailyQuote() {
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final random = Random(seed);
    final index = random.nextInt(dailyQuotesEn.length);
    final enQuote = dailyQuotesEn[index];
    final key = enQuote.text.hashCode.toString();

    return QuoteModel(
      text: enQuote.text,
      author: enQuote.author,
      category: enQuote.category,
      isSaved: _savedBox.containsKey(key),
    );
  }

  /// Returns all quotes from the data list, with saved state resolved
  List<QuoteModel> getAllQuotes() {
    return dailyQuotesEn.map((enQuote) {
      final key = enQuote.text.hashCode.toString();
      return QuoteModel(
        text: enQuote.text,
        author: enQuote.author,
        category: enQuote.category,
        isSaved: _savedBox.containsKey(key),
      );
    }).toList();
  }

  /// Returns all saved quotes from Hive
  List<QuoteModel> getSavedQuotes() {
    return _savedBox.values.toList();
  }

  /// Save a quote to Hive
  Future<void> saveQuote(QuoteModel quote) async {
    final saved = quote.copyWith(isSaved: true);
    await _savedBox.put(saved.storageKey, saved);
  }

  /// Remove a quote from saved
  Future<void> unsaveQuote(QuoteModel quote) async {
    await _savedBox.delete(quote.storageKey);
  }

  /// Check if a quote is saved
  bool isQuoteSaved(QuoteModel quote) {
    return _savedBox.containsKey(quote.storageKey);
  }
}