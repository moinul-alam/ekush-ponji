// lib/features/prayer_times/prayer_times_viewmodel.dart

import 'dart:async';
import 'package:adhan/adhan.dart' hide Prayer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ekush_ponji/features/prayer_times/models/prayer_times_model.dart';
import 'package:ekush_ponji/features/prayer_times/services/prayer_notification_service.dart';
import 'package:ekush_ponji/features/prayer_times/prayer_settings_viewmodel.dart';

// ── State ──────────────────────────────────────────────────────

enum PrayerLoadStatus { idle, locating, calculating, loaded, error }

class PrayerTimesState {
  final PrayerLoadStatus status;
  final PrayerTimesModel? todayTimes;
  final String? errorMessage;
  final Duration? countdown;        // time remaining to next prayer
  final Prayer? highlightedPrayer; // current or next prayer

  const PrayerTimesState({
    this.status = PrayerLoadStatus.idle,
    this.todayTimes,
    this.errorMessage,
    this.countdown,
    this.highlightedPrayer,
  });

  bool get isLoading =>
      status == PrayerLoadStatus.locating ||
      status == PrayerLoadStatus.calculating;

  bool get hasData => todayTimes != null;

  PrayerTimesState copyWith({
    PrayerLoadStatus? status,
    PrayerTimesModel? todayTimes,
    String? errorMessage,
    Duration? countdown,
    Prayer? highlightedPrayer,
  }) {
    return PrayerTimesState(
      status: status ?? this.status,
      todayTimes: todayTimes ?? this.todayTimes,
      errorMessage: errorMessage ?? this.errorMessage,
      countdown: countdown ?? this.countdown,
      highlightedPrayer: highlightedPrayer ?? this.highlightedPrayer,
    );
  }
}

// ── ViewModel ──────────────────────────────────────────────────

class PrayerTimesViewModel extends Notifier<PrayerTimesState> {
  Timer? _countdownTimer;

  @override
  PrayerTimesState build() {
    // Clean up timer when provider is disposed
    ref.onDispose(() {
      _countdownTimer?.cancel();
    });
    return const PrayerTimesState();
  }

  // ── Load ─────────────────────────────────────────────────────

  Future<void> load() async {
    state = state.copyWith(status: PrayerLoadStatus.locating);

    try {
      // 1. Check + request location permission
      final position = await _getPosition();

      // 2. Reverse geocode for display name
      state = state.copyWith(status: PrayerLoadStatus.calculating);
      final locationDisplay = await _getLocationDisplay(
        position.latitude,
        position.longitude,
      );

      // 3. Calculate prayer times via adhan
      final settings = ref
          .read(prayerSettingsViewModelProvider)
          .calculationSettings;

      final coords = Coordinates(position.latitude, position.longitude);
      final params = settings.adhanParams;
      final today = DateTime.now();
      final dateComponents = DateComponents(today.year, today.month, today.day);

      final adhanTimes = PrayerTimes(coords, dateComponents, params);

      final todayModel = PrayerTimesModel.fromAdhan(
        times: adhanTimes,
        latitude: position.latitude,
        longitude: position.longitude,
        locationDisplay: locationDisplay,
      );

      state = state.copyWith(
        status: PrayerLoadStatus.loaded,
        todayTimes: todayModel,
        errorMessage: null,
      );

      // 4. Start countdown timer
      _startCountdown();

      // 5. Schedule notifications
      await _scheduleNotifications(todayModel, position, params, locationDisplay);

    } on LocationPermissionDeniedException {
      state = state.copyWith(
        status: PrayerLoadStatus.error,
        errorMessage: 'location_permission_denied',
      );
    } on LocationServiceDisabledException {
      state = state.copyWith(
        status: PrayerLoadStatus.error,
        errorMessage: 'location_service_disabled',
      );
    } catch (e) {
      state = state.copyWith(
        status: PrayerLoadStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() => load();

  // ── Countdown timer ───────────────────────────────────────────

  void _startCountdown() {
    _countdownTimer?.cancel();
    _updateCountdown(); // immediate first tick
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final times = state.todayTimes;
    if (times == null) return;

    final next = times.nextPrayer;
    final current = times.currentPrayer;
    final countdown = times.timeUntilNextPrayer;

    state = state.copyWith(
      countdown: countdown,
      highlightedPrayer: next ?? current,
    );
  }

  // ── Location helpers ──────────────────────────────────────────

  Future<Position> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw LocationServiceDisabledException();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw LocationPermissionDeniedException();
    }

    // Try last known position first — instant, no GPS warm-up needed
    final lastKnown = await Geolocator.getLastKnownPosition();

    try {
      // Attempt fresh fix with generous timeout
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 30),
      );
    } catch (_) {
      // GPS timed out — use last known position if available
      if (lastKnown != null) return lastKnown;
      rethrow;
    }
  }

  Future<String> _getLocationDisplay(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[
          if (p.locality?.isNotEmpty == true) p.locality!,
          if (p.country?.isNotEmpty == true) p.country!,
        ];
        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {
      // geocoding failed — fall back to coordinates
    }
    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  // ── Notification scheduling ───────────────────────────────────

  Future<void> _scheduleNotifications(
    PrayerTimesModel todayModel,
    Position position,
    CalculationParameters params,
    String locationDisplay,
  ) async {
    final notifPrefs =
        ref.read(prayerSettingsViewModelProvider).notificationPrefs;
    if (!notifPrefs.masterEnabled) return;

    // Calculate tomorrow for pre-scheduling Fajr
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowComponents =
        DateComponents(tomorrow.year, tomorrow.month, tomorrow.day);
    final coords = Coordinates(position.latitude, position.longitude);
    final tomorrowAdhan = PrayerTimes(coords, tomorrowComponents, params);
    final tomorrowModel = PrayerTimesModel.fromAdhan(
      times: tomorrowAdhan,
      latitude: position.latitude,
      longitude: position.longitude,
      locationDisplay: locationDisplay,
    );

    // Read language from locale — default to 'en'
    await PrayerNotificationService.scheduleAll(
      today: todayModel,
      tomorrow: tomorrowModel,
      prefs: notifPrefs,
      languageCode: 'en', // will be passed from screen
    );
  }

  /// Call this when settings change (method, notifications)
  Future<void> rescheduleNotifications(String languageCode) async {
    final times = state.todayTimes;
    if (times == null) return;

    final position = Position(
      latitude: times.latitude,
      longitude: times.longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

    final settings =
        ref.read(prayerSettingsViewModelProvider).calculationSettings;

    await _scheduleNotifications(
      times,
      position,
      settings.adhanParams,
      times.locationDisplay,
    );
  }
}

// ── Custom exceptions ──────────────────────────────────────────

class LocationPermissionDeniedException implements Exception {}
class LocationServiceDisabledException implements Exception {}

// ── Providers ─────────────────────────────────────────────────

final prayerTimesViewModelProvider =
    NotifierProvider<PrayerTimesViewModel, PrayerTimesState>(
  PrayerTimesViewModel.new,
);

/// Countdown stream — ticks every second, emits remaining Duration
final prayerCountdownProvider = StreamProvider.autoDispose<Duration?>((ref) {
  final controller = StreamController<Duration?>();
  final timer = Timer.periodic(const Duration(seconds: 1), (_) {
    final times =
        ref.read(prayerTimesViewModelProvider).todayTimes;
    controller.add(times?.timeUntilNextPrayer);
  });
  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });
  return controller.stream;
});