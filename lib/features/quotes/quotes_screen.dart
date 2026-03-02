// lib/features/quotes/quotes_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/features/quotes/models/quote.dart';
import 'package:ekush_ponji/features/quotes/quotes_viewmodel.dart';

class QuotesScreen extends BaseScreen {
  const QuotesScreen({super.key});

  @override
  BaseScreenState createState() => _QuotesScreenState();
}

class _QuotesScreenState extends BaseScreenState<QuotesScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<Offset> _slideOutAnimation;
  late Animation<Offset> _slideInAnimation;
  bool _isAnimating = false;
  bool _slideFromRight = true; // true = next, false = previous

  @override
  NotifierProvider<dynamic, ViewState> get viewModelProvider =>
      quotesViewModelProvider;

  @override
  void onScreenInit() {
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

  Future<void> _goToNext(List<QuoteModel> quotes) async {
    if (_isAnimating || _currentIndex >= quotes.length - 1) return;
    _isAnimating = true;
    _setupAnimations(fromRight: true);
    _animationController.reset();
    await _animationController.forward();
    setState(() => _currentIndex++);
    _animationController.reset();
    _isAnimating = false;
  }

  Future<void> _goToPrevious(List<QuoteModel> quotes) async {
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
      title: Text(l10n.quoteOfTheDay),
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_outline_rounded),
          tooltip: l10n.savedQuotes,
          onPressed: () => context.push(RouteNames.savedQuotes),
        ),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(quotesViewModelProvider);
    final vm = ref.read(quotesViewModelProvider.notifier);

    if (viewState is ViewStateLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final quotes = vm.allQuotes;
    if (quotes.isEmpty) {
      return buildEmptyWidget(
        const ViewStateEmpty('No quotes available'),
      );
    }

    // Clamp index safety
    if (_currentIndex >= quotes.length) {
      _currentIndex = quotes.length - 1;
    }

    final quote = quotes[_currentIndex];

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -300) {
          _goToNext(quotes);
        } else if (details.primaryVelocity! > 300) {
          _goToPrevious(quotes);
        }
      },
      child: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_currentIndex + 1} / ${quotes.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  _swipeHintText(context),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),

          // Animated card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  // During animation: slide out old, slide in new
                  final isForwarding = _animationController.isAnimating;
                  return Stack(
                    children: [
                      if (isForwarding)
                        SlideTransition(
                          position: _slideOutAnimation,
                          child: _QuoteCard(
                            quote: quote,
                            onToggleSave: () => vm.toggleSave(quote),
                          ),
                        ),
                      if (isForwarding)
                        SlideTransition(
                          position: _slideInAnimation,
                          child: _QuoteCard(
                            quote: quotes[_slideFromRight
                                ? (_currentIndex < quotes.length - 1
                                    ? _currentIndex + 1
                                    : _currentIndex)
                                : (_currentIndex > 0
                                    ? _currentIndex - 1
                                    : _currentIndex)],
                            onToggleSave: () => vm.toggleSave(quote),
                          ),
                        ),
                      if (!isForwarding)
                        _QuoteCard(
                          quote: quote,
                          onToggleSave: () => vm.toggleSave(quote),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Navigation arrows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.outlined(
                  onPressed: _currentIndex > 0
                      ? () => _goToPrevious(quotes)
                      : null,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  tooltip: AppLocalizations.of(context).previous,
                ),
                // Dot indicators (max 5 visible)
                _DotIndicator(
                  total: quotes.length,
                  current: _currentIndex,
                ),
                IconButton.outlined(
                  onPressed: _currentIndex < quotes.length - 1
                      ? () => _goToNext(quotes)
                      : null,
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  tooltip: AppLocalizations.of(context).next,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _swipeHintText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return '← ${l10n.previous}  |  ${l10n.next} →';
  }
}

// ─── Quote Card ───────────────────────────────────────────────
class _QuoteCard extends StatelessWidget {
  final QuoteModel quote;
  final VoidCallback onToggleSave;

  const _QuoteCard({
    required this.quote,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                colorScheme.secondaryContainer.withValues(alpha: 0.4),
                colorScheme.tertiaryContainer.withValues(alpha: 0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category + bookmark row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
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
                    onPressed: onToggleSave,
                    icon: Icon(
                      quote.isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      color: quote.isSaved
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    tooltip: quote.isSaved ? 'Unsave' : 'Save',
                  ),
                ],
              ),

              const Spacer(),

              // Opening quote mark
              Icon(
                Icons.format_quote_rounded,
                color: colorScheme.primary.withValues(alpha: 0.3),
                size: 48,
              ),

              const SizedBox(height: 12),

              // Quote text
              Text(
                quote.text,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ),

              const Spacer(),

              // Author
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 2,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    quote.author,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Dot Indicator ────────────────────────────────────────────
class _DotIndicator extends StatelessWidget {
  final int total;
  final int current;

  const _DotIndicator({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const maxDots = 5;
    final visibleCount = total.clamp(0, maxDots);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(visibleCount, (i) {
        final isActive = i == current.clamp(0, maxDots - 1);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}