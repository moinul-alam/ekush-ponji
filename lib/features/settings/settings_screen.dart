import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/features/settings/settings_viewmodel.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/constants/app_constants.dart';

class SettingsScreen extends BaseScreen {
  const SettingsScreen({super.key});

  @override
  BaseScreenState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends BaseScreenState<SettingsScreen> {
  @override
  NotifierProvider<SettingsViewModel, ViewState> get viewModelProvider =>
      settingsViewModelProvider;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(l10n.settingsTitle),
      centerTitle: false,
      backgroundColor: colorScheme.surface,
      elevation: 0,
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewModel = ref.read(settingsViewModelProvider.notifier);

    // Watch current settings
    final currentTheme = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);
    final currentLanguage = currentLocale.languageCode;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Appearance Section
        _SectionHeader(title: 'Appearance'),

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

        // Notifications Section
        _SectionHeader(title: l10n.notifications),

        _SettingsSwitchTile(
          icon: Icons.notifications_outlined,
          title: l10n.notifications,
          subtitle: 'Receive important updates and reminders',
          value: viewModel.notificationsEnabled,
          onChanged: (value) => viewModel.toggleNotifications(value),
        ),

        _SettingsSwitchTile(
          icon: Icons.volume_up_outlined,
          title: 'Sound',
          subtitle: 'Play sound for notifications',
          value: viewModel.soundEnabled,
          onChanged: (value) => viewModel.toggleSound(value),
        ),

        _SettingsSwitchTile(
          icon: Icons.vibration_outlined,
          title: 'Vibration',
          subtitle: 'Vibrate for notifications',
          value: viewModel.vibrationEnabled,
          onChanged: (value) => viewModel.toggleVibration(value),
        ),

        const Divider(height: 32),

        // Data & Storage Section
        _SectionHeader(title: 'Data & Storage'),

        _SettingsSwitchTile(
          icon: Icons.backup_outlined,
          title: 'Auto Backup',
          subtitle: 'Automatically backup your data',
          value: viewModel.autoBackupEnabled,
          onChanged: (value) => viewModel.toggleAutoBackup(value),
        ),

        _SettingsTile(
          icon: Icons.delete_outline,
          title: 'Clear All Data',
          subtitle: 'Reset app to default settings',
          titleColor: colorScheme.error,
          onTap: () => _showClearDataDialog(context, viewModel, l10n),
        ),

        const Divider(height: 32),

        // About Section
        _SectionHeader(title: l10n.about),

        _SettingsTile(
          icon: Icons.info_outline,
          title: l10n.about,
          subtitle: 'App version and information',
          onTap: () => _showAboutDialog(context, l10n),
        ),

        _SettingsTile(
          icon: Icons.help_outline,
          title: l10n.helpSupport,
          subtitle: 'Get help and contact support',
          onTap: () => showInfo('${l10n.helpSupport} - ${l10n.comingSoon}'),
        ),

        _SettingsTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          onTap: () => showInfo('Privacy Policy - ${l10n.comingSoon}'),
        ),

        _SettingsTile(
          icon: Icons.gavel_outlined,
          title: 'Terms of Service',
          subtitle: 'Read our terms of service',
          onTap: () => showInfo('Terms of Service - ${l10n.comingSoon}'),
        ),

        const SizedBox(height: 16),

        // App Version
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Version 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
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
          children: [
            RadioListTile<ThemeMode>(
              title: Text(l10n.lightMode),
              value: ThemeMode.light,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  viewModel.changeTheme(value, ref);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.darkMode),
              value: ThemeMode.dark,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  viewModel.changeTheme(value, ref);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.systemDefault),
              value: ThemeMode.system,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  viewModel.changeTheme(value, ref);
                  Navigator.pop(context);
                }
              },
            ),
          ],
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
              title: const Text('বাংলা'),
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
              title: const Text('English'),
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
    SettingsViewModel viewModel,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will reset all settings to default and clear all stored data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              viewModel.clearAllData();
              Navigator.pop(context);
            },
            child: Text(
              l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.about),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.appName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'A comprehensive Bangla calendar app with date conversion, events, and more.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

// Custom Widgets
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
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
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
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
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
        style: theme.textTheme.bodyLarge,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      value: value,
      onChanged: onChanged,
    );
  }
}
