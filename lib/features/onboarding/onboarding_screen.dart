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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // ── App logo + name ─────────────────────────────
              Center(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.calendar_month_rounded,
                            size: 40,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isBn ? 'একুশ পঞ্জি' : 'Ekush Ponji',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isBn
                          ? 'শুরু করার আগে কয়েকটি সেটিংস ঠিক করুন'
                          : 'Set up a few preferences to get started',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // ── Language selection ──────────────────────────
              Text(
                isBn ? 'ভাষা বেছে নিন' : 'Choose Language',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
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

              const SizedBox(height: 36),

              // ── Prayer times toggle ─────────────────────────
              Text(
                isBn ? 'নামাজের সময়' : 'Prayer Times',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _FeatureToggleCard(
                icon: Icons.access_time_rounded,
                title: isBn ? 'নামাজের সময় দেখান' : 'Show Prayer Times',
                subtitle: isBn
                    ? 'প্রতিদিনের নামাজের সময়সূচি'
                    : 'Daily prayer time schedule',
                value: state.showPrayerTimes,
                onChanged: notifier.togglePrayerTimes,
              ),
              if (state.showPrayerTimes) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isBn
                            ? 'সঠিক সময়ের জন্য অবস্থানের অনুমতি প্রয়োজন'
                            : 'Location permission needed for accurate times',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // ── Get started button ──────────────────────────
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

// ── Language card ─────────────────────────────────────────────

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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
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
    );
  }
}

// ── Feature toggle card ───────────────────────────────────────

class _FeatureToggleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FeatureToggleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: colorScheme.primary),
        title: Text(title, style: theme.textTheme.bodyLarge),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        value: value,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}