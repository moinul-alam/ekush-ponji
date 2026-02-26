// lib/features/prayer_times/models/prayer_times_model.dart

import 'package:adhan/adhan.dart';

/// Names of the 5 prayers + Sunrise
enum Prayer {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha;

  String get nameEn {
    switch (this) {
      case Prayer.fajr:    return 'Fajr';
      case Prayer.sunrise: return 'Sunrise';
      case Prayer.dhuhr:   return 'Dhuhr';
      case Prayer.asr:     return 'Asr';
      case Prayer.maghrib: return 'Maghrib';
      case Prayer.isha:    return 'Isha';
    }
  }

  String get nameBn {
    switch (this) {
      case Prayer.fajr:    return 'ফজর';
      case Prayer.sunrise: return 'সূর্যোদয়';
      case Prayer.dhuhr:   return 'জোহর';
      case Prayer.asr:     return 'আসর';
      case Prayer.maghrib: return 'মাগরিব';
      case Prayer.isha:    return 'এশা';
    }
  }

  String nameForLocale(String languageCode) =>
      languageCode == 'bn' ? nameBn : nameEn;

  /// Whether this prayer has a notification option (Sunrise does not)
  bool get isNotifiable => this != Prayer.sunrise;
}

/// Holds all calculated prayer times for a single day
class PrayerTimesModel {
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final double latitude;
  final double longitude;
  final String locationDisplay; // e.g. "Dhaka, Bangladesh"

  /// Tomorrow's Fajr time — used for the post-Isha countdown.
  /// Populated by the viewmodel after calculating tomorrow's times.
  final DateTime? tomorrowFajr;

  const PrayerTimesModel({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.latitude,
    required this.longitude,
    required this.locationDisplay,
    this.tomorrowFajr,
  });

  /// Build from adhan PrayerTimes object
  factory PrayerTimesModel.fromAdhan({
    required PrayerTimes times,
    required double latitude,
    required double longitude,
    required String locationDisplay,
    DateTime? tomorrowFajr,
  }) {
    return PrayerTimesModel(
      date: times.fajr,
      fajr: times.fajr,
      sunrise: times.sunrise,
      dhuhr: times.dhuhr,
      asr: times.asr,
      maghrib: times.maghrib,
      isha: times.isha,
      latitude: latitude,
      longitude: longitude,
      locationDisplay: locationDisplay,
      tomorrowFajr: tomorrowFajr,
    );
  }

  /// Returns a copy with tomorrowFajr set (called after tomorrow is calculated)
  PrayerTimesModel withTomorrowFajr(DateTime fajr) {
    return PrayerTimesModel(
      date: date,
      fajr: this.fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
      latitude: latitude,
      longitude: longitude,
      locationDisplay: locationDisplay,
      tomorrowFajr: fajr,
    );
  }

  /// Get time for a specific prayer
  DateTime timeFor(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:    return fajr;
      case Prayer.sunrise: return sunrise;
      case Prayer.dhuhr:   return dhuhr;
      case Prayer.asr:     return asr;
      case Prayer.maghrib: return maghrib;
      case Prayer.isha:    return isha;
    }
  }

  /// All prayers in order
  List<Prayer> get allPrayers => Prayer.values;

  /// Determine which prayer is currently active (time has passed but next hasn't)
  Prayer? get currentPrayer {
    final now = DateTime.now();
    if (now.isBefore(fajr)) return null;
    if (now.isBefore(sunrise)) return Prayer.fajr;
    if (now.isBefore(dhuhr)) return Prayer.sunrise;
    if (now.isBefore(asr)) return Prayer.dhuhr;
    if (now.isBefore(maghrib)) return Prayer.asr;
    if (now.isBefore(isha)) return Prayer.maghrib;
    return Prayer.isha;
  }

  /// Determine which prayer is coming next.
  /// After Isha, wraps around to Fajr (tomorrow's cycle).
  Prayer? get nextPrayer {
    final now = DateTime.now();
    if (now.isBefore(fajr))    return Prayer.fajr;
    if (now.isBefore(sunrise)) return Prayer.sunrise;
    if (now.isBefore(dhuhr))   return Prayer.dhuhr;
    if (now.isBefore(asr))     return Prayer.asr;
    if (now.isBefore(maghrib)) return Prayer.maghrib;
    if (now.isBefore(isha))    return Prayer.isha;
    // Past Isha — next prayer is Fajr tomorrow
    return Prayer.fajr;
  }

  /// Time remaining until next prayer.
  /// After Isha, counts down to tomorrow's Fajr if available.
  Duration? get timeUntilNextPrayer {
    final now = DateTime.now();
    if (now.isBefore(isha)) {
      // Normal case — next prayer is still today
      final next = nextPrayer;
      if (next == null) return null;
      return timeFor(next).difference(now);
    }
    // Past Isha — count down to tomorrow's Fajr
    final tf = tomorrowFajr;
    if (tf == null) return null;
    return tf.difference(now);
  }

  /// Progress through the day (0.0 = Fajr, 1.0 = Isha)
  /// After Isha resets to 0.0 so the timeline widget wraps cleanly.
  double get dayProgress {
    final now = DateTime.now();
    if (now.isBefore(fajr)) return 0.0;
    if (!now.isBefore(isha)) return 0.0; // reset after Isha
    final total = isha.difference(fajr).inSeconds;
    final elapsed = now.difference(fajr).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }
}

