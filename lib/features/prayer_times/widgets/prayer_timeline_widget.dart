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
    final progress = times.dayProgress;

    // Only show the 5 main prayers on the timeline (not sunrise)
    final markers = [
      (Prayer.fajr, times.fajr),
      (Prayer.dhuhr, times.dhuhr),
      (Prayer.asr, times.asr),
      (Prayer.maghrib, times.maghrib),
      (Prayer.isha, times.isha),
    ];

    final totalSpan = times.isha.difference(times.fajr).inSeconds;

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
          // ── Header ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.languageCode == 'bn' ? 'দিনের অগ্রগতি' : 'Day Progress',
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

          const SizedBox(height: 16),

          // ── Timeline bar ──────────────────────────────────
          LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;

            return SizedBox(
              height: 48,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background track
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 18,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  // Filled progress track
                  Positioned(
                    left: 0,
                    top: 18,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: (width * progress).clamp(0.0, width),
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            cs.primary,
                            cs.tertiary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  // Prayer markers
                  ...markers.map((entry) {
                    final prayer = entry.$1;
                    final time = entry.$2;
                    final isPast = time.isBefore(DateTime.now());

                    final elapsed =
                        time.difference(times.fajr).inSeconds;
                    final fraction =
                        (elapsed / totalSpan).clamp(0.0, 1.0);
                    final x = width * fraction;

                    return Positioned(
                      left: x - 4,
                      top: 12,
                      child: Column(
                        children: [
                          // Dot
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isPast ? cs.primary : cs.outlineVariant,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: cs.surface,
                                width: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Label
                          SizedBox(
                            width: 36,
                            child: Text(
                              prayer.nameForLocale(l10n.languageCode)
                                  .substring(0, prayer == Prayer.maghrib ? 4 : 3),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 9,
                                color: isPast
                                    ? cs.primary
                                    : cs.onSurfaceVariant.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Current time thumb
                  Positioned(
                    left: (width * progress).clamp(0.0, width - 12) - 6,
                    top: 10,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                        border: Border.all(color: cs.surface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),

          // ── Fajr / Isha labels ────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(times.fajr),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                _formatTime(times.isha),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}