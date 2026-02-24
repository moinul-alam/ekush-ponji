// lib/features/prayer_times/widgets/next_prayer_card.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/prayer_times/models/prayer_times_model.dart';

class NextPrayerCard extends StatelessWidget {
  final Prayer? nextPrayer;
  final DateTime? nextPrayerTime;
  final Duration? countdown;

  const NextPrayerCard({
    super.key,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.countdown,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    if (nextPrayer == null) {
      // Past Isha — all prayers done for today
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(Icons.nights_stay_rounded,
                color: cs.onPrimaryContainer, size: 32),
            const SizedBox(width: 16),
            Text(
              l10n.languageCode == 'bn'
                  ? 'আজকের সকল নামাজ সম্পন্ন'
                  : 'All prayers completed for today',
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final timeStr = nextPrayerTime != null
        ? _formatTime(nextPrayerTime!)
        : '--:--';

    final countdownStr = countdown != null
        ? _formatCountdown(countdown!)
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
            // Left: label + prayer name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.languageCode == 'bn' ? 'পরবর্তী নামাজ' : 'Next Prayer',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onPrimary.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextPrayer!.nameForLocale(l10n.languageCode),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeStr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cs.onPrimary.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Right: countdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.languageCode == 'bn' ? 'বাকি সময়' : 'Remaining',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onPrimary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  countdownStr,
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

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _formatCountdown(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}