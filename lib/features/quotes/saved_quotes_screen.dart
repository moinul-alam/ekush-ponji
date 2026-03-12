// lib/features/quotes/saved_quotes_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';
import 'package:ekush_ponji/features/quotes/quotes_viewmodel.dart';

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
    return AppBar(
      title: Text(l10n.savedQuotes),
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(quotesViewModelProvider.notifier);

    // Re-read saved quotes on every build so unsave reflects immediately
    final savedQuotes = vm.savedQuotes;

    if (savedQuotes.isEmpty) {
      return buildEmptyWidget(
        const ViewStateEmpty('No saved quotes yet'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: savedQuotes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final quote = savedQuotes[index];
        return _SavedQuoteCard(
          quote: quote,
          onUnsave: () async {
            await vm.toggleSave(quote);
            // Trigger rebuild to reflect removal
            ref.invalidate(quotesViewModelProvider);
          },
        );
      },
    );
  }
}

// ─── Saved Quote Card ─────────────────────────────────────────
class _SavedQuoteCard extends StatelessWidget {
  final QuoteModel quote;
  final VoidCallback onUnsave;

  const _SavedQuoteCard({
    required this.quote,
    required this.onUnsave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category + unsave row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
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
                  icon: Icon(
                    Icons.favorite_rounded,
                    color: colorScheme.primary,
                  ),
                  tooltip: 'Remove from saved',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Quote text
            Text(
              quote.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            // Author
            Row(
              children: [
                Container(
                  width: 24,
                  height: 2,
                  color: colorScheme.primary,
                ),
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
    );
  }
}