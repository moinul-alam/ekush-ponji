// lib/data/datasources/local/words_local_datasource.dart

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekush_ponji/features/words/models/word.dart';

const String savedWordsBoxName = 'saved_words';

class WordsLocalDatasource {
  final Box<WordModel> _savedBox;

  List<WordModel>? _cachedWords;

  WordsLocalDatasource({required Box<WordModel> savedBox})
      : _savedBox = savedBox;

  // ── Asset loading ──────────────────────────────────────────

  Future<void> init() async {
    if (_cachedWords != null) return;
    await _loadWords();
  }

  Future<void> _loadWords() async {
    final jsonString =
        await rootBundle.loadString('assets/data/words/words_en.json');
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

  /// Returns the word assigned to today's month + day.
  /// Falls back to the first word if no match is found.
  WordModel getDailyWord() {
    final today = DateTime.now();
    final word = _words.firstWhere(
      (w) => w.month == today.month && w.day == today.day,
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

  List<WordModel> getSavedWords() {
    return _savedBox.values.toList();
  }

  Future<void> saveWord(WordModel word) async {
    final saved = word.copyWith(isSaved: true);
    await _savedBox.put(saved.storageKey, saved);
  }

  Future<void> unsaveWord(WordModel word) async {
    await _savedBox.delete(word.storageKey);
  }

  bool isWordSaved(WordModel word) {
    return _savedBox.containsKey(word.storageKey);
  }
}
