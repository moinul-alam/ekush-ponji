// lib/features/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/features/onboarding/onboarding_viewmodel.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isBn = state.selectedLanguage == 'bn';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // ── Logo ─────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      size: 44,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Title ─────────────────────────────
              Text(
                isBn ? 'একুশ পঞ্জিতে স্বাগতম' : 'Welcome to Ekush Ponji',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // ── Subtitle ──────────────────────────
              Text(
                isBn
                    ? 'বাংলা, ইংরেজি ও আরবি ক্যালেন্ডার\nছুটি • ইভেন্ট • রিমাইন্ডার'
                    : 'Bangla, English & Arabic Calendar\nHolidays • Events • Reminders',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // ── Language label ────────────────────
              Text(
                isBn ? 'ভাষা নির্বাচন করুন' : 'Choose your language',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              // ── Language cards ────────────────────
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

              // ── Get Started Button ────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.isCompleting
                      ? null
                      : () async {
                          await notifier.complete(ref);
                          if (context.mounted) {
                            context.go(RouteNames.home);
                          }
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: state.isCompleting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          isBn ? 'শুরু করুন' : 'Get Started',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
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
              Text(flag, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 10),
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
