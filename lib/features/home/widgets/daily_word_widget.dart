// lib/features/home/widgets/daily_word_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/words/models/word.dart';
import 'package:ekush_ponji/features/words/words_viewmodel.dart';

class DailyWordWidget extends ConsumerWidget {
  const DailyWordWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final viewState = ref.watch(wordsViewModelProvider);
    final vm = ref.read(wordsViewModelProvider.notifier);

    return Container(
      margin: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      l10n.wordOfTheDay,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.book_rounded,
                      size: 14, color: cs.onTertiaryContainer),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
            child: viewState is ViewStateLoading
                ? const Center(child: CircularProgressIndicator())
                : viewState is ViewStateError
                    ? Center(
                        child: Text(
                          l10n.failedToLoadData,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: cs.error),
                        ),
                      )
                    : _WordContent(
                        word: vm.dailyWord,
                        onOpen: () {
                          final index = vm.allWords.indexWhere(
                            (w) => w.storageKey == vm.dailyWord!.storageKey,
                          );
                          context.push(RouteNames.words,
                              extra: index < 0 ? 0 : index);
                        },
                        onToggleSave: vm.dailyWord != null
                            ? () => vm.toggleSave(vm.dailyWord!)
                            : null,
                      ),
          ),
        ],
      ),
    );
  }
}

class _WordContent extends StatelessWidget {
  final WordModel? word;
  final VoidCallback onOpen;
  final VoidCallback? onToggleSave;

  const _WordContent({this.word, required this.onOpen, this.onToggleSave});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    if (word == null) return const SizedBox.shrink();

    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.tertiaryContainer.withValues(alpha: 0.4),
              cs.primaryContainer.withValues(alpha: 0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Word + part of speech + save ──────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    word!.word,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.tertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.tertiary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    word!.partOfSpeech,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (onToggleSave != null)
                  IconButton(
                    onPressed: onToggleSave,
                    icon: Icon(
                      word!.isSaved
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: word!.isSaved ? cs.error : cs.onSurfaceVariant,
                      size: 28,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),

            const SizedBox(height: 4),

            // ── Pronunciation (with speaker icon) ─────────
            Row(
              children: [
                Icon(
                  Icons.volume_up_rounded,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  word!.pronunciation,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Bengali meaning (big) ─────────────────────
            Text(
              word!.meaningBn,
              style: theme.textTheme.titleLarge?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),
            Divider(color: cs.outline.withValues(alpha: 0.3), height: 1),
            const SizedBox(height: 16),

            // ── English meaning ───────────────────────────
            _buildSection(context,
                icon: Icons.lightbulb_outline_rounded,
                title: l10n.meaningEnglish,
                content: word!.meaningEn),
            const SizedBox(height: 14),

            // ── Synonym ───────────────────────────────────
            _buildSection(context,
                icon: Icons.sync_alt_rounded,
                title: l10n.synonym,
                content: word!.synonym),
            const SizedBox(height: 14),

            // ── Example ───────────────────────────────────
            _buildSection(context,
                icon: Icons.chat_bubble_outline_rounded,
                title: l10n.example,
                content: word!.example,
                isItalic: true),
          ],
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
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: cs.tertiary),
            const SizedBox(width: 6),
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: cs.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: cs.onSurface,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
