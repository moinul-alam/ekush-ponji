// lib/data/datasources/local/words_local_datasource.dart

import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekush_ponji/core/data/dailyWordsEn.dart';
import 'package:ekush_ponji/features/words/models/word.dart';

const String savedWordsBoxName = 'saved_words';

class WordsLocalDatasource {
  final Box<WordModel> _savedBox;

  WordsLocalDatasource({required Box<WordModel> savedBox})
      : _savedBox = savedBox;

  /// Returns today's word seeded by date so it's consistent all day
  WordModel getDailyWord() {
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final random = Random(seed);
    final index = random.nextInt(dailyWordsEn.length);
    final enWord = dailyWordsEn[index];
    final key = enWord.word.toLowerCase();

    return WordModel(
      word: enWord.word,
      partOfSpeech: enWord.partOfSpeech,
      meaningEn: enWord.meaningEn,
      meaningBn: enWord.meaningBn,
      synonym: enWord.synonym,
      example: enWord.example,
      pronunciation: enWord.pronunciation,
      isSaved: _savedBox.containsKey(key),
    );
  }

  /// Returns all words from the data list, with saved state resolved
  List<WordModel> getAllWords() {
    return dailyWordsEn.map((enWord) {
      final key = enWord.word.toLowerCase();
      return WordModel(
        word: enWord.word,
        partOfSpeech: enWord.partOfSpeech,
        meaningEn: enWord.meaningEn,
        meaningBn: enWord.meaningBn,
        synonym: enWord.synonym,
        example: enWord.example,
        pronunciation: enWord.pronunciation,
        isSaved: _savedBox.containsKey(key),
      );
    }).toList();
  }

  /// Returns all saved words from Hive
  List<WordModel> getSavedWords() {
    return _savedBox.values.toList();
  }

  /// Save a word to Hive
  Future<void> saveWord(WordModel word) async {
    final saved = word.copyWith(isSaved: true);
    await _savedBox.put(saved.storageKey, saved);
  }

  /// Remove a word from saved
  Future<void> unsaveWord(WordModel word) async {
    await _savedBox.delete(word.storageKey);
  }

  /// Check if a word is saved
  bool isWordSaved(WordModel word) {
    return _savedBox.containsKey(word.storageKey);
  }
}