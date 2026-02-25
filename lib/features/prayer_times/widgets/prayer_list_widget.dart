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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section 1: Sunrise & Sunset ─────────────────────
        _SectionLabel(
          label: l10n.languageCode == 'bn' ? 'সূর্য' : 'Sun',
          theme: theme,
          cs: cs,
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              _SunRow(
                label: l10n.languageCode == 'bn' ? 'সূর্যোদয়' : 'Sunrise',
                time: times.sunrise,
                icon: Icons.wb_sunny_outlined,
                l10n: l10n,
                theme: theme,
                cs: cs,
                showDivider: true,
              ),
              _SunRow(
                label: l10n.languageCode == 'bn' ? 'সূর্যাস্ত' : 'Sunset',
                time: times.maghrib,
                icon: Icons.nights_stay_outlined,
                l10n: l10n,
                theme: theme,
                cs: cs,
                showDivider: false,
              ),
            ],
          ),
        ),

        // ── Section 2: 5 Prayers ─────────────────────────────
        _SectionLabel(
          label: l10n.languageCode == 'bn' ? 'নামাজ' : 'Prayers',
          theme: theme,
          cs: cs,
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Prayer.fajr,
              Prayer.dhuhr,
              Prayer.asr,
              Prayer.maghrib,
              Prayer.isha,
            ].asMap().entries.map((entry) {
              final index = entry.key;
              final prayer = entry.value;
              final isLast = index == 4;
              return _PrayerRow(
                prayer: prayer,
                time: times.timeFor(prayer),
                isHighlighted: prayer == highlightedPrayer,
                notifPrefs: notifPrefs,
                onToggle: (val) => onToggleNotification(prayer, val),
                showDivider: !isLast,
                l10n: l10n,
                theme: theme,
                cs: cs,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Sun row (no notification) ──────────────────────────────────

class _SunRow extends StatelessWidget {
  final String label;
  final DateTime time;
  final IconData icon;
  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme cs;
  final bool showDivider;

  const _SunRow({
    required this.label,
    required this.time,
    required this.icon,
    required this.l10n,
    required this.theme,
    required this.cs,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = time.isBefore(DateTime.now());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: cs.tertiaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: cs.tertiary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isPast
                        ? cs.onSurface.withOpacity(0.45)
                        : cs.onSurface,
                  ),
                ),
              ),
              Text(
                _formatTime(time, l10n),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isPast
                      ? cs.onSurface.withOpacity(0.4)
                      : cs.tertiary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1, indent: 16, endIndent: 16,
            color: cs.outlineVariant.withOpacity(0.3),
          ),
      ],
    );
  }

  String _formatTime(DateTime time, AppLocalizations l10n) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    final hourStr = l10n.localizeNumber(hour);
    final minuteStr = _localizePadded(minute, l10n);
    return '$hourStr:$minuteStr $period';
  }

  String _localizePadded(String padded, AppLocalizations l10n) {
    return padded.split('').map((c) {
      final digit = int.tryParse(c);
      return digit != null ? l10n.localizeNumber(digit) : c;
    }).join();
  }
}

// ── Prayer row (with notification toggle) ─────────────────────

class _PrayerRow extends StatelessWidget {
  final Prayer prayer;
  final DateTime time;
  final bool isHighlighted;
  final PrayerNotificationPrefs notifPrefs;
  final void Function(bool) onToggle;
  final bool showDivider;
  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme cs;

  const _PrayerRow({
    required this.prayer,
    required this.time,
    required this.isHighlighted,
    required this.notifPrefs,
    required this.onToggle,
    required this.showDivider,
    required this.l10n,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = time.isBefore(DateTime.now());
    final notifEnabled = notifPrefs.isEnabledFor(prayer);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: isHighlighted
              ? cs.primaryContainer.withOpacity(0.4)
              : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? cs.primary.withOpacity(0.12)
                        : cs.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _prayerIcon(prayer),
                    size: 18,
                    color: isHighlighted
                        ? cs.primary
                        : isPast
                            ? cs.onSurfaceVariant.withOpacity(0.4)
                            : cs.onSurfaceVariant,
                  ),
                ),

                const SizedBox(width: 14),

                // Name
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
                          color: isPast && !isHighlighted
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),

                // Time
                Text(
                  _formatTime(time, l10n),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight:
                        isHighlighted ? FontWeight.w800 : FontWeight.w600,
                    color: isHighlighted
                        ? cs.primary
                        : isPast
                            ? cs.onSurface.withOpacity(0.4)
                            : cs.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),

                // Notification toggle
                if (notifPrefs.masterEnabled) ...[
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => onToggle(!notifEnabled),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: notifEnabled
                            ? cs.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        notifEnabled
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_outlined,
                        size: 18,
                        color: notifEnabled
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
            height: 1, indent: 16, endIndent: 16,
            color: cs.outlineVariant.withOpacity(0.3),
          ),
      ],
    );
  }

  String _formatTime(DateTime time, AppLocalizations l10n) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    final hourStr = l10n.localizeNumber(hour);
    final minuteStr = _localizePadded(minute, l10n);
    return '$hourStr:$minuteStr $period';
  }

  String _localizePadded(String padded, AppLocalizations l10n) {
    return padded.split('').map((c) {
      final digit = int.tryParse(c);
      return digit != null ? l10n.localizeNumber(digit) : c;
    }).join();
  }

  IconData _prayerIcon(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:    return Icons.wb_twilight_rounded;
      case Prayer.dhuhr:   return Icons.wb_sunny_rounded;
      case Prayer.asr:     return Icons.wb_cloudy_outlined;
      case Prayer.maghrib: return Icons.wb_twilight_rounded;
      case Prayer.isha:    return Icons.nights_stay_rounded;
      default:             return Icons.circle_outlined;
    }
  }
}

// ── Section label ──────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeData theme;
  final ColorScheme cs;

  const _SectionLabel({
    required this.label,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}