import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/home/widgets/home_section_widget.dart';

/// Displays a daily word with its meaning and usage
/// TODO: Replace sample data with API call or rotating word system
class DailyWordWidget extends StatelessWidget {
  final DailyWord? word;

  const DailyWordWidget({
    super.key,
    this.word,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use sample word if none provided
    final displayWord = word ?? _getSampleWord();

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
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.book_rounded,
                  color: colorScheme.tertiary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Word of the Day',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Word container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.tertiaryContainer.withValues(alpha: 0.4),
                  colorScheme.primaryContainer.withValues(alpha: 0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The word itself
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayWord.word,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.tertiary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (displayWord.pronunciation != null)
                            Text(
                              displayWord.pronunciation!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Part of speech badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        displayWord.partOfSpeech,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Divider
                Divider(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  height: 1,
                ),

                const SizedBox(height: 16),

                // Meaning
                _buildSection(
                  context,
                  icon: Icons.lightbulb_outline_rounded,
                  title: 'Meaning',
                  content: displayWord.meaning,
                ),

                if (displayWord.synonym != null) ...[
                  const SizedBox(height: 12),
                  _buildSection(
                    context,
                    icon: Icons.sync_alt_rounded,
                    title: 'Synonym',
                    content: displayWord.synonym!,
                  ),
                ],

                if (displayWord.example != null) ...[
                  const SizedBox(height: 12),
                  _buildSection(
                    context,
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Example',
                    content: displayWord.example!,
                    isItalic: true,
                  ),
                ],
              ],
            ),
          ),
        ],
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
            Icon(
              icon,
              size: 16,
              color: colorScheme.tertiary,
            ),
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

  // TODO: Replace with API call or daily rotation logic
  DailyWord _getSampleWord() {
    // Sample words pool
    final words = [
      DailyWord(
        word: 'Serendipity',
        pronunciation: '/ˌserənˈdipədē/',
        partOfSpeech: 'noun',
        meaning:
            'The occurrence of events by chance in a happy or beneficial way.',
        synonym: 'Luck, fortune, chance',
        example:
            'A fortunate stroke of serendipity brought the two old friends together after many years.',
      ),
      DailyWord(
        word: 'Eloquent',
        pronunciation: '/ˈeləkwənt/',
        partOfSpeech: 'adjective',
        meaning: 'Fluent or persuasive in speaking or writing.',
        synonym: 'Articulate, expressive, fluent',
        example:
            'The lawyer made an eloquent plea for his client\'s innocence.',
      ),
      DailyWord(
        word: 'Resilient',
        pronunciation: '/rɪˈzɪliənt/',
        partOfSpeech: 'adjective',
        meaning:
            'Able to withstand or recover quickly from difficult conditions.',
        synonym: 'Strong, tough, hardy',
        example:
            'The community showed resilient spirit in rebuilding after the disaster.',
      ),
      DailyWord(
        word: 'Ephemeral',
        pronunciation: '/ɪˈfem(ə)rəl/',
        partOfSpeech: 'adjective',
        meaning: 'Lasting for a very short time.',
        synonym: 'Fleeting, transient, momentary',
        example:
            'The beauty of cherry blossoms is ephemeral, lasting only a few weeks.',
      ),
      DailyWord(
        word: 'Ubiquitous',
        pronunciation: '/yo͞oˈbikwədəs/',
        partOfSpeech: 'adjective',
        meaning: 'Present, appearing, or found everywhere.',
        synonym: 'Omnipresent, pervasive, universal',
        example: 'Smartphones have become ubiquitous in modern society.',
      ),
    ];

    // Return word based on day of year (so it changes daily)
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return words[dayOfYear % words.length];
  }
}

// Models
class DailyWord {
  final String word;
  final String? pronunciation;
  final String partOfSpeech;
  final String meaning;
  final String? synonym;
  final String? example;

  DailyWord({
    required this.word,
    this.pronunciation,
    required this.partOfSpeech,
    required this.meaning,
    this.synonym,
    this.example,
  });

  // TODO: Add fromJson factory for API integration
  // factory DailyWord.fromJson(Map<String, dynamic> json) {
  //   return DailyWord(
  //     word: json['word'],
  //     pronunciation: json['pronunciation'],
  //     partOfSpeech: json['part_of_speech'],
  //     meaning: json['meaning'],
  //     synonym: json['synonym'],
  //     example: json['example'],
  //   );
  // }
}
