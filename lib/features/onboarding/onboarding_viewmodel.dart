// lib/features/onboarding/onboarding_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';

// ── Constants ────────────────────────────────────────────────

const String _onboardingBoxName = 'settings';
const String _onboardingDoneKey = 'onboarding_done';
const String _prayerTimesEnabledKey = 'prayer_times_enabled';

// ── State ────────────────────────────────────────────────────

class OnboardingState {
  final String selectedLanguage;  // 'bn' | 'en'
  final bool showPrayerTimes;
  final bool isCompleting;

  const OnboardingState({
    this.selectedLanguage = 'bn',
    this.showPrayerTimes = true,
    this.isCompleting = false,
  });

  OnboardingState copyWith({
    String? selectedLanguage,
    bool? showPrayerTimes,
    bool? isCompleting,
  }) {
    return OnboardingState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      showPrayerTimes: showPrayerTimes ?? this.showPrayerTimes,
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

  void togglePrayerTimes(bool value) {
    state = state.copyWith(showPrayerTimes: value);
  }

  /// Persists all choices and marks onboarding complete.
  /// Called when the user taps "Get Started".
  Future<void> complete(WidgetRef ref) async {
    state = state.copyWith(isCompleting: true);

    final box = Hive.box(_onboardingBoxName);

    // 1. Save language
    final locale = state.selectedLanguage == 'bn'
        ? const Locale('bn', 'BD')
        : const Locale('en', 'US');
    await ref.read(localeProvider.notifier).setLocale(locale);

    // 2. Save prayer times preference
    await box.put(_prayerTimesEnabledKey, state.showPrayerTimes);

    // 3. Mark onboarding done — splash will never show this again
    await box.put(_onboardingDoneKey, true);

    state = state.copyWith(isCompleting: false);
  }
}

// ── Helpers ──────────────────────────────────────────────────

/// Returns true if onboarding has already been completed.
/// Read this in the splash screen to decide where to navigate.
bool isOnboardingDone() {
  try {
    final box = Hive.box(_onboardingBoxName);
    return box.get(_onboardingDoneKey, defaultValue: false) as bool;
  } catch (_) {
    return false;
  }
}

/// Returns whether prayer times feature is enabled.
/// Read by the prayer times screen / bottom nav to show or hide.
bool isPrayerTimesEnabled() {
  try {
    final box = Hive.box(_onboardingBoxName);
    return box.get(_prayerTimesEnabledKey, defaultValue: true) as bool;
  } catch (_) {
    return true;
  }
}

// ── Provider ─────────────────────────────────────────────────

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);

/// Convenience provider — exposes prayer times enabled state reactively.
final prayerTimesEnabledProvider = Provider<bool>((ref) {
  return isPrayerTimesEnabled();
});