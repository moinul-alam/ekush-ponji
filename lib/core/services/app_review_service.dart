// lib/core/services/app_review_service.dart
//
// Manages in-app review triggers using Google Play In-App Review API.
//
// Trigger conditions (ALL must be met):
//   1. At least 5 app launches
//   2. At least 3 days since first install recorded
//   3. At least 1 meaningful action (saved quote/word OR added event/reminder)
//   4. Never been requested before
//
// Fallback: if 10+ launches and conditions met but native dialog was suppressed,
// a banner flag is set so HomeScreen can show a soft "Rate us" card.

import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppReviewService {
  AppReviewService._();

  // ── Keys ──────────────────────────────────────────────────
  static const String _keyLaunchCount = 'review_launch_count';
  static const String _keyFirstLaunchDate = 'review_first_launch_date';
  static const String _keyMeaningfulAction = 'review_meaningful_action';
  static const String _keyReviewRequested = 'review_requested';
  static const String _keyShowFallback = 'review_show_fallback';
  static const String _keyFallbackDismissed = 'review_fallback_dismissed';

  // ── Thresholds ────────────────────────────────────────────
  static const int _minLaunches = 5;
  static const int _minDays = 3;
  static const int _fallbackLaunches = 10;

  static final InAppReview _inAppReview = InAppReview.instance;

  // ── Public API ────────────────────────────────────────────

  /// Call once on every app launch (from HomeScreen.onScreenInit).
  /// Increments launch count, records first launch date, and
  /// checks if review should be triggered.
  static Future<void> onAppLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Already requested — nothing more to do
      if (prefs.getBool(_keyReviewRequested) ?? false) return;

      // Record first launch date
      if (!prefs.containsKey(_keyFirstLaunchDate)) {
        await prefs.setString(
          _keyFirstLaunchDate,
          DateTime.now().toIso8601String(),
        );
      }

      // Increment launch count
      final launches = (prefs.getInt(_keyLaunchCount) ?? 0) + 1;
      await prefs.setInt(_keyLaunchCount, launches);

      debugPrint('📊 AppReview: launch count = $launches');

      await _evaluateTrigger(prefs, launches);
    } catch (e) {
      debugPrint('⚠️ AppReviewService.onAppLaunch error: $e');
    }
  }

  /// Call when the user completes a meaningful action:
  ///   - Saved a quote or word
  ///   - Added an event or reminder
  static Future<void> recordMeaningfulAction() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_keyReviewRequested) ?? false) return;
      await prefs.setBool(_keyMeaningfulAction, true);
      debugPrint('📊 AppReview: meaningful action recorded');
      final launches = prefs.getInt(_keyLaunchCount) ?? 0;
      await _evaluateTrigger(prefs, launches);
    } catch (e) {
      debugPrint('⚠️ AppReviewService.recordMeaningfulAction error: $e');
    }
  }

  /// Whether to show the fallback "Rate us" banner.
  /// Returns true only if:
  ///   - fallback flag is set (native dialog may have been suppressed)
  ///   - user hasn't dismissed the banner yet
  static Future<bool> shouldShowFallbackBanner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final show = prefs.getBool(_keyShowFallback) ?? false;
      final dismissed = prefs.getBool(_keyFallbackDismissed) ?? false;
      return show && !dismissed;
    } catch (_) {
      return false;
    }
  }

  /// Call when user dismisses the fallback banner — never show again.
  static Future<void> dismissFallbackBanner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyFallbackDismissed, true);
    } catch (e) {
      debugPrint('⚠️ AppReviewService.dismissFallbackBanner error: $e');
    }
  }

  /// Call when user taps "Rate Now" on the fallback banner.
  /// Opens the store listing directly.
  static Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing(
        appStoreId: '', // iOS App Store ID — fill in when available
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyReviewRequested, true);
      await prefs.setBool(_keyFallbackDismissed, true);
    } catch (e) {
      debugPrint('⚠️ AppReviewService.openStoreListing error: $e');
    }
  }

  // ── Internal ──────────────────────────────────────────────

  static Future<void> _evaluateTrigger(
    SharedPreferences prefs,
    int launches,
  ) async {
    // Condition 1: minimum launches
    if (launches < _minLaunches) return;

    // Condition 2: minimum days since first install
    final firstLaunchStr = prefs.getString(_keyFirstLaunchDate);
    if (firstLaunchStr == null) return;
    final firstLaunch = DateTime.tryParse(firstLaunchStr);
    if (firstLaunch == null) return;
    final daysSince = DateTime.now().difference(firstLaunch).inDays;
    if (daysSince < _minDays) {
      debugPrint(
          '📊 AppReview: only $daysSince days since install, need $_minDays');
      return;
    }

    // Condition 3: at least one meaningful action
    final hasMeaningfulAction = prefs.getBool(_keyMeaningfulAction) ?? false;
    if (!hasMeaningfulAction) {
      debugPrint('📊 AppReview: no meaningful action yet');
      return;
    }

    // All conditions met — request review
    debugPrint('✅ AppReview: all conditions met, requesting review...');
    await _requestReview(prefs, launches);
  }

  static Future<void> _requestReview(
    SharedPreferences prefs,
    int launches,
  ) async {
    try {
      final isAvailable = await _inAppReview.isAvailable();

      if (isAvailable) {
        await _inAppReview.requestReview();
        await prefs.setBool(_keyReviewRequested, true);
        debugPrint('✅ AppReview: native review dialog requested');
      } else {
        // Native not available — set fallback flag if enough launches
        debugPrint('ℹ️ AppReview: native not available');
        if (launches >= _fallbackLaunches) {
          await prefs.setBool(_keyShowFallback, true);
          debugPrint('📊 AppReview: fallback banner enabled');
        }
      }
    } catch (e) {
      debugPrint('⚠️ AppReview: requestReview error — $e');
      // On error, enable fallback banner as safety net
      if (launches >= _fallbackLaunches) {
        await prefs.setBool(_keyShowFallback, true);
      }
    }
  }
}
