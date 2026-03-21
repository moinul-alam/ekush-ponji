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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),

          // ── Logo ───────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/app_logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 52,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),

          // ── App Title ──────────────────────────
          Image.asset(
            'assets/images/app_title.png',
            width: 150,
            height: 60,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Text(
              'একুশ পঞ্জি',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Title ──────────────────────────────
          Text(
            isBn ? 'সব ক্যালেন্ডার এক অ্যাপে' : 'All Calendars in One App',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 14),

          // ── Subtitle ───────────────────────────
          Text(
            isBn
                ? 'বাংলা, ইংরেজি ও আরবি - তিন ক্যালেন্ডার এক সাথে। সরকারি ছুটি, গুরত্বপূর্ণ ইভেন্ট, জরুরি রিমাইন্ডার আর প্রতিদিনের অনুপ্রেরণামূলক উক্তি—সবই থাকছে আপনার হাতের মুঠোয়।'
                : 'Seamlessly track Bangla, English & Arabic dates. Stay ahead with holiday alerts, important events, custom reminders, and a daily dose of inspiration — all in one place.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // ── Language label ─────────────────────
          Text(
            isBn ? 'আপনার ভাষা বেছে নিন' : 'Choose your language',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 16),

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
              const SizedBox(width: 12),
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

          const Spacer(),

          // ── Next button ────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                isBn ? 'পরবর্তী' : 'Next',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
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
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  isSelected ? colorScheme.primary : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(flag, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 10),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: theme.textTheme.bodyMedium?.copyWith(
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
