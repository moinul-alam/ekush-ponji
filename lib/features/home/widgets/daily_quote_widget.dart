// lib/features/home/widgets/daily_quote_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';
import 'package:ekush_ponji/features/quotes/quotes_viewmodel.dart';

class DailyQuoteWidget extends ConsumerWidget {
  const DailyQuoteWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final viewState = ref.watch(quotesViewModelProvider);
    final vm = ref.read(quotesViewModelProvider.notifier);

    return Container(
      margin: const EdgeInsets.fromLTRB(4, 1, 4, 1),
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
                      l10n.quoteOfTheDay,
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
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.format_quote_rounded,
                      size: 14, color: cs.onPrimaryContainer),
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
                    : _QuoteContent(
                        quote: vm.dailyQuote,
                        onOpen: () {
                          final index = vm.allQuotes.indexWhere(
                            (q) => q.storageKey == vm.dailyQuote!.storageKey,
                          );
                          context.push(RouteNames.quotes,
                              extra: index < 0 ? 0 : index);
                        },
                        onToggleSave: vm.dailyQuote != null
                            ? () => vm.toggleSave(vm.dailyQuote!)
                            : null,
                      ),
          ),
        ],
      ),
    );
  }
}

class _QuoteContent extends StatelessWidget {
  final QuoteModel? quote;
  final VoidCallback onOpen;
  final VoidCallback? onToggleSave;

  const _QuoteContent({this.quote, required this.onOpen, this.onToggleSave});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (quote == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.secondaryContainer.withValues(alpha: 0.3),
            cs.tertiaryContainer.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.format_quote,
                  color: cs.primary.withValues(alpha: 0.4), size: 32),
              if (onToggleSave != null)
                IconButton(
                  onPressed: onToggleSave,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    quote!.isSaved
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: quote!.isSaved ? cs.error : cs.onSurfaceVariant,
                    size: 28,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                quote!.text,
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurface,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    fontWeight: FontWeight.w800,
                    fontSize: 20),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // --- FIXED SECTION START ---
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min, // Ensures container doesn't stretch
                children: [
                  Icon(Icons.person_outline, size: 14, color: cs.primary),
                  const SizedBox(width: 6),
                  Text(
                    quote!.author,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // --- FIXED SECTION END ---
        ],
      ),
    );
  }
}
