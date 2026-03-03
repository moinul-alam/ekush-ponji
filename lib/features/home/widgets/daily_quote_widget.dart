// lib/features/home/widgets/daily_quote_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';
import 'package:ekush_ponji/features/home/widgets/home_section_widget.dart';
import 'package:ekush_ponji/features/quotes/quotes_viewmodel.dart';

class DailyQuoteWidget extends ConsumerWidget {
  const DailyQuoteWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final viewState = ref.watch(quotesViewModelProvider);
    final vm = ref.read(quotesViewModelProvider.notifier);

    return HomeSectionWidget(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.format_quote_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.quoteOfTheDay,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Content
          if (viewState is ViewStateLoading)
            const Center(child: CircularProgressIndicator())
          else if (viewState is ViewStateError)
            Center(
              child: Text(
                l10n.failedToLoadData,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            )
          else
            _QuoteContent(
              quote: vm.dailyQuote,
              onOpen: () => context.push(RouteNames.quotes),
              onToggleSave: vm.dailyQuote != null
                  ? () => vm.toggleSave(vm.dailyQuote!)
                  : null,
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
    final colorScheme = theme.colorScheme;

    if (quote == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.secondaryContainer.withValues(alpha: 0.3),
            colorScheme.tertiaryContainer.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote,
            color: colorScheme.primary.withValues(alpha: 0.4),
            size: 32,
          ),
          const SizedBox(height: 8),

          // Quote text
          InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                quote!.text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Author + bookmark
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline,
                        size: 14, color: colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      quote!.author,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onToggleSave != null)
                IconButton(
                  onPressed: onToggleSave,
                  icon: Icon(
                    quote!.isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: quote!.isSaved
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),

          // Category chip
          if (quote!.category.isNotEmpty) ...[
            const SizedBox(height: 10),
            Chip(
              label: Text(
                quote!.category,
                style: theme.textTheme.bodySmall,
              ),
              backgroundColor: colorScheme.surfaceContainerHighest,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ],
      ),
    );
  }
}