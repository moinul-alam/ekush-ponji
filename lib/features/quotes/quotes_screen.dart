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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekush_ponji/core/services/share_service.dart';
import 'package:ekush_ponji/core/services/ad_service.dart';
import 'package:ekush_ponji/features/quotes/services/quote_notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_service.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_prefs.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_provider.dart';
import 'package:ekush_ponji/features/quotes/services/quote_notification_prefs.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';

class QuotesScreen extends BaseScreen {
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
  int _quotesViewed = 0;
  bool _interstitialTriggered = false;

  // ── Notification state ─────────────────────────────────────
  bool _notifEnabled = false;
  QuoteNotificationPrefs _notifPrefs =
      const QuoteNotificationPrefs(enabled: false);

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
    _loadFontScale();
    _loadNotifPrefs();
  }

  @override
  void onScreenDispose() {
    _animationController.dispose();
  }

  // ── Font scale ─────────────────────────────────────────────

  Future<void> _loadFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getDouble('quote_font_scale') ?? 1.0;
    if (!mounted) return;
    setState(() => _quoteFontScale = v.clamp(0.8, 1.6));
  }

  Future<void> _saveFontScale(double v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('quote_font_scale', v);
  }

  void _increaseFontSize() {
    if (_quoteFontScale >= 1.6) return;
    final next = (_quoteFontScale + 0.1).clamp(0.8, 1.6);
    setState(() => _quoteFontScale = next);
    _saveFontScale(next);
  }

  void _decreaseFontSize() {
    if (_quoteFontScale <= 0.8) return;
    final next = (_quoteFontScale - 0.1).clamp(0.8, 1.6);
    setState(() => _quoteFontScale = next);
    _saveFontScale(next);
  }

  // ── Notification prefs ─────────────────────────────────────

  Future<void> _loadNotifPrefs() async {
    final prefs = await QuoteNotificationPrefs.load();
    final osGranted = await NotificationPermissionService.isGranted();
    if (!mounted) return;
    setState(() {
      _notifPrefs = prefs;
      // Only show as enabled if BOTH user pref AND OS permission are true
      _notifEnabled = prefs.enabled && osGranted;
    });
  }

  Future<void> _toggleNotification() async {
    final l10n = AppLocalizations.of(context);

    if (!_notifEnabled) {
      // User wants to enable — check OS permission first
      final osGranted = await NotificationPermissionService.isGranted();

      if (!osGranted) {
        // Request permission contextually
        final granted = await NotificationPermissionService.ensurePermission();
        if (granted) {
          await NotificationPermissionPrefs.markGranted();
          ref.read(notificationPermissionProvider.notifier).refresh();
        } else {
          await NotificationPermissionPrefs.markDenied();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(l10n.languageCode == 'bn'
                  ? 'নোটিফিকেশনের অনুমতি দেওয়া হয়নি'
                  : 'Notification permission not granted'),
              action: SnackBarAction(
                label: l10n.languageCode == 'bn' ? 'সেটিংস' : 'Settings',
                onPressed: () => openAppSettings(),
              ),
            ));
          }
          return;
        }
      }
    }

    final newEnabled = !_notifEnabled;
    setState(() => _notifEnabled = newEnabled);

    final updated = _notifPrefs.copyWith(enabled: newEnabled);
    _notifPrefs = updated;
    await updated.save();

    await QuoteNotificationService.scheduleUpcoming(
      repository: ref.read(quotesRepositoryProvider),
      prefs: updated,
      languageCode: l10n.languageCode,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(newEnabled
            ? (l10n.languageCode == 'bn'
                ? 'উদ্ধৃতির নোটিফিকেশন চালু হয়েছে'
                : 'Quote notifications enabled')
            : (l10n.languageCode == 'bn'
                ? 'উদ্ধৃতির নোটিফিকেশন বন্ধ হয়েছে'
                : 'Quote notifications disabled')),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  // ── Animations ─────────────────────────────────────────────

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
    _quotesViewed++;
    if (_quotesViewed >= 3 && !_interstitialTriggered) {
      _interstitialTriggered = true;
      ref.read(adServiceProvider).showInterstitialIfAvailable();
    }
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
    _quotesViewed++;
    if (_quotesViewed >= 3 && !_interstitialTriggered) {
      _interstitialTriggered = true;
      ref.read(adServiceProvider).showInterstitialIfAvailable();
    }
    _animationController.reset();
    _isAnimating = false;
  }

  // ── AppBar ─────────────────────────────────────────────────

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.pop(),
      ),
      title: AppHeader.title(context, l10n.quoteOfTheDay),
      centerTitle: true,
      actions: [
        // ── Font size: decrease ──────────────────────────
        // IconButton(
        //   icon: const Icon(Icons.text_decrease_rounded),
        //   tooltip: 'Decrease font size',
        //   onPressed: _quoteFontScale <= 0.8 ? null : _decreaseFontSize,
        // ),
        // // ── Font size: increase ──────────────────────────
        // IconButton(
        //   icon: const Icon(Icons.text_increase_rounded),
        //   tooltip: 'Increase font size',
        //   onPressed: _quoteFontScale >= 1.6 ? null : _increaseFontSize,
        // ),
        // ── Notification toggle ──────────────────────────
        IconButton(
          icon: Icon(
            _notifEnabled
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_outlined,
            color: _notifEnabled ? cs.primary : cs.onSurfaceVariant,
          ),
          tooltip: _notifEnabled
              ? (l10n.languageCode == 'bn'
                  ? 'বিজ্ঞপ্তি বন্ধ করুন'
                  : 'Disable notifications')
              : (l10n.languageCode == 'bn'
                  ? 'বিজ্ঞপ্তি চালু করুন'
                  : 'Enable notifications'),
          onPressed: _toggleNotification,
        ),
        // ── Saved quotes ─────────────────────────────────
        IconButton(
          icon: const Icon(Icons.favorite_rounded),
          tooltip: l10n.savedQuotes,
          onPressed: () => context.push(RouteNames.savedQuotes),
        ),
      ],
    );
  }

  // ── Body ───────────────────────────────────────────────────

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

    if (_currentIndex >= quotes.length) _currentIndex = quotes.length - 1;

    final quote = quotes[_currentIndex];
    final canGoPrev = _currentIndex > 0;
    final canGoNext = _currentIndex < quotes.length - 1;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -300)
          _goToNext(quotes);
        else if (details.primaryVelocity! > 300) _goToPrevious(quotes);
      },
      child: Stack(
        children: [
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
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
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
                    child: const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white, size: 20),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          fileBaseName: 'ekush_ponji_quote_${quote.storageKey}',
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
                      child: SingleChildScrollView(
                        child: Text(
                          quote.text,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                            fontSize: (22 * quoteFontScale).roundToDouble(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

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
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
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
