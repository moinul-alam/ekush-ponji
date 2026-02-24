// lib/features/prayer_times/widgets/prayer_list_widget.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/prayer_times/models/prayer_times_model.dart';

class PrayerListWidget extends StatelessWidget {
  final PrayerTimesModel times;
  final Prayer? highlightedPrayer;
  final PrayerNotificationPrefs notifPrefs;
  final void Function(Prayer prayer, bool enabled) onToggleNotification;

  const PrayerListWidget({
    super.key,
    required this.times,
    required this.highlightedPrayer,
    required this.notifPrefs,
    required this.onToggleNotification,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: Column(
        children: Prayer.values.asMap().entries.map((entry) {
          final index = entry.key;
          final prayer = entry.value;
          final isLast = index == Prayer.values.length - 1;
          return _PrayerRow(
            prayer: prayer,
            time: times.timeFor(prayer),
            isHighlighted: prayer == highlightedPrayer,
            notifPrefs: notifPrefs,
            onToggle: prayer.isNotifiable
                ? (val) => onToggleNotification(prayer, val)
                : null,
            showDivider: !isLast,
            l10n: l10n,
            theme: theme,
          );
        }).toList(),
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final Prayer prayer;
  final DateTime time;
  final bool isHighlighted;
  final PrayerNotificationPrefs notifPrefs;
  final void Function(bool)? onToggle;
  final bool showDivider;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _PrayerRow({
    required this.prayer,
    required this.time,
    required this.isHighlighted,
    required this.notifPrefs,
    required this.onToggle,
    required this.showDivider,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final isPast = time.isBefore(DateTime.now());

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isHighlighted
                ? cs.primaryContainer.withOpacity(0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(
              showDivider ? 0 : 20,
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // ── Prayer icon ──────────────────────────
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? cs.primary.withOpacity(0.12)
                        : cs.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _prayerIcon(prayer),
                    size: 20,
                    color: isHighlighted
                        ? cs.primary
                        : isPast
                            ? cs.onSurfaceVariant.withOpacity(0.5)
                            : cs.onSurfaceVariant,
                  ),
                ),

                const SizedBox(width: 14),

                // ── Prayer name ──────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prayer.nameForLocale(l10n.languageCode),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: isHighlighted
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isHighlighted
                              ? cs.onSurface
                              : isPast
                                  ? cs.onSurface.withOpacity(0.45)
                                  : cs.onSurface,
                        ),
                      ),
                      if (isHighlighted)
                        Text(
                          l10n.languageCode == 'bn'
                              ? 'পরবর্তী নামাজ'
                              : 'Next prayer',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Time ─────────────────────────────────
                Text(
                  _formatTime(time),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
                    color: isHighlighted
                        ? cs.primary
                        : isPast
                            ? cs.onSurface.withOpacity(0.4)
                            : cs.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),

                // ── Notification toggle ───────────────────
                if (onToggle != null && notifPrefs.masterEnabled) ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () =>
                        onToggle!(!notifPrefs.isEnabledFor(prayer)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: notifPrefs.isEnabledFor(prayer)
                            ? cs.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        notifPrefs.isEnabledFor(prayer)
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_outlined,
                        size: 18,
                        color: notifPrefs.isEnabledFor(prayer)
                            ? cs.primary
                            : cs.onSurfaceVariant.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  IconData _prayerIcon(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:    return Icons.wb_twilight_rounded;
      case Prayer.sunrise: return Icons.wb_sunny_outlined;
      case Prayer.dhuhr:   return Icons.wb_sunny_rounded;
      case Prayer.asr:     return Icons.wb_cloudy_outlined;
      case Prayer.maghrib: return Icons.wb_twilight_rounded;
      case Prayer.isha:    return Icons.nights_stay_rounded;
    }
  }
}