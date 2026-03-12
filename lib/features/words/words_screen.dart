// lib/features/words/words_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/features/words/models/word.dart';
import 'package:ekush_ponji/features/words/words_viewmodel.dart';
import 'package:ekush_ponji/features/words/widgets/word_share_card.dart';
import 'package:ekush_ponji/core/services/share_service.dart';

class WordsScreen extends BaseScreen {
  final int initialIndex;

  const WordsScreen({super.key, this.initialIndex = 0});

  @override
  BaseScreenState createState() => _WordsScreenState();
}

class _WordsScreenState extends BaseScreenState<WordsScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animationController;
  late Animation<Offset> _slideOutAnimation;
  late Animation<Offset> _slideInAnimation;
  bool _isAnimating = false;
  bool _slideFromRight = true;

  @override
  NotifierProvider<dynamic, ViewState> get viewModelProvider =>
      wordsViewModelProvider;

  @override
  void onScreenInit() {
    _currentIndex = widget.initialIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _setupAnimations(fromRight: true);
  }

  @override
  void onScreenDispose() {
    _animationController.dispose();
  }

  void _setupAnimations({required bool fromRight}) {
    _slideFromRight = fromRight;

    _slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(fromRight ? -1.2 : 1.2, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInCubic,
    ));

    _slideInAnimation = Tween<Offset>(
      begin: Offset(fromRight ? 1.2 : -1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  Future<void> _goToNext(List<WordModel> words) async {
    if (_isAnimating || _currentIndex >= words.length - 1) return;
    _isAnimating = true;
    _setupAnimations(fromRight: true);
    _animationController.reset();
    await _animationController.forward();
    setState(() => _currentIndex++);
    _animationController.reset();
    _isAnimating = false;
  }

  Future<void> _goToPrevious(List<WordModel> words) async {
    if (_isAnimating || _currentIndex <= 0) return;
    _isAnimating = true;
    _setupAnimations(fromRight: false);
    _animationController.reset();
    await _animationController.forward();
    setState(() => _currentIndex--);
    _animationController.reset();
    _isAnimating = false;
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.pop(),
      ),
      title: Text(l10n.wordOfTheDay),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border_rounded),
          tooltip: l10n.savedWords,
          onPressed: () => context.push(RouteNames.savedWords),
        ),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(wordsViewModelProvider);
    final vm = ref.read(wordsViewModelProvider.notifier);

    if (viewState is ViewStateLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final words = vm.allWords;
    if (words.isEmpty) {
      return buildEmptyWidget(const ViewStateEmpty('No words available'));
    }

    if (_currentIndex >= words.length) {
      _currentIndex = words.length - 1;
    }

    final word = words[_currentIndex];
    final canGoPrev = _currentIndex > 0;
    final canGoNext = _currentIndex < words.length - 1;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -300) {
          _goToNext(words);
        } else if (details.primaryVelocity! > 300) {
          _goToPrevious(words);
        }
      },
      child: Stack(
        children: [
          // ── Animated card ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final isForwarding = _animationController.isAnimating;
                return Stack(
                  children: [
                    if (isForwarding)
                      SlideTransition(
                        position: _slideOutAnimation,
                        child: _WordCard(
                          word: word,
                          onToggleSave: () => vm.toggleSave(word),
                        ),
                      ),
                    if (isForwarding)
                      SlideTransition(
                        position: _slideInAnimation,
                        child: _WordCard(
                          word: words[_slideFromRight
                              ? (_currentIndex < words.length - 1
                                  ? _currentIndex + 1
                                  : _currentIndex)
                              : (_currentIndex > 0
                                  ? _currentIndex - 1
                                  : _currentIndex)],
                          onToggleSave: () => vm.toggleSave(word),
                        ),
                      ),
                    if (!isForwarding)
                      _WordCard(
                        word: word,
                        onToggleSave: () => vm.toggleSave(word),
                      ),
                  ],
                );
              },
            ),
          ),

          // ── Floating prev arrow ────────────────────────────────
          if (canGoPrev)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => _goToPrevious(words),
                  child: Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

          // ── Floating next arrow ────────────────────────────────
          if (canGoNext)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => _goToNext(words),
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Word Card ────────────────────────────────────────────────
class _WordCard extends StatelessWidget {
  final WordModel word;
  final VoidCallback onToggleSave;

  const _WordCard({required this.word, required this.onToggleSave});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Card(
        elevation: 3,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                colorScheme.tertiaryContainer.withValues(alpha: 0.4),
                colorScheme.primaryContainer.withValues(alpha: 0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Part of speech badge + actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        word.partOfSpeech,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => ShareService.shareWidget(
                            widget: WordShareCard(word: word),
                            fileBaseName:
                                'ekush_ponji_word_${word.storageKey}',
                          ),
                          icon: Icon(Icons.share_rounded,
                              color: colorScheme.onSurfaceVariant),
                          tooltip: l10n.share,
                        ),
                        IconButton(
                          onPressed: onToggleSave,
                          icon: Icon(
                            word.isSaved
                                ? Icons.favorite_rounded
                                : Icons.favorite_outline_rounded,
                            color: word.isSaved
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                          tooltip: word.isSaved ? 'Unsave' : 'Save',
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Word + pronunciation
                Text(
                  word.word,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  word.pronunciation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 20),

                Divider(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    height: 1),

                const SizedBox(height: 20),

                _buildSection(context,
                    icon: Icons.lightbulb_outline_rounded,
                    title: l10n.meaningEnglish,
                    content: word.meaningEn),
                const SizedBox(height: 4),
                _buildSection(context,
                    icon: Icons.translate_rounded,
                    title: l10n.meaningBengali,
                    content: word.meaningBn),
                const SizedBox(height: 16),
                _buildSection(context,
                    icon: Icons.sync_alt_rounded,
                    title: l10n.synonym,
                    content: word.synonym),
                const SizedBox(height: 16),
                _buildSection(context,
                    icon: Icons.chat_bubble_outline_rounded,
                    title: l10n.example,
                    content: word.example,
                    isItalic: true),

                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Ekush Ponji',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.55),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    bool isItalic = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: colorScheme.tertiary),
            const SizedBox(width: 6),
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}