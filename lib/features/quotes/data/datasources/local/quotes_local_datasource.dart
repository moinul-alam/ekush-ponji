// lib/data/datasources/local/quotes_local_datasource.dart

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';

const String savedQuotesBoxName = 'saved_quotes';

class QuotesLocalDatasource {
  final Box<QuoteModel> _savedBox;

  // In-memory cache so we only parse the JSON once per session
  List<QuoteModel>? _cachedQuotes;

  QuotesLocalDatasource({required Box<QuoteModel> savedBox})
      : _savedBox = savedBox;

  // ── Asset loading ──────────────────────────────────────────

  /// Loads and caches all quotes from the JSON asset.
  /// Call this once at startup (e.g. in your provider/repository init).
  Future<void> init() async {
    if (_cachedQuotes != null) return;
    await _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    final jsonString =
        await rootBundle.loadString('assets/data/quotes/quotes_en.json');
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

  /// Returns the quote assigned to today's month + day.
  /// Falls back to the first quote if no match is found.
  QuoteModel getDailyQuote() {
    final today = DateTime.now();
    final quote = _quotes.firstWhere(
      (q) => q.month == today.month && q.day == today.day,
      orElse: () => _quotes.first,
    );
    final key = quote.storageKey;
    return quote.copyWith(isSaved: _savedBox.containsKey(key));
  }

  // ── All quotes ─────────────────────────────────────────────

  /// Returns all quotes with saved state resolved.
  List<QuoteModel> getAllQuotes() {
    return _quotes.map((q) {
      return q.copyWith(isSaved: _savedBox.containsKey(q.storageKey));
    }).toList();
  }

  // ── Saved quotes ───────────────────────────────────────────

  /// Returns all saved quotes from Hive.
  List<QuoteModel> getSavedQuotes() {
    return _savedBox.values.toList();
  }

  /// Save a quote to Hive.
  Future<void> saveQuote(QuoteModel quote) async {
    final saved = quote.copyWith(isSaved: true);
    await _savedBox.put(saved.storageKey, saved);
  }

  /// Remove a quote from saved.
  Future<void> unsaveQuote(QuoteModel quote) async {
    await _savedBox.delete(quote.storageKey);
  }

  /// Check if a quote is saved.
  bool isQuoteSaved(QuoteModel quote) {
    return _savedBox.containsKey(quote.storageKey);
  }
}
