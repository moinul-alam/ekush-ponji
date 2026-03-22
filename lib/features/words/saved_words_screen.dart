// lib/features/words/saved_words_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/widgets/ads/native_ad_widget.dart';
import 'package:ekush_ponji/features/words/models/word.dart';
import 'package:ekush_ponji/features/words/words_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';

class SavedWordsScreen extends BaseScreen {
  const SavedWordsScreen({super.key});

  @override
  BaseScreenState createState() => _SavedWordsScreenState();
}

class _SavedWordsScreenState extends BaseScreenState<SavedWordsScreen> {
  @override
  NotifierProvider<dynamic, ViewState> get viewModelProvider =>
      wordsViewModelProvider;

  @override
  bool get showLoadingOverlay => false;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppHeader(pageTitle: l10n.savedWords);
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final vm = ref.watch(wordsViewModelProvider.notifier);
    final savedWords = vm.savedWords;

    if (savedWords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noSavedWords,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final now = DateTime.now();
                final words = vm.allWords;
                final index = words.indexWhere(
                  (w) => w.month == now.month && w.day == now.day,
                );
                context.push(RouteNames.words, extra: index < 0 ? 0 : index);
              },
              icon: const Icon(Icons.menu_book_rounded),
              label: Text(l10n.wordOfTheDay),
            ),
          ],
        ),
      );
    }

    // Build list with native ad injected after the 3rd word
    final items = <Widget>[];
    for (int i = 0; i < savedWords.length; i++) {
      final word = savedWords[i];
      items.add(_SavedWordCard(
        word: word,
        onUnsave: () async {
          await vm.toggleSave(word);
          ref.invalidate(wordsViewModelProvider);
        },
      ));

      // Inject native ad after the 3rd word (index 2)
      if (i == 2) {
        items.add(const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: NativeAdWidget(style: NativeAdStyle.card),
        ));
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: items,
    );
  }
}

class _SavedWordCard extends StatelessWidget {
  final WordModel word;
  final VoidCallback onUnsave;

  const _SavedWordCard({required this.word, required this.onUnsave});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  IconButton(
                    onPressed: onUnsave,
                    icon: Icon(Icons.favorite_rounded,
                        color: colorScheme.primary),
                    tooltip: 'Remove from saved',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                word.word,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                word.pronunciation,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Divider(
                  color: colorScheme.outline.withValues(alpha: 0.3), height: 1),
              const SizedBox(height: 12),
              _buildSection(context,
                  icon: Icons.lightbulb_outline_rounded,
                  title: l10n.meaningEnglish,
                  content: word.meaningEn),
              const SizedBox(height: 4),
              _buildSection(context,
                  icon: Icons.translate_rounded,
                  title: 'অর্থ',
                  content: word.meaningBn),
              const SizedBox(height: 10),
              _buildSection(context,
                  icon: Icons.sync_alt_rounded,
                  title: l10n.synonym,
                  content: word.synonym),
              const SizedBox(height: 10),
              _buildSection(context,
                  icon: Icons.chat_bubble_outline_rounded,
                  title: l10n.example,
                  content: word.example,
                  isItalic: true),
            ],
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: colorScheme.tertiary),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$title: ',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: content,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
