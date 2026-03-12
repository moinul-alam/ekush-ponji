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
import 'package:ekush_ponji/features/quotes/widgets/quote_share_card.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekush_ponji/core/services/share_service.dart';

class QuotesScreen extends BaseScreen {
  /// When navigating from home, pass the daily quote's index so the screen
  /// opens directly on that quote instead of always starting at index 0.
  final int initialIndex;

  const QuotesScreen({super.key, this.initialIndex = 0});

  @override
  BaseScreenState createState() => _QuotesScreenState();
}

class _QuotesScreenState extends BaseScreenState<QuotesScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animationController;
  late Animation<Offset> _slideOutAnimation;
  late Animation<Offset> _slideInAnimation;
  bool _isAnimating = false;
  bool _slideFromRight = true;
  double _quoteFontScale = 1.0;

  @override
  NotifierProvider<dynamic, ViewState> get viewModelProvider =>
      quotesViewModelProvider;

  @override
  void onScreenInit() {
    _currentIndex = widget.initialIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _setupAnimations(fromRight: true);
    _loadQuoteFontScale();
  }

  @override
  void onScreenDispose() {
    _animationController.dispose();
  }

  Future<void> _loadQuoteFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getDouble('quote_font_scale') ?? 1.0;
    if (!mounted) return;
    setState(() => _quoteFontScale = v.clamp(0.8, 1.6));
  }

  Future<void> _saveQuoteFontScale(double v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('quote_font_scale', v);
  }

  void _showFontSizeSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.adjustFontSize,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('A', style: Theme.of(context).textTheme.bodyMedium),
                  Expanded(
                    child: Slider(
                      value: _quoteFontScale,
                      min: 0.8,
                      max: 1.6,
                      divisions: 8,
                      onChanged: (v) => setState(() => _quoteFontScale = v),
                      onChangeEnd: _saveQuoteFontScale,
                    ),
                  ),
                  Text(
                    'A',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
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
      // Back button is shown automatically because this screen is pushed
      // onto the navigator stack via context.pushNamed()
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.pop(),
      ),
      title: Text(l10n.quoteOfTheDay),
      actions: [
        IconButton(
          icon: const Icon(Icons.text_fields_rounded),
          tooltip: l10n.adjustFontSize,
          onPressed: () => _showFontSizeSheet(context),
        ),
        IconButton(
          icon: const Icon(Icons.favorite_outline_rounded),
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
      return buildEmptyWidget(const ViewStateEmpty('No quotes available'));
    }

    if (_currentIndex >= quotes.length) {
      _currentIndex = quotes.length - 1;
    }

    final quote = quotes[_currentIndex];
    final canGoPrev = _currentIndex > 0;
    final canGoNext = _currentIndex < quotes.length - 1;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -300) {
          _goToNext(quotes);
        } else if (details.primaryVelocity! > 300) {
          _goToPrevious(quotes);
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
                        child: _QuoteCard(
                          quote: quote,
                          onToggleSave: () => vm.toggleSave(quote),
                          quoteFontScale: _quoteFontScale,
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
                          quoteFontScale: _quoteFontScale,
                        ),
                      ),
                    if (!isForwarding)
                      _QuoteCard(
                        quote: quote,
                        onToggleSave: () => vm.toggleSave(quote),
                        quoteFontScale: _quoteFontScale,
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
                  onTap: () => _goToPrevious(quotes),
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
                  onTap: () => _goToNext(quotes),
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

// ─── Quote Card ───────────────────────────────────────────────
class _QuoteCard extends StatelessWidget {
  final QuoteModel quote;
  final VoidCallback onToggleSave;
  final double quoteFontScale;

  const _QuoteCard({
    required this.quote,
    required this.onToggleSave,
    required this.quoteFontScale,
  });

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
              // Category + actions
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
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => ShareService.shareWidget(
                          widget: QuoteShareCard(quote: quote),
                          fileBaseName:
                              'ekush_ponji_quote_${quote.storageKey}',
                        ),
                        icon: Icon(Icons.share_rounded,
                            color: colorScheme.onSurfaceVariant),
                        tooltip: l10n.share,
                      ),
                      IconButton(
                        onPressed: onToggleSave,
                        icon: Icon(
                          quote.isSaved
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: quote.isSaved
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        tooltip: quote.isSaved ? 'Unsave' : 'Save',
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Quote body
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      size: 48,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: AutoSizeText(
                        quote.text,
                        maxLines: 12,
                        minFontSize: 14 * quoteFontScale,
                        maxFontSize: 34 * quoteFontScale,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Author + watermark
              Row(
                children: [
                  Container(width: 32, height: 2, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      quote.author,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'Ekush Ponji',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.55),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
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