// lib/features/words/data/datasources/local/words_local_datasource.dart
//
// CHANGED: added getDailyWordForDate(DateTime) for word notification service

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ekush_ponji/features/words/models/word.dart';
import 'package:ekush_ponji/features/words/services/words_sync_service.dart';

const String savedWordsBoxName = 'saved_words';

class WordsLocalDatasource {
  final Box<WordModel> _savedBox;
  final Box _settingsBox;

  List<WordModel>? _cachedWords;

  WordsLocalDatasource({
    required Box<WordModel> savedBox,
    required Box settingsBox,
  })  : _savedBox = savedBox,
        _settingsBox = settingsBox;

  // ── Initialisation ─────────────────────────────────────────

  Future<void> init() async {
    if (_cachedWords != null) return;
    await _loadWords();
  }

  Future<void> reload() async {
    _cachedWords = null;
    await _loadWords();
  }

  Future<void> _loadWords() async {
    final String jsonString;

    final hiveCached = _settingsBox.get(WordsSyncService.wordsEnKey) as String?;

    if (hiveCached != null && hiveCached.isNotEmpty) {
      jsonString = hiveCached;
    } else {
      jsonString =
          await rootBundle.loadString('assets/data/words/words_en.json');
    }

    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final List<dynamic> rawList = jsonMap['words'] as List<dynamic>;

    _cachedWords = rawList.map((raw) {
      final map = raw as Map<String, dynamic>;
      final key = (map['word'] as String).toLowerCase();
      return WordModel.fromJson(map, isSaved: _savedBox.containsKey(key));
    }).toList();
  }

  List<WordModel> get _words {
    assert(
      _cachedWords != null,
      'WordsLocalDatasource.init() must be awaited before use.',
    );
    return _cachedWords!;
  }

  // ── Daily word ─────────────────────────────────────────────

  /// Returns the word for today's date.
  WordModel getDailyWord() {
    return getDailyWordForDate(DateTime.now());
  }

  /// Returns the word matching [date]'s month+day.
  /// Used by WordNotificationService to fetch today's and tomorrow's word.
  WordModel getDailyWordForDate(DateTime date) {
    final word = _words.firstWhere(
      (w) => w.month == date.month && w.day == date.day,
      orElse: () => _words.first,
    );
    return word.copyWith(isSaved: _savedBox.containsKey(word.storageKey));
  }

  // ── All words ──────────────────────────────────────────────

  List<WordModel> getAllWords() {
    return _words.map((w) {
      return w.copyWith(isSaved: _savedBox.containsKey(w.storageKey));
    }).toList();
  }

  // ── Saved words ────────────────────────────────────────────

  List<WordModel> getSavedWords() => _savedBox.values.toList();

  Future<void> saveWord(WordModel word) async {
    await _savedBox.put(word.storageKey, word.copyWith(isSaved: true));
  }

  Future<void> unsaveWord(WordModel word) async {
    await _savedBox.delete(word.storageKey);
  }

  bool isWordSaved(WordModel word) => _savedBox.containsKey(word.storageKey);
}
