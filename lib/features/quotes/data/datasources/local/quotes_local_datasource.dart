// lib/features/quotes/data/datasources/local/quotes_local_datasource.dart
//
// CHANGED: added getDailyQuoteForDate(DateTime) for quote notification service

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ekush_ponji/features/quotes/models/quote.dart';
import 'package:ekush_ponji/features/quotes/services/quotes_sync_service.dart';

const String savedQuotesBoxName = 'saved_quotes';

class QuotesLocalDatasource {
  final Box<QuoteModel> _savedBox;
  final Box _settingsBox;

  List<QuoteModel>? _cachedQuotes;

  QuotesLocalDatasource({
    required Box<QuoteModel> savedBox,
    required Box settingsBox,
  })  : _savedBox = savedBox,
        _settingsBox = settingsBox;

  // ── Initialisation ─────────────────────────────────────────

  Future<void> init() async {
    if (_cachedQuotes != null) return;
    await _loadQuotes();
  }

  Future<void> reload() async {
    _cachedQuotes = null;
    await _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    final String jsonString;

    final hiveCached =
        _settingsBox.get(QuotesSyncService.quotesEnKey) as String?;

    if (hiveCached != null && hiveCached.isNotEmpty) {
      jsonString = hiveCached;
    } else {
      jsonString =
          await rootBundle.loadString('assets/data/quotes/quotes_en.json');
    }

    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final List<dynamic> rawList = jsonMap['quotes'] as List<dynamic>;

    _cachedQuotes = rawList.map((raw) {
      final map = raw as Map<String, dynamic>;
      final key = (map['text'] as String).hashCode.toString();
      return QuoteModel.fromJson(map, isSaved: _savedBox.containsKey(key));
    }).toList();
  }

  List<QuoteModel> get _quotes {
    assert(
      _cachedQuotes != null,
      'QuotesLocalDatasource.init() must be awaited before use.',
    );
    return _cachedQuotes!;
  }

  // ── Daily quote ────────────────────────────────────────────

  /// Returns the quote for today's date.
  QuoteModel getDailyQuote() {
    return getDailyQuoteForDate(DateTime.now());
  }

  /// Returns the quote matching [date]'s month+day.
  /// Used by QuoteNotificationService to fetch today's and tomorrow's quote.
  QuoteModel getDailyQuoteForDate(DateTime date) {
    final quote = _quotes.firstWhere(
      (q) => q.month == date.month && q.day == date.day,
      orElse: () => _quotes.first,
    );
    return quote.copyWith(isSaved: _savedBox.containsKey(quote.storageKey));
  }

  // ── All quotes ─────────────────────────────────────────────

  List<QuoteModel> getAllQuotes() {
    return _quotes.map((q) {
      return q.copyWith(isSaved: _savedBox.containsKey(q.storageKey));
    }).toList();
  }

  // ── Saved quotes ───────────────────────────────────────────

  List<QuoteModel> getSavedQuotes() => _savedBox.values.toList();

  Future<void> saveQuote(QuoteModel quote) async {
    await _savedBox.put(quote.storageKey, quote.copyWith(isSaved: true));
  }

  Future<void> unsaveQuote(QuoteModel quote) async {
    await _savedBox.delete(quote.storageKey);
  }

  bool isQuoteSaved(QuoteModel quote) =>
      _savedBox.containsKey(quote.storageKey);
}
