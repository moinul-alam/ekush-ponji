// lib/features/prayer_times/prayer_times_screen.dart
//
// CHANGED:
//   • Removed requestPermission() from initState() — was firing on every mount.
//   • Added _notificationPermissionTriggered guard flag.
//   • Added _maybeAskNotificationPermission() — called once when prayer times
//     first load successfully. Waits 5 seconds then asks for notification
//     permission, respecting NotificationPermissionPrefs rules:
//       - First time: always ask.
//       - Denied: wait 3 days before asking again.
//       - Granted: never ask again.
//   • _onBack() and 30-second interstitial logic unchanged.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/services/ad_service.dart';
import 'package:ekush_ponji/core/services/notification_permission_prefs.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ekush_ponji/features/prayer_times/prayer_times_viewmodel.dart';
import 'package:ekush_ponji/features/prayer_times/prayer_settings_viewmodel.dart';
import 'package:ekush_ponji/features/prayer_times/services/prayer_notification_service.dart';
import 'package:ekush_ponji/features/prayer_times/widgets/next_prayer_card.dart';
import 'package:ekush_ponji/features/prayer_times/widgets/prayer_list_widget.dart';
import 'package:ekush_ponji/features/prayer_times/widgets/prayer_timeline_widget.dart';
import 'package:ekush_ponji/features/prayer_times/widgets/prayer_settings_sheet.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:go_router/go_router.dart';

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen> {
  // Track when user entered — used for 30-second engagement check
  late final DateTime _enteredAt;

  // Guards against triggering the notification prompt more than once
  // per screen lifetime (e.g. if build() is called multiple times while loaded).
  bool _notificationPermissionTriggered = false;

  @override
  void initState() {
    super.initState();
    _enteredAt = DateTime.now();
    // Only initialize + load. Permission is handled contextually after
    // prayer times load successfully — see _maybeAskNotificationPermission().
    PrayerNotificationService.initialize().then((_) {
      if (mounted) {
        ref.read(prayerTimesViewModelProvider.notifier).load();
      }
    });
  }

  // ── Notification permission ───────────────────────────────────

  /// Called once after prayer times load successfully.
  ///
  /// Waits 5 seconds so the user can see and appreciate the prayer times
  /// first, then asks for notification permission — but only if
  /// [NotificationPermissionPrefs.shouldAsk()] allows it.
  Future<void> _maybeAskNotificationPermission() async {
    // Flip the flag immediately — prevents re-entry on subsequent builds.
    _notificationPermissionTriggered = true;

    final should = await NotificationPermissionPrefs.shouldAsk();
    if (!should) return;

    // Wait 5 seconds so the user sees prayer times before the prompt appears.
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;

    // Mark as asked before showing the dialog so even if the app is killed
    // mid-prompt we don't spam the user on next launch.
    await NotificationPermissionPrefs.markAsked();

    final granted = await PrayerNotificationService.requestPermission();

    if (granted) {
      await NotificationPermissionPrefs.markGranted();
    } else {
      await NotificationPermissionPrefs.markDenied();
    }
  }

  // ── Back / interstitial ───────────────────────────────────────

  void _onBack() {
    final elapsed = DateTime.now().difference(_enteredAt);
    if (elapsed.inSeconds >= 30) {
      ref.read(adServiceProvider).showInterstitialIfAvailable(
        onClosed: () {
          if (mounted) context.go(RouteNames.home);
        },
      );
    } else {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(prayerTimesViewModelProvider);
    final settings = ref.watch(prayerSettingsViewModelProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(l10n.navPrayerTimes),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBack,
          tooltip: l10n.back,
        ),
        actions: [
          // Refresh location
          if (state.hasData)
            IconButton(
              icon: const Icon(Icons.my_location_rounded),
              tooltip: l10n.updateLocation,
              onPressed: () => ref
                  .read(prayerTimesViewModelProvider.notifier)
                  .updateLocation(),
            ),
          // Settings
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: l10n.settings,
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: _buildBody(context, state, settings, l10n, cs, theme),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PrayerTimesState state,
    PrayerSettingsState settings,
    AppLocalizations l10n,
    ColorScheme cs,
    ThemeData theme,
  ) {
    // ── Loading ───────────────────────────────────────────
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              state.status == PrayerLoadStatus.locating
                  ? l10n.detectingLocation
                  : l10n.calculatingPrayerTimes,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // ── Error ─────────────────────────────────────────────
    if (state.status == PrayerLoadStatus.error) {
      return _buildError(context, state, l10n, cs, theme);
    }

    // ── Idle (first launch) ───────────────────────────────
    if (state.status == PrayerLoadStatus.idle) {
      return _buildFirstLaunch(context, l10n, cs, theme);
    }

    // ── Loaded ────────────────────────────────────────────
    // Trigger notification permission prompt once per screen lifetime.
    if (!_notificationPermissionTriggered) {
      _maybeAskNotificationPermission();
    }

    final times = state.todayTimes!;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(prayerTimesViewModelProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // ── Location bar ──────────────────────────────
            _LocationBar(
              locationDisplay: times.locationDisplay,
              theme: theme,
              cs: cs,
            ),

            const SizedBox(height: 4),

            // ── Next prayer card ──────────────────────────
            NextPrayerCard(
              times: times,
              nextPrayer: state.highlightedPrayer ?? times.nextPrayer,
              countdownToNextPrayer: state.countdown,
            ),

            // ── Timeline ──────────────────────────────────
            PrayerTimelineWidget(times: times),

            // ── Prayer list ───────────────────────────────
            PrayerListWidget(
              times: times,
              highlightedPrayer: state.highlightedPrayer ?? times.nextPrayer,
              notifPrefs: settings.notificationPrefs,
              onToggleNotification: (prayer, enabled) async {
                await ref
                    .read(prayerSettingsViewModelProvider.notifier)
                    .setPrayerEnabled(prayer, enabled);
                await ref
                    .read(prayerTimesViewModelProvider.notifier)
                    .rescheduleNotifications(l10n.languageCode);
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────

  Widget _buildError(
    BuildContext context,
    PrayerTimesState state,
    AppLocalizations l10n,
    ColorScheme cs,
    ThemeData theme,
  ) {
    final isPermission = state.errorMessage == 'location_permission_denied';
    final isDisabled = state.errorMessage == 'location_service_disabled';

    final icon = isPermission || isDisabled
        ? Icons.location_off_rounded
        : Icons.error_outline_rounded;

    final title = isDisabled
        ? l10n.localtionServicesDisabled
        : isPermission
            ? l10n.locationPermissionRequired
            : l10n.error;

    final subtitle = isDisabled
        ? l10n.enableLocationServicesForPrayerTimes
        : isPermission
            ? l10n.locationServiceUsageForPrayerTimes
            : state.errorMessage ?? '';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: cs.error),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            if (isPermission)
              OutlinedButton.icon(
                onPressed: () => Geolocator.openAppSettings(),
                icon: const Icon(Icons.settings_rounded),
                label: Text(l10n.openSettings),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(prayerTimesViewModelProvider.notifier).load(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  // ── First launch state ────────────────────────────────────────

  Widget _buildFirstLaunch(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme cs,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mosque_rounded, size: 72, color: cs.primary),
            const SizedBox(height: 24),
            Text(
              l10n.navPrayerTimes,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.locationServiceUsageForPrayerTimes,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(prayerTimesViewModelProvider.notifier).load(),
              icon: const Icon(Icons.my_location_rounded),
              label: Text(l10n.getPrayerTimes),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Settings bottom sheet ─────────────────────────────────────

  void _showSettings(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, controller) => PrayerSettingsSheet(
          onSettingsChanged: () {
            ref.read(prayerTimesViewModelProvider.notifier).refresh();
          },
        ),
      ),
    );
  }
}

// ── Location bar ───────────────────────────────────────────────

class _LocationBar extends StatelessWidget {
  final String locationDisplay;
  final ThemeData theme;
  final ColorScheme cs;

  const _LocationBar({
    required this.locationDisplay,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on_rounded, size: 16, color: cs.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              locationDisplay,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
