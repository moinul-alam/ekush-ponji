// lib/features/prayer_times/widgets/next_prayer_card.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/prayer_times/models/prayer_times_model.dart';

class NextPrayerCard extends StatelessWidget {
  final PrayerTimesModel times;
  final Prayer? nextPrayer;
  final Duration? countdownToNextPrayer;

  const NextPrayerCard({
    super.key,
    required this.times,
    required this.nextPrayer,
    required this.countdownToNextPrayer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    if (nextPrayer == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(Icons.nights_stay_rounded, color: cs.onPrimaryContainer, size: 32),
            const SizedBox(width: 16),
            Text(
              l10n.allPrayersCompletedToday,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final currentPrayer = times.currentPrayer;
    final currentRemaining = times.timeUntilCurrentPrayerEnds;

    final currentName = currentPrayer != null
        ? currentPrayer.nameForLocale(l10n.languageCode)
        : '--';

    final currentRemainingStr = currentRemaining != null
        ? _formatCountdown(currentRemaining, l10n)
        : '--:--:--';

    final nextName = nextPrayer != null
        ? nextPrayer!.nameForLocale(l10n.languageCode)
        : '--';

    final nextRemainingStr = countdownToNextPrayer != null
        ? _formatCountdown(countdownToNextPrayer!, l10n)
        : '--:--:--';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.currentPrayer,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onPrimary.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentRemainingStr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cs.onPrimary.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.nextPrayer,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onPrimary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nextName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nextRemainingStr,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCountdown(Duration d, AppLocalizations l10n) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '${_localizePadded(h, l10n)}:${_localizePadded(m, l10n)}:${_localizePadded(s, l10n)}';
  }

  String _localizePadded(String padded, AppLocalizations l10n) {
    return padded.split('').map((c) {
      final digit = int.tryParse(c);
      return digit != null ? l10n.localizeNumber(digit) : c;
    }).join();
  }
}