/// User's prayer notification preferences
class PrayerNotificationPrefs {
  final bool masterEnabled;
  final bool fajrEnabled;
  final bool sunriseEnabled;
  final bool dhuhrEnabled;
  final bool asrEnabled;
  final bool maghribEnabled;
  final bool ishaEnabled;
  final int offsetMinutes;

  const PrayerNotificationPrefs({
    this.masterEnabled = true,
    this.fajrEnabled = true,
    this.sunriseEnabled = false,
    this.dhuhrEnabled = true,
    this.asrEnabled = true,
    this.maghribEnabled = true,
    this.ishaEnabled = true,
    this.offsetMinutes = 0,
  });

  bool isEnabledFor(Prayer prayer) {
    if (!masterEnabled) return false;
    switch (prayer) {
      case Prayer.fajr:    return fajrEnabled;
      case Prayer.sunrise: return false;
      case Prayer.dhuhr:   return dhuhrEnabled;
      case Prayer.asr:     return asrEnabled;
      case Prayer.maghrib: return maghribEnabled;
      case Prayer.isha:    return ishaEnabled;
    }
  }

  PrayerNotificationPrefs copyWith({
    bool? masterEnabled,
    bool? fajrEnabled,
    bool? dhuhrEnabled,
    bool? asrEnabled,
    bool? maghribEnabled,
    bool? ishaEnabled,
    int? offsetMinutes,
  }) {
    return PrayerNotificationPrefs(
      masterEnabled: masterEnabled ?? this.masterEnabled,
      fajrEnabled: fajrEnabled ?? this.fajrEnabled,
      dhuhrEnabled: dhuhrEnabled ?? this.dhuhrEnabled,
      asrEnabled: asrEnabled ?? this.asrEnabled,
      maghribEnabled: maghribEnabled ?? this.maghribEnabled,
      ishaEnabled: ishaEnabled ?? this.ishaEnabled,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
        'masterEnabled': masterEnabled,
        'fajrEnabled': fajrEnabled,
        'dhuhrEnabled': dhuhrEnabled,
        'asrEnabled': asrEnabled,
        'maghribEnabled': maghribEnabled,
        'ishaEnabled': ishaEnabled,
        'offsetMinutes': offsetMinutes,
      };

  factory PrayerNotificationPrefs.fromJson(Map<String, dynamic> json) {
    return PrayerNotificationPrefs(
      masterEnabled: json['masterEnabled'] as bool? ?? true,
      fajrEnabled: json['fajrEnabled'] as bool? ?? true,
      dhuhrEnabled: json['dhuhrEnabled'] as bool? ?? true,
      asrEnabled: json['asrEnabled'] as bool? ?? true,
      maghribEnabled: json['maghribEnabled'] as bool? ?? true,
      ishaEnabled: json['ishaEnabled'] as bool? ?? true,
      offsetMinutes: json['offsetMinutes'] as int? ?? 0,
    );
  }
}

/// Calculation method + madhab settings
class PrayerCalculationSettings {
  final String methodKey;
  final bool isHanafi;

  const PrayerCalculationSettings({
    this.methodKey = 'karachi',
    this.isHanafi = true,
  });

  static const Map<String, String> methodNames = {
    'karachi':           'University of Islamic Sciences, Karachi',
    'muslimWorldLeague': 'Muslim World League',
    'egyptian':          'Egyptian General Authority of Survey',
    'ummAlQura':         'Umm al-Qura University, Makkah',
    'dubai':             'Dubai',
    'kuwait':            'Kuwait',
    'qatar':             'Qatar',
    'singapore':         'Majlis Ugama Islam Singapura',
    'northAmerica':      'Islamic Society of North America',
    'moon':              'Moonsighting Committee Worldwide',
  };

  CalculationParameters get adhanParams {
    CalculationParameters params;
    switch (methodKey) {
      case 'muslimWorldLeague':
        params = CalculationMethod.muslim_world_league.getParameters();
        break;
      case 'egyptian':
        params = CalculationMethod.egyptian.getParameters();
        break;
      case 'ummAlQura':
        params = CalculationMethod.umm_al_qura.getParameters();
        break;
      case 'dubai':
        params = CalculationMethod.dubai.getParameters();
        break;
      case 'kuwait':
        params = CalculationMethod.kuwait.getParameters();
        break;
      case 'qatar':
        params = CalculationMethod.qatar.getParameters();
        break;
      case 'singapore':
        params = CalculationMethod.singapore.getParameters();
        break;
      case 'northAmerica':
        params = CalculationMethod.north_america.getParameters();
        break;
      case 'moon':
        params = CalculationMethod.moon_sighting_committee.getParameters();
        break;
      case 'karachi':
      default:
        params = CalculationMethod.karachi.getParameters();
        break;
    }
    params.madhab = isHanafi ? Madhab.hanafi : Madhab.shafi;
    return params;
  }

  PrayerCalculationSettings copyWith({
    String? methodKey,
    bool? isHanafi,
  }) {
    return PrayerCalculationSettings(
      methodKey: methodKey ?? this.methodKey,
      isHanafi: isHanafi ?? this.isHanafi,
    );
  }

  Map<String, dynamic> toJson() => {
        'methodKey': methodKey,
        'isHanafi': isHanafi,
      };

  factory PrayerCalculationSettings.fromJson(Map<String, dynamic> json) {
    return PrayerCalculationSettings(
      methodKey: json['methodKey'] as String? ?? 'karachi',
      isHanafi: json['isHanafi'] as bool? ?? true,
    );
  }
}