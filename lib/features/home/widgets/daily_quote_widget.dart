import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/home/widgets/home_section_widget.dart';

/// Displays a daily inspirational quote
/// TODO: Replace sample data with API call or rotating quote system
class DailyQuoteWidget extends StatelessWidget {
  final Quote? quote;

  const DailyQuoteWidget({
    super.key,
    this.quote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    // Use sample quote if none provided
    final displayQuote = quote ?? _getSampleQuote();

    return HomeSectionWidget(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
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
              Text(
                l10n.quoteOfTheDay,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quote text
          Container(
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
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Opening quote mark
                Icon(
                  Icons.format_quote,
                  color: colorScheme.primary.withValues(alpha: 0.4),
                  size: 32,
                ),
                const SizedBox(height: 8),

                // Quote text
                Text(
                  displayQuote.text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 12),

                // Author
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
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
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            displayQuote.author,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Category tag if available
          if (displayQuote.category != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(
                    displayQuote.category!,
                    style: theme.textTheme.bodySmall,
                  ),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // TODO: Replace with API call or daily rotation logic
  Quote _getSampleQuote() {
    // Sample quotes pool
    final quotes = [
      Quote(
        text: 'The only way to do great work is to love what you do.',
        author: 'Steve Jobs',
        category: 'Motivation',
      ),
      Quote(
        text:
            'Success is not final, failure is not fatal: it is the courage to continue that counts.',
        author: 'Winston Churchill',
        category: 'Success',
      ),
      Quote(
        text: 'Believe you can and you\'re halfway there.',
        author: 'Theodore Roosevelt',
        category: 'Inspiration',
      ),
      Quote(
        text:
            'The future belongs to those who believe in the beauty of their dreams.',
        author: 'Eleanor Roosevelt',
        category: 'Dreams',
      ),
      Quote(
        text:
            'It does not matter how slowly you go as long as you do not stop.',
        author: 'Confucius',
        category: 'Perseverance',
      ),
    ];

    // Return quote based on day of year (so it changes daily)
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return quotes[dayOfYear % quotes.length];
  }
}

// Models
class Quote {
  final String text;
  final String author;
  final String? category;

  Quote({
    required this.text,
    required this.author,
    this.category,
  });

  // TODO: Add fromJson factory for API integration
  // factory Quote.fromJson(Map<String, dynamic> json) {
  //   return Quote(
  //     text: json['text'],
  //     author: json['author'],
  //     category: json['category'],
  //   );
  // }
}
