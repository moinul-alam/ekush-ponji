// lib/features/onboarding/onboarding_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';

// ── Constants ────────────────────────────────────────────────

const String _onboardingBoxName = 'settings';
const String _onboardingDoneKey = 'onboarding_done';

// ── State ────────────────────────────────────────────────────

class OnboardingState {
  final String selectedLanguage; // 'bn' | 'en'
  final bool isCompleting;

  const OnboardingState({
    this.selectedLanguage = 'bn',
    this.isCompleting = false,
  });

  OnboardingState copyWith({
    String? selectedLanguage,
    bool? isCompleting,
  }) {
    return OnboardingState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      isCompleting: isCompleting ?? this.isCompleting,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void selectLanguage(String code) {
    state = state.copyWith(selectedLanguage: code);
  }

  /// Persists all choices and marks onboarding complete.
  /// Called when the user taps "Get Started".
  Future<void> complete(WidgetRef ref) async {
    state = state.copyWith(isCompleting: true);

    final box = Hive.box(_onboardingBoxName);

    // Save language
    final locale = state.selectedLanguage == 'bn'
        ? const Locale('bn', 'BD')
        : const Locale('en', 'US');
    await ref.read(localeProvider.notifier).setLocale(locale);

    // Mark onboarding done — splash will never show this again
    await box.put(_onboardingDoneKey, true);

    state = state.copyWith(isCompleting: false);
  }
}

// ── Helpers ──────────────────────────────────────────────────

/// Returns true if onboarding has already been completed.
bool isOnboardingDone() {
  try {
    final box = Hive.box(_onboardingBoxName);
    return box.get(_onboardingDoneKey, defaultValue: false) as bool;
  } catch (_) {
    return false;
  }
}

// ── Provider ─────────────────────────────────────────────────

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
