// lib/features/prayer_times/prayer_times_viewmodel.dart

import 'dart:async';
import 'package:adhan/adhan.dart' hide Prayer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final Duration? countdown;
  final Prayer? highlightedPrayer;

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

  // ── Cache keys ────────────────────────────────────────────────
  static const String _cachedLatKey = 'prayer_cached_lat';
  static const String _cachedLngKey = 'prayer_cached_lng';
  static const String _cachedLocationDisplayKey =
      'prayer_cached_location_display';

  @override
  PrayerTimesState build() {
    ref.onDispose(() {
      _countdownTimer?.cancel();
    });
    return const PrayerTimesState();
  }

  // ── Public API ────────────────────────────────────────────────

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'bn';
    final cache = await _loadLocationCache();

    if (cache != null) {
      await _calculateAndUpdate(
        lat: cache['lat'] as double,
        lng: cache['lng'] as double,
        locationDisplay: cache['display'] as String,
        languageCode: languageCode,
      );
    } else {
      await _fetchGpsAndUpdate();
    }
  }

  Future<void> refresh() async {
    final existing = state.todayTimes;
    if (existing == null) return load();

    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'bn';

    await _calculateAndUpdate(
      lat: existing.latitude,
      lng: existing.longitude,
      locationDisplay: existing.locationDisplay,
      languageCode: languageCode,
    );
  }

  Future<void> updateLocation() => _fetchGpsAndUpdate();

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
      languageCode: languageCode,
    );
  }

  // ── Core private methods ──────────────────────────────────────

  Future<void> _fetchGpsAndUpdate() async {
    state = state.copyWith(status: PrayerLoadStatus.locating);

    try {
      final position = await _getPosition();

      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('languageCode') ?? 'bn';

      state = state.copyWith(status: PrayerLoadStatus.calculating);

      final locationDisplay = await _getLocationDisplay(
        position.latitude,
        position.longitude,
        languageCode,
      );

      await _saveLocationCache(
        position.latitude,
        position.longitude,
        locationDisplay,
      );

      await _calculateAndUpdate(
        lat: position.latitude,
        lng: position.longitude,
        locationDisplay: locationDisplay,
        languageCode: languageCode,
      );
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

  Future<void> _calculateAndUpdate({
    required double lat,
    required double lng,
    required String locationDisplay,
    required String languageCode,
  }) async {
    try {
      state = state.copyWith(status: PrayerLoadStatus.calculating);

      final settings =
          ref.read(prayerSettingsViewModelProvider).calculationSettings;

      final coords = Coordinates(lat, lng);
      final params = settings.adhanParams;

      // ── Today ─────────────────────────────────────────────────
      final today = DateTime.now();
      final todayComponents =
          DateComponents(today.year, today.month, today.day);
      final adhanToday = PrayerTimes(coords, todayComponents, params);

      // ── Tomorrow (needed for post-Isha countdown) ─────────────
      final tomorrow = today.add(const Duration(days: 1));
      final tomorrowComponents =
          DateComponents(tomorrow.year, tomorrow.month, tomorrow.day);
      final adhanTomorrow = PrayerTimes(coords, tomorrowComponents, params);

      // Build today's model and attach tomorrow's Fajr so that
      // timeUntilNextPrayer can count down past Isha correctly.
      final todayModel = PrayerTimesModel.fromAdhan(
        times: adhanToday,
        latitude: lat,
        longitude: lng,
        locationDisplay: locationDisplay,
        tomorrowFajr: adhanTomorrow.fajr,
      );

      // Build tomorrow's model for notification scheduling.
      final tomorrowModel = PrayerTimesModel.fromAdhan(
        times: adhanTomorrow,
        latitude: lat,
        longitude: lng,
        locationDisplay: locationDisplay,
      );

      state = state.copyWith(
        status: PrayerLoadStatus.loaded,
        todayTimes: todayModel,
        errorMessage: null,
      );

      _startCountdown();

      final position = Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      await _scheduleNotifications(
        todayModel,
        position,
        params,
        locationDisplay,
        languageCode: languageCode,
        tomorrowModel: tomorrowModel,
      );
    } catch (e) {
      state = state.copyWith(
        status: PrayerLoadStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Cache helpers ─────────────────────────────────────────────

  Future<void> _saveLocationCache(
    double lat,
    double lng,
    String locationDisplay,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_cachedLatKey, lat);
    await prefs.setDouble(_cachedLngKey, lng);
    await prefs.setString(_cachedLocationDisplayKey, locationDisplay);
  }

  Future<Map<String, dynamic>?> _loadLocationCache() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_cachedLatKey);
    final lng = prefs.getDouble(_cachedLngKey);
    final display = prefs.getString(_cachedLocationDisplayKey);
    if (lat == null || lng == null || display == null) return null;
    return {'lat': lat, 'lng': lng, 'display': display};
  }

  // ── Countdown timer ───────────────────────────────────────────

  void _startCountdown() {
    _countdownTimer?.cancel();
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final times = state.todayTimes;
    if (times == null) return;

    final now = DateTime.now();

    final modelDate = times.fajr; // Fajr is always the first prayer of the day
    final modelDay = DateTime(modelDate.year, modelDate.month, modelDate.day);
    final today = DateTime(now.year, now.month, now.day);

    if (today.isAfter(modelDay)) {
      // The calendar date has changed — recalculate for the new day.
      SharedPreferences.getInstance().then((prefs) {
        final languageCode = prefs.getString('languageCode') ?? 'bn';
        _calculateAndUpdate(
          lat: times.latitude,
          lng: times.longitude,
          locationDisplay: times.locationDisplay,
          languageCode: languageCode,
        );
      });
      return;
    }

    final next = times.nextPrayer;
    final countdown = times.timeUntilNextPrayer;

    state = state.copyWith(
      countdown: countdown,
      highlightedPrayer: next,
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

    final lastKnown = await Geolocator.getLastKnownPosition();

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 30),
      );
    } catch (_) {
      if (lastKnown != null) return lastKnown;
      rethrow;
    }
  }

  Future<String> _getLocationDisplay(
    double lat,
    double lng,
    String languageCode,
  ) async {
    try {
      if (languageCode == 'bn') {
        await setLocaleIdentifier('bn_BD');
        final bnPlacemarks = await placemarkFromCoordinates(lat, lng);

        if (bnPlacemarks.isNotEmpty) {
          final p = bnPlacemarks.first;
          final locality = p.locality ?? '';
          final country = p.country ?? '';
          final localityIsBengali = locality.runes.any((r) => r > 127);
          final countryIsBengali = country.runes.any((r) => r > 127);

          if (localityIsBengali &&
              countryIsBengali &&
              locality.isNotEmpty &&
              country.isNotEmpty) {
            return '$locality, $country';
          }
        }

        await setLocaleIdentifier('en_US');
        final enPlacemarks = await placemarkFromCoordinates(lat, lng);
        if (enPlacemarks.isNotEmpty) {
          final p = enPlacemarks.first;
          final parts = <String>[
            if (p.locality?.isNotEmpty == true) p.locality!,
            if (p.country?.isNotEmpty == true) p.country!,
          ];
          if (parts.isNotEmpty) return parts.join(', ');
        }
      } else {
        await setLocaleIdentifier('en_US');
        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = <String>[
            if (p.locality?.isNotEmpty == true) p.locality!,
            if (p.country?.isNotEmpty == true) p.country!,
          ];
          if (parts.isNotEmpty) return parts.join(', ');
        }
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
    String locationDisplay, {
    required String languageCode,
    PrayerTimesModel? tomorrowModel,
  }) async {
    final notifPrefs =
        ref.read(prayerSettingsViewModelProvider).notificationPrefs;
    if (!notifPrefs.masterEnabled) return;

    // Use the pre-calculated tomorrow model if provided, otherwise calculate.
    final tomorrow = tomorrowModel ??
        () {
          final t = DateTime.now().add(const Duration(days: 1));
          final tomorrowComponents = DateComponents(t.year, t.month, t.day);
          final coords = Coordinates(position.latitude, position.longitude);
          final adhan = PrayerTimes(coords, tomorrowComponents, params);
          return PrayerTimesModel.fromAdhan(
            times: adhan,
            latitude: position.latitude,
            longitude: position.longitude,
            locationDisplay: locationDisplay,
          );
        }();

    await PrayerNotificationService.scheduleAll(
      today: todayModel,
      tomorrow: tomorrow,
      prefs: notifPrefs,
      languageCode: languageCode,
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
    final times = ref.read(prayerTimesViewModelProvider).todayTimes;
    controller.add(times?.timeUntilNextPrayer);
  });
  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });
  return controller.stream;
});
