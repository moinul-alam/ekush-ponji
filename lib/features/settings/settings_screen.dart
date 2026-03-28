import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_provider.dart';
import 'package:ekush_ponji/features/settings/settings_viewmodel.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/constants/app_constants.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/features/holidays/providers/holiday_notification_provider.dart';
import 'package:ekush_ponji/features/holidays/holidays_viewmodel.dart';
import 'package:ekush_ponji/features/quotes/providers/quote_notification_prefs_provider.dart';
import 'package:ekush_ponji/features/words/providers/word_notification_prefs_provider.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';
import 'package:ekush_ponji/core/services/app_version_service.dart';

abstract class _SettingsFonts {
  static const double sectionHeader = 13.0;
  static const double tileTitle = 18.0;
  static const double tileSubtitle = 13.0;
  static const double syncSubtitle = 13.0;
  static const double version = 13.0;
}

class SettingsScreen extends BaseScreen {
  const SettingsScreen({super.key});

  @override
  BaseScreenState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends BaseScreenState<SettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(notificationPermissionProvider.notifier).refresh();
    }
  }

  @override
  NotifierProvider<SettingsViewModel, ViewState> get viewModelProvider =>
      settingsViewModelProvider;

  @override
  bool get showLoadingOverlay => false;

  @override
  bool get autoHandleSuccess => true;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppHeader(pageTitle: l10n.settingsTitle);
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(settingsViewModelProvider);

    if (viewState is ViewStateLoading &&
        viewState.message == 'Loading settings...') {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewState is ViewStateError) {
      return buildErrorWidget(viewState);
    }

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final currentTheme = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);
    final currentLanguage = currentLocale.languageCode;

    final osGranted = ref.watch(notificationPermissionProvider).value ?? false;
    final appVersion = ref.watch(appVersionProvider);

    final isSyncing = viewState is ViewStateLoading &&
        viewState.message == 'Updating data...';

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // ── Appearance ────────────────────────────────────────
        _SectionHeader(title: l10n.appearance),
        _SettingsTile(
          icon: Icons.palette_outlined,
          title: l10n.theme,
          subtitle: _getThemeName(currentTheme, l10n),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showThemeDialog(context, ref, l10n),
        ),
        _SettingsTile(
          icon: Icons.language_outlined,
          title: l10n.language,
          subtitle: AppConstants.getLanguageName(currentLanguage),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLanguageDialog(context, ref, l10n, viewModel),
        ),

        const Divider(height: 32),

        // ── Data Sync ─────────────────────────────────────────
        _SectionHeader(title: l10n.dataUpdate),
        ListTile(
          leading: Icon(Icons.sync_rounded, color: colorScheme.primary),
          title: Text(
            l10n.updateAllData,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: _SettingsFonts.tileTitle,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            l10n.updateAllDataSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: _SettingsFonts.tileSubtitle,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: isSyncing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                )
              : const Icon(Icons.chevron_right),
          onTap: isSyncing
              ? null
              : () => ref
                  .read(settingsViewModelProvider.notifier)
                  .syncAllData(widgetRef: ref, l10n: l10n),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
          child: Text(
            _formatLastSyncLine(l10n),
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: _SettingsFonts.syncSubtitle,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        const Divider(height: 32),

        // ── Notifications ─────────────────────────────────────
        _SectionHeader(title: l10n.notifications),

        if (!osGranted) _PermissionBanner(l10n: l10n),

        Consumer(
          builder: (context, ref, _) {
            final holidayEnabled =
                ref.watch(holidayNotificationProvider).enabled;
            final effectiveValue = holidayEnabled && osGranted;
            return _SettingsSwitchTile(
              icon: Icons.celebration_outlined,
              title: l10n.holidayNotifications,
              subtitle: l10n.holidayNotificationsSubtitle,
              value: effectiveValue,
              onChanged: (value) async {
                if (value && !osGranted) {
                  _showPermissionDialog(context, ref, l10n);
                  return;
                }
                final holidays =
                    ref.read(holidaysViewModelProvider.notifier).holidays;
                await ref.read(holidayNotificationProvider.notifier).setEnabled(
                      value,
                      holidays: holidays,
                      languageCode: l10n.languageCode,
                    );
              },
            );
          },
        ),

        Consumer(
          builder: (context, ref, _) {
            final quotePrefs = ref.watch(quoteNotificationPrefsProvider);
            final effectiveValue = quotePrefs.enabled && osGranted;
            return _SettingsSwitchTile(
              icon: Icons.format_quote_outlined,
              title: l10n.quoteNotifications,
              subtitle: l10n.quoteNotificationsSubtitle,
              value: effectiveValue,
              onChanged: (value) async {
                if (value && !osGranted) {
                  _showPermissionDialog(context, ref, l10n);
                  return;
                }
                await ref
                    .read(quoteNotificationPrefsProvider.notifier)
                    .setEnabled(value, languageCode: l10n.languageCode);
              },
            );
          },
        ),

        Consumer(
          builder: (context, ref, _) {
            final wordPrefs = ref.watch(wordNotificationPrefsProvider);
            final effectiveValue = wordPrefs.enabled && osGranted;
            return _SettingsSwitchTile(
              icon: Icons.menu_book_outlined,
              title: l10n.wordNotifications,
              subtitle: l10n.wordNotificationsSubtitle,
              value: effectiveValue,
              onChanged: (value) async {
                if (value && !osGranted) {
                  _showPermissionDialog(context, ref, l10n);
                  return;
                }
                await ref
                    .read(wordNotificationPrefsProvider.notifier)
                    .setEnabled(value, languageCode: l10n.languageCode);
              },
            );
          },
        ),

        const Divider(height: 32),

        // ── Data & Storage ────────────────────────────────────
        _SectionHeader(title: l10n.dataAndStorage),
        _SettingsTile(
          icon: Icons.restore_outlined,
          title: l10n.resetSettings,
          subtitle: l10n.resetSettingsSubtitle,
          titleColor: colorScheme.error,
          onTap: () => _showResetSettingsDialog(context, ref, viewModel, l10n),
        ),
        _SettingsTile(
          icon: Icons.delete_outline,
          title: l10n.deleteAllData,
          subtitle: l10n.deleteAllDataSubtitle,
          titleColor: colorScheme.error,
          onTap: () => _showClearDataDialog(context, ref, viewModel, l10n),
        ),

        const Divider(height: 32),

        // ── About ─────────────────────────────────────────────
        _SectionHeader(title: l10n.about),
        _SettingsTile(
          icon: Icons.info_outline,
          title: l10n.about,
          subtitle: l10n.appVersionSubtitle,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(RouteNames.about),
        ),

        const SizedBox(height: 16),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.languageCode == 'bn'
                  ? appVersion.displayBn
                  : appVersion.displayEn,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: _SettingsFonts.version,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void onRetry() {
    ref.read(settingsViewModelProvider.notifier).loadSettings();
  }

  String _getThemeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.lightMode;
      case ThemeMode.dark:
        return l10n.darkMode;
      case ThemeMode.system:
        return l10n.systemDefault;
    }
  }

  String _formatLastSyncLine(AppLocalizations l10n) {
    try {
      final box = Hive.box('settings');
      final keys = [
        'holidays_last_check',
        'quotes_last_check',
        'words_last_check',
      ];

      DateTime? latest;
      for (final key in keys) {
        final raw = box.get(key) as String?;
        if (raw == null) continue;
        final dt = DateTime.tryParse(raw);
        if (dt != null && (latest == null || dt.isAfter(latest))) {
          latest = dt;
        }
      }

      if (latest == null) {
        return '${l10n.lastSynced}${l10n.lastSyncedNever}';
      }

      final diff = DateTime.now().difference(latest);

      if (diff.inMinutes < 1) {
        return '${l10n.lastSynced}${l10n.lastSyncedJustNow}';
      }
      if (diff.inHours < 1) {
        return '${l10n.lastSynced}${l10n.lastSyncedMinutesAgo(diff.inMinutes)}';
      }
      if (diff.inDays < 1) {
        return '${l10n.lastSynced}${l10n.lastSyncedHoursAgo(diff.inHours)}';
      }
      if (diff.inDays == 1) {
        return '${l10n.lastSynced}${l10n.lastSyncedYesterday}';
      }
      return '${l10n.lastSynced}${l10n.lastSyncedDaysAgo(diff.inDays)}';
    } catch (_) {
      return l10n.lastSyncedUnknown;
    }
  }

  void _showPermissionDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.notificationPermissionTitle),
        content: Text(l10n.notificationPermissionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await openAppSettings();
            },
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final currentTheme = ref.read(themeModeProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            final label = mode == ThemeMode.light
                ? l10n.lightMode
                : mode == ThemeMode.dark
                    ? l10n.darkMode
                    : l10n.systemDefault;
            return RadioListTile<ThemeMode>(
              title: Text(label),
              value: mode,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  viewModel.changeTheme(value, ref);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    SettingsViewModel viewModel,
  ) {
    final currentLocale = ref.read(localeProvider);
    final currentLanguage = currentLocale.languageCode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(l10n.languageBangla),
              value: 'bn',
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  viewModel.changeLanguage(value, ref);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.languageEnglish),
              value: 'en',
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  viewModel.changeLanguage(value, ref);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(
    BuildContext context,
    WidgetRef ref,
    SettingsViewModel viewModel,
    AppLocalizations l10n,
  ) {
    showConfirmDialog(
      title: l10n.deleteAllData,
      message: l10n.deleteAllDataConfirmMessage,
      confirmText: l10n.delete,
      cancelText: l10n.cancel,
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed) viewModel.clearAllData(ref, l10n);
    });
  }

  void _showResetSettingsDialog(
    BuildContext context,
    WidgetRef ref,
    SettingsViewModel viewModel,
    AppLocalizations l10n,
  ) {
    showConfirmDialog(
      title: l10n.resetSettings,
      message: l10n.resetSettingsConfirmMessage,
      confirmText: l10n.reset,
      cancelText: l10n.cancel,
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed) viewModel.resetSettings(ref, l10n);
    });
  }
}

class _PermissionBanner extends StatelessWidget {
  final AppLocalizations l10n;
  const _PermissionBanner({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_off_rounded,
              color: cs.onErrorContainer, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.notificationPermissionDeniedBanner,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: _SettingsFonts.tileSubtitle,
                    color: cs.onErrorContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          fontSize: _SettingsFonts.sectionHeader,
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: _SettingsFonts.tileTitle,
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: _SettingsFonts.tileSubtitle,
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SwitchListTile(
      secondary: Icon(icon, color: colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: _SettingsFonts.tileTitle,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: _SettingsFonts.tileSubtitle,
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      value: value,
      onChanged: onChanged,
    );
  }
}
