// lib/features/prayer_times/widgets/prayer_settings_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/prayer_times/models/prayer_times_model.dart';
import 'package:ekush_ponji/features/prayer_times/prayer_settings_viewmodel.dart';
import 'package:ekush_ponji/core/services/local_notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class PrayerSettingsSheet extends ConsumerWidget {
  final VoidCallback onSettingsChanged;

  const PrayerSettingsSheet({super.key, required this.onSettingsChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(prayerSettingsViewModelProvider);
    final vm = ref.read(prayerSettingsViewModelProvider.notifier);
    final calc = settings.calculationSettings;
    final notif = settings.notificationPrefs;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ── Title ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.tune_rounded, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.prayerSettingsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Calculation method ───────────────────
                  _SectionHeader(
                    label: l10n.prayerCalculationMethod,
                    theme: theme,
                    cs: cs,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: cs.outlineVariant.withOpacity(0.4)),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: calc.methodKey,
                        isExpanded: true,
                        dropdownColor: cs.surface,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface,
                        ),
                        items: PrayerCalculationSettings.methodNames.entries
                            .map((e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Text(e.value,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            vm.setMethodKey(val);
                            onSettingsChanged();
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Madhab ───────────────────────────────
                  _SectionHeader(
                    label: l10n.prayerMadhab,
                    theme: theme,
                    cs: cs,
                  ),
                  const SizedBox(height: 8),
                  _SegmentRow(
                    selected: calc.isHanafi,
                    leftLabel: l10n.prayerMadhabHanafi,
                    rightLabel: l10n.prayerMadhabShafii,
                    onLeft: () {
                      vm.setHanafi(true);
                      onSettingsChanged();
                    },
                    onRight: () {
                      vm.setHanafi(false);
                      onSettingsChanged();
                    },
                    theme: theme,
                    cs: cs,
                  ),

                  const SizedBox(height: 24),
                  Divider(color: cs.outlineVariant.withOpacity(0.4)),
                  const SizedBox(height: 16),

                  // ── Master notification switch ────────────
                  _SectionHeader(
                    label: l10n.prayerNotificationsTitle,
                    theme: theme,
                    cs: cs,
                  ),
                  const SizedBox(height: 8),
                  _SettingsTile(
                    label: l10n.prayerEnableNotifications,
                    subtitle: l10n.prayerNotificationsSubtitle,
                    trailing: Switch(
                      value: notif.masterEnabled,
                      onChanged: (val) async {
                        if (val) {
                          final ok =
                              await LocalNotificationService.ensurePermission();
                          if (!ok) {
                            if (context.mounted) {
                              await showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(l10n.notifications),
                                  content: Text(
                                      l10n.notificationsPermissionRequired),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text(l10n.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        await openAppSettings();
                                      },
                                      child: Text(l10n.openSettings),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return;
                          }
                        }
                        await vm.setMasterEnabled(val);
                        onSettingsChanged();
                      },
                    ),
                    theme: theme,
                    cs: cs,
                  ),

                  // ── Per-prayer toggles ────────────────────
                  if (notif.masterEnabled) ...[
                    const SizedBox(height: 12),
                    _SectionHeader(
                      label: l10n.prayerPerPrayerTitle,
                      theme: theme,
                      cs: cs,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: cs.outlineVariant.withOpacity(0.4)),
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
                          return Column(
                            children: [
                              _PrayerToggleRow(
                                prayer: prayer,
                                enabled: notif.isEnabledFor(prayer),
                                l10n: l10n,
                                theme: theme,
                                cs: cs,
                                onChanged: (val) async {
                                  if (val) {
                                    final ok =
                                        await LocalNotificationService
                                            .ensurePermission();
                                    if (!ok) {
                                      if (context.mounted) {
                                        await showDialog<void>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(l10n.notifications),
                                            content: Text(l10n
                                                .notificationsPermissionRequired),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: Text(l10n.cancel),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.of(context).pop();
                                                  await openAppSettings();
                                                },
                                                child: Text(l10n.openSettings),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return;
                                    }
                                  }
                                  await vm.setPrayerEnabled(prayer, val);
                                  onSettingsChanged();
                                },
                              ),
                              if (!isLast)
                                Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                  color:
                                      cs.outlineVariant.withOpacity(0.3),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Notification offset ──────────────────
                    _SectionHeader(
                      label: l10n.prayerNotifyBeforeTitle,
                      theme: theme,
                      cs: cs,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [0, 5, 10].map((minutes) {
                        final isSelected = notif.offsetMinutes == minutes;
                        final label = minutes == 0
                            ? l10n.prayerNotifyOnTime
                            : l10n.formatNamed(
                                l10n.prayerNotifyMinutesBefore,
                                {'minutes': l10n.localizeNumber(minutes)},
                              );
                        return Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await vm.setOffsetMinutes(minutes);
                              onSettingsChanged();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? cs.primaryContainer
                                    : cs.surfaceContainerHighest
                                        .withOpacity(0.4),
                                borderRadius: BorderRadius.circular(10),
                                border: isSelected
                                    ? Border.all(
                                        color: cs.primary, width: 1.5)
                                    : Border.all(
                                        color: cs.outlineVariant
                                            .withOpacity(0.4)),
                              ),
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? cs.onPrimaryContainer
                                      : cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final ThemeData theme;
  final ColorScheme cs;

  const _SectionHeader({
    required this.label,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: theme.textTheme.labelMedium?.copyWith(
        color: cs.onSurfaceVariant,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final Widget trailing;
  final ThemeData theme;
  final ColorScheme cs;

  const _SettingsTile({
    required this.label,
    this.subtitle,
    required this.trailing,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: ListTile(
        title: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              )
            : null,
        trailing: trailing,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

class _SegmentRow extends StatelessWidget {
  final bool selected; // true = left selected
  final String leftLabel;
  final String rightLabel;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final ThemeData theme;
  final ColorScheme cs;

  const _SegmentRow({
    required this.selected,
    required this.leftLabel,
    required this.rightLabel,
    required this.onLeft,
    required this.onRight,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Segment(
          label: leftLabel,
          isSelected: selected,
          onTap: onLeft,
          isLeft: true,
          theme: theme,
          cs: cs,
        ),
        _Segment(
          label: rightLabel,
          isSelected: !selected,
          onTap: onRight,
          isLeft: false,
          theme: theme,
          cs: cs,
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLeft;
  final ThemeData theme;
  final ColorScheme cs;

  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isLeft,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? cs.primary : cs.surfaceContainerHighest.withOpacity(0.4),
            borderRadius: BorderRadius.horizontal(
              left: isLeft ? const Radius.circular(12) : Radius.zero,
              right: !isLeft ? const Radius.circular(12) : Radius.zero,
            ),
            border: Border.all(
              color: isSelected ? cs.primary : cs.outlineVariant.withOpacity(0.4),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrayerToggleRow extends StatelessWidget {
  final Prayer prayer;
  final bool enabled;
  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme cs;
  final ValueChanged<bool> onChanged;

  const _PrayerToggleRow({
    required this.prayer,
    required this.enabled,
    required this.l10n,
    required this.theme,
    required this.cs,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            prayer.nameForLocale(l10n.languageCode),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: enabled ? cs.onSurface : cs.onSurface.withOpacity(0.5),
            ),
          ),
          const Spacer(),
          Switch(
            value: enabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}