// lib/features/words/words_viewmodel.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/services/app_review_service.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';
import 'package:ekush_ponji/features/words/data/datasources/local/words_local_datasource.dart';
import 'package:ekush_ponji/features/words/models/word.dart';
import 'package:ekush_ponji/features/words/data/repositories/words_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WordsViewModel extends BaseViewModel {
  late final WordsRepository _repository;

  WordModel? _dailyWord;
  List<WordModel> _allWords = [];
  List<WordModel> _savedWords = [];

  WordModel? get dailyWord => _dailyWord;
  List<WordModel> get allWords => _allWords;
  List<WordModel> get savedWords => _savedWords;

  @override
  void onSyncSetup() {
    _repository = WordsRepository(
      localDatasource: WordsLocalDatasource(
        savedBox: Hive.box<WordModel>(savedWordsBoxName),
        settingsBox: Hive.box(settingsBoxName),
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    loadWords();
  }

  Future<void> loadWords() async {
    await executeAsync(
      operation: () async {
        await _repository.init();
        _dailyWord = _repository.getDailyWord();
        _allWords = _repository.getAllWords();
        _savedWords = _repository.getSavedWords();
      },
      loadingMessage: 'Loading words...',
      errorMessage: 'Failed to load words',
    );
  }

  Future<void> toggleSave(WordModel word) async {
    await executeAsync(
      operation: () async {
        await _repository.toggleSave(word);
        final isSaved = _repository.isWordSaved(word);
        _allWords = _allWords.map((w) {
          return w == word ? w.copyWith(isSaved: isSaved) : w;
        }).toList();
        if (_dailyWord == word) {
          _dailyWord = _dailyWord!.copyWith(isSaved: isSaved);
        }
        _savedWords = _repository.getSavedWords();

        // Record meaningful action when user saves a word for the first time
        if (isSaved) {
          AppReviewService.recordMeaningfulAction();
        }
      },
      showLoading: false,
      errorMessage: 'Failed to update saved words',
    );
  }

  Future<void> refreshSavedWords() async {
    _savedWords = _repository.getSavedWords();
    setSuccess();
  }

  bool isWordSaved(WordModel word) => _repository.isWordSaved(word);
}

final wordsViewModelProvider =
    NotifierProvider<WordsViewModel, ViewState>(WordsViewModel.new);

/// Exposes WordsRepository directly for use outside the viewmodel
/// (e.g. AppInitializer for notification scheduling)
final wordsRepositoryProvider = Provider<WordsRepository>((ref) {
  return WordsRepository(
    localDatasource: WordsLocalDatasource(
      savedBox: Hive.box<WordModel>(savedWordsBoxName),
      settingsBox: Hive.box(settingsBoxName),
    ),
  );
});
