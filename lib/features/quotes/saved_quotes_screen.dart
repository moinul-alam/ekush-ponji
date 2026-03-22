// lib/features/quotes/saved_quotes_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/widgets/ads/native_ad_widget.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';
import 'package:ekush_ponji/features/quotes/quotes_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';

class SavedQuotesScreen extends BaseScreen {
  const SavedQuotesScreen({super.key});

  @override
  BaseScreenState createState() => _SavedQuotesScreenState();
}

class _SavedQuotesScreenState extends BaseScreenState<SavedQuotesScreen> {
  @override
  NotifierProvider<dynamic, ViewState> get viewModelProvider =>
      quotesViewModelProvider;

  @override
  bool get showLoadingOverlay => false;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppHeader(pageTitle: l10n.savedQuotes);
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final vm = ref.watch(quotesViewModelProvider.notifier);
    final savedQuotes = vm.savedQuotes;

    if (savedQuotes.isEmpty) {
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
              l10n.noSavedQuotes,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final now = DateTime.now();
                final quotes = vm.allQuotes;
                final index = quotes.indexWhere(
                  (q) => q.month == now.month && q.day == now.day,
                );
                context.push(RouteNames.quotes, extra: index < 0 ? 0 : index);
              },
              icon: const Icon(Icons.format_quote_rounded),
              label: Text(l10n.quoteOfTheDay),
            ),
          ],
        ),
      );
    }

    // Build list with native ad injected after the 3rd quote
    final items = <Widget>[];
    for (int i = 0; i < savedQuotes.length; i++) {
      final quote = savedQuotes[i];
      items.add(_SavedQuoteCard(
        quote: quote,
        onUnsave: () async {
          await vm.toggleSave(quote);
          ref.invalidate(quotesViewModelProvider);
        },
      ));

      // Inject native ad after the 3rd quote (index 2)
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

class _SavedQuoteCard extends StatelessWidget {
  final QuoteModel quote;
  final VoidCallback onUnsave;

  const _SavedQuoteCard({required this.quote, required this.onUnsave});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      quote.category,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
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
              const SizedBox(height: 12),
              Text(
                quote.text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(width: 24, height: 2, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    quote.author,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
