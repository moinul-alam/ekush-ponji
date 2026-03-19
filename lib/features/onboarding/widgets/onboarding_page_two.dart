// lib/features/onboarding/widgets/onboarding_page_two.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/features/onboarding/onboarding_viewmodel.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_service.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_prefs.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_provider.dart';
import 'package:ekush_ponji/features/quotes/services/quote_notification_prefs.dart';
import 'package:ekush_ponji/features/quotes/services/quote_notification_service.dart';
import 'package:ekush_ponji/features/quotes/providers/quote_notification_prefs_provider.dart';
import 'package:ekush_ponji/features/words/services/word_notification_prefs.dart';
import 'package:ekush_ponji/features/words/services/word_notification_service.dart';
import 'package:ekush_ponji/features/words/providers/word_notification_prefs_provider.dart';
import 'package:ekush_ponji/features/holidays/providers/holiday_notification_provider.dart';
import 'package:ekush_ponji/features/holidays/holidays_viewmodel.dart';

class OnboardingPageTwo extends ConsumerStatefulWidget {
  final bool isBn;
  final OnboardingState state;
  final VoidCallback onBack;

  const OnboardingPageTwo({
    super.key,
    required this.isBn,
    required this.state,
    required this.onBack,
  });

  @override
  ConsumerState<OnboardingPageTwo> createState() => _OnboardingPageTwoState();
}

class _OnboardingPageTwoState extends ConsumerState<OnboardingPageTwo> {
  bool _notifEnabled = false;
  bool _notifRequested = false;

  // ── Notification handler ───────────────────────────────────

  Future<void> _handleEnableNotification() async {
    if (_notifRequested) return;
    setState(() => _notifRequested = true);

    final granted = await NotificationPermissionService.ensurePermission();

    if (granted) {
      await NotificationPermissionPrefs.markGranted();
      setState(() => _notifEnabled = true);

      final languageCode = widget.state.selectedLanguage;

      // Capture notifiers
      final quoteNotifier = ref.read(quoteNotificationPrefsProvider.notifier);
      final wordNotifier = ref.read(wordNotificationPrefsProvider.notifier);
      final holidayNotifier = ref.read(holidayNotificationProvider.notifier);
      final holidays = ref.read(holidaysViewModelProvider.notifier).holidays;

      // Quotes
      final quotePrefs = await QuoteNotificationPrefs.load();
      final enabledQuotePrefs = quotePrefs.copyWith(enabled: true);
      await enabledQuotePrefs.save();
      quoteNotifier.forceState(enabledQuotePrefs);
      await QuoteNotificationService.scheduleUpcoming(
        prefs: enabledQuotePrefs,
        languageCode: languageCode,
      );

      // Words
      final wordPrefs = await WordNotificationPrefs.load();
      final enabledWordPrefs = wordPrefs.copyWith(enabled: true);
      await enabledWordPrefs.save();
      wordNotifier.forceState(enabledWordPrefs);
      await WordNotificationService.scheduleUpcoming(
        prefs: enabledWordPrefs,
        languageCode: languageCode,
      );

      // Holidays
      await holidayNotifier.rescheduleIfEnabled(
        holidays: holidays,
        languageCode: languageCode,
      );

      // Refresh OS permission provider
      ref.read(notificationPermissionProvider.notifier).refresh();
    } else {
      await NotificationPermissionPrefs.markDenied();
      setState(() {
        _notifEnabled = false;
        _notifRequested = false; // allow retry
      });
    }
  }

  // ── Get Started handler ────────────────────────────────────

  Future<void> _handleGetStarted() async {
    final notifier = ref.read(onboardingProvider.notifier);
    await notifier.complete(ref);
    if (mounted) context.go(RouteNames.home);
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isBn = widget.isBn;
    final isCompleting = ref.watch(onboardingProvider).isCompleting;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),

          // ── Logo only ──────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/logo.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 36,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Title ──────────────────────────────
          Text(
            isBn
                ? 'শুরু করার আগে একটি ছোট অনুরোধ'
                : 'A Quick Note Before You Begin',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          // ── Notification card ──────────────────
          _TransparencyCard(
            icon: Icons.notifications_outlined,
            iconColor: colorScheme.primary,
            iconBg: colorScheme.primaryContainer,
            title: isBn ? 'নোটিফিকেশন' : 'Notifications',
            body: isBn
                ? 'ছুটির আগাম বার্তা, প্রতিদিনের উক্তি ও নতুন শব্দ পেতে নোটিফিকেশন চালু রাখুন — যাতে কোনো মুহূর্ত মিস না হয়।'
                : 'Enable notifications for holiday alerts, daily quotes, and new words — so you never miss a moment.',
            action: _notifEnabled
                ? _EnabledBadge(isBn: isBn)
                : _EnableButton(
                    isBn: isBn,
                    onTap: _handleEnableNotification,
                  ),
          ),

          const SizedBox(height: 16),

          // ── Ads card ───────────────────────────
          _TransparencyCard(
            icon: Icons.volunteer_activism_outlined,
            iconColor: colorScheme.tertiary,
            iconBg: colorScheme.tertiaryContainer,
            title: isBn ? 'বিজ্ঞাপন' : 'Ads',
            body: isBn
                ? 'একুশ পঞ্জি সম্পূর্ণ ফ্রি। অ্যাপটি সচল রাখতে আমরা খুব সামান্য এবং বিরক্তিহীন বিজ্ঞাপন ব্যবহার করি। আপনার যেকোনো মূল্যবান মতামত জানাতে ইমেইল করুন: ekushponji@gmail.com'
                : 'Ekush Ponji is free for everyone. To keep the app running, we show minimal, non-intrusive ads. We value your experience — feedback welcome at ekushponji@gmail.com',
            action: null,
          ),

          const Spacer(),

          // ── Back + Get Started ─────────────────
          Row(
            children: [
              OutlinedButton(
                onPressed: widget.onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  isBn ? 'পিছনে' : 'Back',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: isCompleting ? null : _handleGetStarted,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isCompleting
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          isBn ? 'শুরু করুন' : 'Get Started',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Transparency Card ─────────────────────────────────────────

class _TransparencyCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String body;
  final Widget? action;

  const _TransparencyCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.body,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon + title ─────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Body ─────────────────────────────
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.7,
            ),
          ),

          // ── Action ───────────────────────────
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}

// ── Enable button ─────────────────────────────────────────────

class _EnableButton extends StatelessWidget {
  final bool isBn;
  final VoidCallback onTap;

  const _EnableButton({required this.isBn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonal(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: colorScheme.primaryContainer,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              isBn ? 'নোটিফিকেশন চালু করুন' : 'Enable Notifications',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Enabled badge ─────────────────────────────────────────────

class _EnabledBadge extends StatelessWidget {
  final bool isBn;
  const _EnabledBadge({required this.isBn});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          isBn ? 'নোটিফিকেশন চালু আছে' : 'Notifications enabled',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
