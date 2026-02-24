// lib/features/prayer_times/widgets/prayer_timeline_widget.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/prayer_times/models/prayer_times_model.dart';

class PrayerTimelineWidget extends StatelessWidget {
  final PrayerTimesModel times;

  const PrayerTimelineWidget({super.key, required this.times});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final progress = times.dayProgress.clamp(0.0, 1.0);

    final now = DateTime.now();

    /// ✅ Include sunrise & sunset
    final markers = [
      (Prayer.fajr, times.fajr),
      (Prayer.sunrise, times.sunrise), // exists
      (Prayer.dhuhr, times.dhuhr),
      (Prayer.asr, times.asr),
      (Prayer.maghrib, times.maghrib), // sunset = maghrib
      (Prayer.isha, times.isha),
    ];  

    final totalSpan =
        times.isha.difference(times.fajr).inSeconds.toDouble();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.languageCode == 'bn'
                    ? 'দিনের অগ্রগতি'
                    : 'Day Progress',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// Timeline
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              return SizedBox(
                height: 56,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    /// Background track
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 22,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),

                    /// Progress track
                    Positioned(
                      left: 0,
                      top: 22,
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 400),
                        width: width * progress,
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              cs.primary,
                              cs.tertiary,
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(3),
                        ),
                      ),
                    ),

                    /// Markers
                    ...markers.map((entry) {
                      final prayer = entry.$1;
                      final time = entry.$2;

                      final isPast = time.isBefore(now);

                      final elapsed =
                          time.difference(times.fajr).inSeconds;

                      final fraction =
                          (elapsed / totalSpan).clamp(0.0, 1.0);

                      /// Prevent overflow at edges
                      final x =
                          (fraction * width).clamp(8.0, width - 8);

                      final label = _shortLabel(
                        prayer,
                        l10n.languageCode,
                      );

                      return Positioned(
                        left: x - 10,
                        top: 8,
                        child: Column(
                          children: [
                            /// Dot
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: isPast
                                    ? cs.primary
                                    : cs.outlineVariant,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: cs.surface,
                                  width: 2,
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            /// Label
                            SizedBox(
                              width: 32,
                              child: Text(
                                label,
                                style: theme
                                    .textTheme.labelSmall
                                    ?.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: isPast
                                      ? cs.primary
                                      : cs.onSurfaceVariant
                                          .withOpacity(0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    /// Current time thumb
                    Positioned(
                      left: (width * progress)
                              .clamp(6.0, width - 6) -
                          6,
                      top: 14,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: cs.surface,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  cs.primary.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          /// Start & End labels
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(times.fajr),
                style: theme.textTheme.labelSmall,
              ),
              Text(
                _formatTime(times.isha),
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Short label logic (prevents overflow)
  String _shortLabel(Prayer prayer, String lang) {
    if (lang == 'bn') {
      switch (prayer) {
        case Prayer.fajr:
          return 'ফজর';
        case Prayer.sunrise:
          return 'সূর্যোদয়';
        case Prayer.dhuhr:
          return 'যোহর';
        case Prayer.asr:
          return 'আসর';
        case Prayer.maghrib:
          return 'মাগরিব';
        case Prayer.isha:
          return 'ইশা';
      }
    } else {
      switch (prayer) {
        case Prayer.fajr:
          return 'Fajr';
        case Prayer.sunrise:
          return 'Sunrise';
        case Prayer.dhuhr:
          return 'Dhuhr';
        case Prayer.asr:
          return 'Asr';
        case Prayer.maghrib:
          return 'Maghrib';
        case Prayer.isha:
          return 'Isha';
      }
    }
  }

  String _formatTime(DateTime time) {
    final hour =
        time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute =
        time.minute.toString().padLeft(2, '0');
    final period =
        time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}