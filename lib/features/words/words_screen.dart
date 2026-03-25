// lib/features/words/words_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/features/words/models/word.dart';
import 'package:ekush_ponji/features/words/words_viewmodel.dart';
import 'package:ekush_ponji/features/words/widgets/word_share_card.dart';
import 'package:ekush_ponji/core/services/share_service.dart';
import 'package:ekush_ponji/core/services/ad_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ekush_ponji/features/words/services/word_notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_service.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_prefs.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_provider.dart';
import 'package:ekush_ponji/features/words/services/word_notification_prefs.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';

class WordsScreen extends BaseScreen {
  final int initialIndex;
  const WordsScreen({super.key, this.initialIndex = 0});

  @override
  BaseScreenState createState() => _WordsScreenState();
}

class _WordsScreenState extends BaseScreenState<WordsScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animationController;
  late Animation<Offset> _slideOutAnimation;
  late Animation<Offset> _slideInAnimation;
  bool _isAnimating = false;
  bool _slideFromRight = true;
  double _wordFontScale = 1.0;
  int _wordsViewed = 0;
  bool _interstitialTriggered = false;

  // ── Notification state ─────────────────────────────────────
  bool _notifEnabled = false;
  WordNotificationPrefs _notifPrefs =
      const WordNotificationPrefs(enabled: false);

  @override
  NotifierProvider<dynamic, ViewState> get viewModelProvider =>
      wordsViewModelProvider;

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
    final v = prefs.getDouble('word_font_scale') ?? 1.0;
    if (!mounted) return;
    setState(() => _wordFontScale = v.clamp(0.8, 1.6));
  }

  Future<void> _saveFontScale(double v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('word_font_scale', v);
  }

  void _increaseFontSize() {
    if (_wordFontScale >= 1.6) return;
    final next = (_wordFontScale + 0.1).clamp(0.8, 1.6);
    setState(() => _wordFontScale = next);
    _saveFontScale(next);
  }

  void _decreaseFontSize() {
    if (_wordFontScale <= 0.8) return;
    final next = (_wordFontScale - 0.1).clamp(0.8, 1.6);
    setState(() => _wordFontScale = next);
    _saveFontScale(next);
  }

  // ── Notification prefs ─────────────────────────────────────

  Future<void> _loadNotifPrefs() async {
    final prefs = await WordNotificationPrefs.load();
    final osGranted = await NotificationPermissionService.isGranted();
    if (!mounted) return;
    setState(() {
      _notifPrefs = prefs;
      _notifEnabled = prefs.enabled && osGranted;
    });
  }

  Future<void> _toggleNotification() async {
    final l10n = AppLocalizations.of(context);

    if (!_notifEnabled) {
      final osGranted = await NotificationPermissionService.isGranted();

      if (!osGranted) {
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

    await WordNotificationService.scheduleUpcoming(
      repository: ref.read(wordsRepositoryProvider),
      prefs: updated,
      languageCode: l10n.languageCode,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(newEnabled
            ? (l10n.languageCode == 'bn'
                ? 'শব্দের নোটিফিকেশন চালু হয়েছে'
                : 'Word notifications enabled')
            : (l10n.languageCode == 'bn'
                ? 'শব্দের নোটিফিকেশন বন্ধ হয়েছে'
                : 'Word notifications disabled')),
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

  Future<void> _goToNext(List<WordModel> words) async {
    if (_isAnimating || _currentIndex >= words.length - 1) return;
    _isAnimating = true;
    _setupAnimations(fromRight: true);
    _animationController.reset();
    await _animationController.forward();
    setState(() => _currentIndex++);
    _wordsViewed++;
    if (_wordsViewed >= 3 && !_interstitialTriggered) {
      _interstitialTriggered = true;
      ref.read(adServiceProvider).showInterstitialIfAvailable();
    }
    _animationController.reset();
    _isAnimating = false;
  }

  Future<void> _goToPrevious(List<WordModel> words) async {
    if (_isAnimating || _currentIndex <= 0) return;
    _isAnimating = true;
    _setupAnimations(fromRight: false);
    _animationController.reset();
    await _animationController.forward();
    setState(() => _currentIndex--);
    _wordsViewed++;
    if (_wordsViewed >= 3 && !_interstitialTriggered) {
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
      title: AppHeader.title(context, l10n.wordOfTheDay),
      centerTitle: true,
      actions: [
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
        IconButton(
          icon: const Icon(Icons.favorite_rounded),
          tooltip: l10n.savedWords,
          onPressed: () => context.push(RouteNames.savedWords),
        ),
      ],
    );
  }

  // ── Body ───────────────────────────────────────────────────

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(wordsViewModelProvider);
    final vm = ref.read(wordsViewModelProvider.notifier);

    if (viewState is ViewStateLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final words = vm.allWords;
    if (words.isEmpty) {
      return buildEmptyWidget(const ViewStateEmpty('No words available'));
    }

    if (_currentIndex >= words.length) _currentIndex = words.length - 1;

    final word = words[_currentIndex];
    final canGoPrev = _currentIndex > 0;
    final canGoNext = _currentIndex < words.length - 1;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -300)
          _goToNext(words);
        else if (details.primaryVelocity! > 300) _goToPrevious(words);
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
                        child: _WordCard(
                          word: word,
                          onToggleSave: () => vm.toggleSave(word),
                          fontScale: _wordFontScale,
                        ),
                      ),
                    if (isForwarding)
                      SlideTransition(
                        position: _slideInAnimation,
                        child: _WordCard(
                          word: words[_slideFromRight
                              ? (_currentIndex < words.length - 1
                                  ? _currentIndex + 1
                                  : _currentIndex)
                              : (_currentIndex > 0
                                  ? _currentIndex - 1
                                  : _currentIndex)],
                          onToggleSave: () => vm.toggleSave(word),
                          fontScale: _wordFontScale,
                        ),
                      ),
                    if (!isForwarding)
                      _WordCard(
                        word: word,
                        onToggleSave: () => vm.toggleSave(word),
                        fontScale: _wordFontScale,
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
                  onTap: () => _goToPrevious(words),
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
                  onTap: () => _goToNext(words),
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

// ─── Word Card ────────────────────────────────────────────────
class _WordCard extends StatelessWidget {
  final WordModel word;
  final VoidCallback onToggleSave;
  final double fontScale;

  const _WordCard({
    required this.word,
    required this.onToggleSave,
    required this.fontScale,
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
                colorScheme.tertiaryContainer.withValues(alpha: 0.4),
                colorScheme.primaryContainer.withValues(alpha: 0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Share + Save actions (top right) ──────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => ShareService.shareWidget(
                      widget: WordShareCard(word: word),
                      fileBaseName: 'ekush_ponji_word_${word.storageKey}',
                    ),
                    icon: Icon(Icons.share_rounded,
                        color: colorScheme.onSurfaceVariant),
                    tooltip: l10n.share,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: onToggleSave,
                    icon: Icon(
                      word.isSaved
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      color: word.isSaved
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    tooltip: word.isSaved ? 'Unsave' : 'Save',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Word (large, prominent) ────────────────────
              Text(
                word.word,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.tertiary,
                  fontSize: (32 * fontScale).roundToDouble(),
                ),
              ),

              const SizedBox(height: 8),

              // ── Part of speech chip ────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  word.partOfSpeech,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Pronunciation (with speaker icon) ──────────
              Row(
                children: [
                  Icon(
                    Icons.volume_up_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    word.pronunciation,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                      fontSize: (14 * fontScale).roundToDouble(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Bengali meaning ────────────────────────────
              Text(
                word.meaningBn,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: (24 * fontScale).roundToDouble(),
                  height: 1.4,
                ),
              ),

              // ── Divider ───────────────────────────────────
              const SizedBox(height: 20),
              Divider(
                  color: colorScheme.outline.withValues(alpha: 0.3), height: 1),
              const SizedBox(height: 20),

              // ── Scrollable lower sections ──────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(context,
                          icon: Icons.lightbulb_outline_rounded,
                          title: l10n.meaningEnglish,
                          content: word.meaningEn,
                          fontScale: fontScale),
                      const SizedBox(height: 16),
                      _buildSection(context,
                          icon: Icons.sync_alt_rounded,
                          title: l10n.synonym,
                          content: word.synonym,
                          fontScale: fontScale),
                      const SizedBox(height: 16),
                      _buildSection(context,
                          icon: Icons.chat_bubble_outline_rounded,
                          title: l10n.example,
                          content: word.example,
                          isItalic: true,
                          fontScale: fontScale),
                      const SizedBox(height: 18),

                      // ── Brand watermark (bottom right) ─────
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'একুশ পঞ্জি',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.55),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required double fontScale,
    bool isItalic = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: colorScheme.tertiary),
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
            fontSize: (14 * fontScale).roundToDouble(),
          ),
        ),
      ],
    );
  }
}
