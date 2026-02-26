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
    final now = DateTime.now();

    final points = [
      _Point(Prayer.fajr.nameForLocale(l10n.languageCode),    times.fajr,    Prayer.fajr),
      _Point(Prayer.dhuhr.nameForLocale(l10n.languageCode),   times.dhuhr,   Prayer.dhuhr),
      _Point(Prayer.asr.nameForLocale(l10n.languageCode),     times.asr,     Prayer.asr),
      _Point(Prayer.maghrib.nameForLocale(l10n.languageCode), times.maghrib, Prayer.maghrib),
      _Point(Prayer.isha.nameForLocale(l10n.languageCode),    times.isha,    Prayer.isha),
    ];

    final nextPrayer = times.nextPrayer;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer.withOpacity(0.45),
            cs.tertiaryContainer.withOpacity(0.35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: cs.primary.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────
            Row(
              children: [
                Icon(Icons.linear_scale_rounded,
                    size: 14, color: cs.primary.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text(
                  l10n.languageCode == 'bn'
                      ? 'দিনের অগ্রগতি'
                      : "Today's Progress",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.primary.withOpacity(0.8),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Timeline ────────────────────────────────────
            LayoutBuilder(builder: (context, constraints) {
              final fullWidth = constraints.maxWidth;

              const inset      = 20.0;
              final trackWidth = fullWidth - inset * 2;

              const labelH  = 18.0;
              const gap1    = 8.0;
              const barH    = 6.0;
              const dotD    = 10.0;
              const nextD   = 16.0;
              const gap2    = 10.0;
              const timeH   = 32.0;
              const thumbD  = 18.0;
              const glowD   = thumbD + 6;

              final barTop   = labelH + gap1;
              final timeTop  = barTop + barH + gap2;
              final totalH   = labelH + gap1 + barH + gap2 + timeH;

              final xs = List.generate(5, (i) => inset + trackWidth * (i / 4.0));

              final thumbFraction = _interpolateThumbFraction(now, points);
              final progressX     = inset + trackWidth * thumbFraction;
              final progressFill  = (trackWidth * thumbFraction).clamp(0.0, trackWidth);

              // After Isha: all prayers are "past" visually, but we treat it
              // as a reset — show no fill and highlight Fajr as next.
              final afterIsha = now.isAfter(points.last.time) ||
                  now.isAtSameMomentAs(points.last.time);

              return SizedBox(
                height: totalH,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // ── Background track ───────────────────
                    Positioned(
                      left: inset,
                      top: barTop,
                      width: trackWidth,
                      child: Container(
                        height: barH,
                        decoration: BoxDecoration(
                          color: cs.onSurface.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    // ── Filled progress track ──────────────
                    // Hidden after Isha so it resets visually to empty.
                    if (!afterIsha)
                      Positioned(
                        left: inset,
                        top: barTop,
                        child: Container(
                          width: progressFill,
                          height: barH,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [cs.primary, cs.tertiary],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ── Prayer dots ────────────────────────
                    ...List.generate(points.length, (i) {
                      final point  = points[i];
                      final cx     = xs[i];

                      // After Isha, treat all prayers as "past" except Fajr,
                      // which becomes the next prayer (tomorrow).
                      final isPast = afterIsha
                          ? (point.prayer != Prayer.fajr)
                          : point.time.isBefore(now);

                      // nextPrayer from the model drives the highlight.
                      // After Isha the model should return Prayer.fajr.
                      final isNext = nextPrayer != null &&
                          point.prayer == nextPrayer;

                      final thisDotD = isNext ? nextD : dotD;
                      final dotTop   = barTop + barH / 2 - thisDotD / 2;

                      const labelW = 52.0;
                      final labelLeft =
                          (cx - labelW / 2).clamp(0.0, fullWidth - labelW);

                      const timeW = 52.0;
                      final timeLeft =
                          (cx - timeW / 2).clamp(0.0, fullWidth - timeW);

                      return Stack(children: [
                        // Label above bar
                        Positioned(
                          left: labelLeft,
                          top: 0,
                          width: labelW,
                          child: Text(
                            point.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: isNext
                                  ? FontWeight.w800
                                  : isPast
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                              color: isNext
                                  ? cs.primary
                                  : isPast
                                      ? cs.onPrimaryContainer
                                      : cs.onSurfaceVariant.withOpacity(0.5),
                            ),
                          ),
                        ),

                        // Dot on bar
                        Positioned(
                          left: cx - thisDotD / 2,
                          top: dotTop,
                          child: Container(
                            width: thisDotD,
                            height: thisDotD,
                            decoration: BoxDecoration(
                              color: isPast ? cs.primary : cs.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isPast || isNext
                                    ? cs.primary
                                    : cs.onSurface.withOpacity(0.2),
                                width: isNext ? 2.0 : 1.5,
                              ),
                              boxShadow: isNext
                                  ? [
                                      BoxShadow(
                                        color: cs.primary.withOpacity(0.25),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),

                        // Time below bar
                        Positioned(
                          left: timeLeft,
                          top: timeTop,
                          width: timeW,
                          child: Text(
                            _formatTime(point.time, l10n),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              height: 1.4,
                              color: isNext
                                  ? cs.primary.withOpacity(0.9)
                                  : isPast
                                      ? cs.onSurface.withOpacity(0.55)
                                      : cs.onSurfaceVariant.withOpacity(0.35),
                              fontWeight: isNext
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ]);
                    }),

                    // ── Current time thumb ─────────────────
                    // Only shown between Fajr and Isha (thumbFraction > 0.0).
                    if (thumbFraction > 0.0)
                      Positioned(
                        left: progressX - glowD / 2,
                        top: barTop + barH / 2 - glowD / 2,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: glowD,
                              height: glowD,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cs.primary.withOpacity(0.2),
                              ),
                            ),
                            Container(
                              width: thumbD,
                              height: thumbD,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: cs.surface, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: cs.primary.withOpacity(0.6),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Piecewise linear interpolation ───────────────────────────
  //
  // Returns a fraction [0.0, 1.0) representing thumb position on the track.
  // After Isha: returns 0.0 to reset the timeline — the day cycle is complete
  // and Fajr (tomorrow) becomes the next prayer via PrayerTimesModel.nextPrayer.
  double _interpolateThumbFraction(DateTime now, List<_Point> points) {
    const segmentSize = 1.0 / 4.0;

    // Before Fajr → not yet started
    if (now.isBefore(points.first.time)) return 0.0;

    // After Isha → day complete, reset to 0.0 (Fajr tomorrow is next)
    if (!now.isBefore(points.last.time)) return 0.0;

    for (int i = 0; i < points.length - 1; i++) {
      final segStart = points[i].time;
      final segEnd   = points[i + 1].time;

      if ((now.isAtSameMomentAs(segStart) || now.isAfter(segStart)) &&
          now.isBefore(segEnd)) {
        final segDuration = segEnd.difference(segStart).inSeconds.toDouble();
        final elapsed     = now.difference(segStart).inSeconds.toDouble();
        final segFraction = elapsed / segDuration;
        final visualStart = i * segmentSize;
        return visualStart + segFraction * segmentSize;
      }
    }

    return 0.0;
  }

  String _formatTime(DateTime time, AppLocalizations l10n) {
    final hour      = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute    = time.minute.toString().padLeft(2, '0');
    final period    = time.hour < 12 ? 'AM' : 'PM';
    final hourStr   = l10n.localizeNumber(hour);
    final minuteStr = _localizePadded(minute, l10n);
    return '$hourStr:$minuteStr\n$period';
  }

  String _localizePadded(String padded, AppLocalizations l10n) {
    return padded.split('').map((c) {
      final d = int.tryParse(c);
      return d != null ? l10n.localizeNumber(d) : c;
    }).join();
  }
}

class _Point {
  final String label;
  final DateTime time;
  final Prayer prayer;
  const _Point(this.label, this.time, this.prayer);
}