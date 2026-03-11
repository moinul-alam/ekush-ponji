// lib/features/words/data/repositories/words_repository.dart

import 'package:ekush_ponji/features/words/data/datasources/local/words_local_datasource.dart';
import 'package:ekush_ponji/features/words/models/word.dart';

class WordsRepository {
  final WordsLocalDatasource _localDatasource;

  WordsRepository({required WordsLocalDatasource localDatasource})
      : _localDatasource = localDatasource;

  /// Must be called once before any other method.
  Future<void> init() => _localDatasource.init();

  /// Reload words from Hive after a sync — call when sync returns true.
  Future<void> reload() => _localDatasource.reload();

  WordModel getDailyWord() => _localDatasource.getDailyWord();

  List<WordModel> getAllWords() => _localDatasource.getAllWords();

  List<WordModel> getSavedWords() => _localDatasource.getSavedWords();

  Future<void> toggleSave(WordModel word) async {
    if (_localDatasource.isWordSaved(word)) {
      await _localDatasource.unsaveWord(word);
    } else {
      await _localDatasource.saveWord(word);
    }
  }

  bool isWordSaved(WordModel word) => _localDatasource.isWordSaved(word);
}
