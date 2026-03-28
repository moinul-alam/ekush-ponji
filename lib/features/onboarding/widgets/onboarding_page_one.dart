// lib/features/onboarding/widgets/onboarding_page_one.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/onboarding/onboarding_viewmodel.dart';

class OnboardingPageOne extends ConsumerWidget {
  final bool isBn;
  final OnboardingState state;
  final VoidCallback onNext;

  const OnboardingPageOne({
    super.key,
    required this.isBn,
    required this.state,
    required this.onNext,
  });

  static const double _logoSize = 88;
  static const double _titleImageWidth = 132;
  static const double _titleImageHeight = 52;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),

                      // ── Logo ───────────────────────────────
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: _logoSize,
                          height: _logoSize,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: _logoSize,
                            height: _logoSize,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              Icons.calendar_month_rounded,
                              size: 40,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),

                      // ── App Title ──────────────────────────
                      Image.asset(
                        'assets/images/app_title.png',
                        width: _titleImageWidth,
                        height: _titleImageHeight,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Text(
                          'একুশ পঞ্জি',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ── Title ──────────────────────────────
                      Text(
                        isBn
                            ? 'সব ক্যালেন্ডার এক অ্যাপে'
                            : 'All Calendars in One App',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      // ── Subtitle ───────────────────────────
                      Text(
                        isBn
                            ? 'বাংলা, গ্রেগরীয় (ইংরেজি) ও হিজরি (আরবী) - তিন ক্যালেন্ডার এক অ্যাপে। সরকারি ছুটি, গুরত্বপূর্ণ ইভেন্ট, জরুরি রিমাইন্ডার আর প্রতিদিনের অনুপ্রেরণামূলক উক্তি—সবই থাকছে আপনার হাতের মুঠোয়।'
                            : 'Seamlessly track Bangla, Gregorian (English) & Hijri (Arabic) dates. Stay ahead with holiday alerts, important events, custom reminders, and a daily dose of inspiration — all in one place.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.55,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // ── Language label ─────────────────────
                      Text(
                        isBn
                            ? 'আপনার ভাষা নির্বাচন করুন'
                            : 'Choose your language',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          letterSpacing: 0.2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ── Language cards ─────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _LanguageCard(
                              label: 'বাংলা',
                              sublabel: 'Bangla',
                              flag: '🇧🇩',
                              isSelected: state.selectedLanguage == 'bn',
                              onTap: () => notifier.selectLanguage('bn'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _LanguageCard(
                              label: 'English',
                              sublabel: 'ইংরেজি',
                              flag: '🇺🇸',
                              isSelected: state.selectedLanguage == 'en',
                              onTap: () => notifier.selectLanguage('en'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onNext,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isBn ? 'পরবর্তী' : 'Next',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Language Card ─────────────────────────────────────────────

class _LanguageCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.label,
    required this.sublabel,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? colorScheme.primary : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(flag, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
