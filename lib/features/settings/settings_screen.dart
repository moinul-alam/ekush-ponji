// lib/features/settings/settings_screen.dart

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
  bool get showLoadingOverlay => false;

  @override
  bool get autoHandleSuccess => true;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      title: Text(l10n.settingsTitle),
      centerTitle: false,
      backgroundColor: colorScheme.surface,
      elevation: 0,
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(settingsViewModelProvider);

    if (viewState is ViewStateLoading) {
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

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // ── Appearance ──────────────────────────────────────────────
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

        // ── Notifications ────────────────────────────────────────────
        // Sound and vibration are intentionally omitted — the OS handles them.
        _SectionHeader(title: l10n.notifications),
        _SettingsSwitchTile(
          icon: Icons.notifications_outlined,
          title: l10n.notifications,
          subtitle: l10n.notificationSubtitle,
          value: viewModel.notificationsEnabled,
          onChanged: (value) => viewModel.toggleNotifications(value),
        ),

        const Divider(height: 32),

        // ── Data & Storage ───────────────────────────────────────────
        _SectionHeader(title: l10n.dataAndStorage),
        _SettingsSwitchTile(
          icon: Icons.backup_outlined,
          title: l10n.autoBackup,
          subtitle: l10n.autoBackupSubtitle,
          // Always forced off; tapping shows "coming soon"
          value: false,
          onChanged: (_) => _showComingSoonSnackBar(context, l10n),
        ),
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
          onTap: () => _showClearDataDialog(context, viewModel, l10n),
        ),

        const Divider(height: 32),

        // ── About ────────────────────────────────────────────────────
        _SectionHeader(title: l10n.about),
        _SettingsTile(
          icon: Icons.info_outline,
          title: l10n.about,
          subtitle: l10n.appVersionSubtitle,
          onTap: () => _showAboutDialog(context, l10n),
        ),
        _SettingsTile(
          icon: Icons.privacy_tip_outlined,
          title: l10n.privacyPolicy,
          subtitle: l10n.privacyPolicySubtitle,
          onTap: () => _showPrivacyPolicyDialog(context, l10n),
        ),
        _SettingsTile(
          icon: Icons.gavel_outlined,
          title: l10n.termsOfService,
          subtitle: l10n.termsOfServiceSubtitle,
          onTap: () => _showTermsDialog(context, l10n),
        ),

        const SizedBox(height: 16),
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

  @override
  void onRetry() {
    ref.read(settingsViewModelProvider.notifier).loadSettings();
  }

  // ── Helpers ────────────────────────────────────────────────────────

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

  void _showComingSoonSnackBar(BuildContext context, AppLocalizations l10n) {
    final isBn = l10n.languageCode == 'bn';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBn
              ? 'এই ফিচারটি শীঘ্রই আসছে…'
              : l10n.featureComingSoon,
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────

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
      if (confirmed) viewModel.clearAllData();
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
      if (confirmed) viewModel.resetSettings(ref);
    });
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isBn = l10n.languageCode == 'bn';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.about),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 64,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                isBn ? 'একুশ পঞ্জি' : 'Ekush Ponji',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 1.0.0',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Text(
                isBn
                    ? 'একুশ পঞ্জি একটি বাংলা ক্যালেন্ডার অ্যাপ। বাংলা ও ইংরেজি তারিখ রূপান্তর, ছুটির তালিকা, ইভেন্ট ও রিমাইন্ডার — সব এক জায়গায়।\n\nডেভেলপ করেছেন বাংলাদেশের ব্যবহারকারীদের কথা মাথায় রেখে।'
                    : 'Ekush Ponji is a Bangla calendar app built for Bangladesh. Convert dates between Bangla and Gregorian calendars, browse holidays, and manage personal events and reminders — all in one place.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
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

  void _showPrivacyPolicyDialog(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isBn = l10n.languageCode == 'bn';

    final content = isBn
        ? '''একুশ পঞ্জি আপনার গোপনীয়তাকে সম্মান করে।

আমরা কী সংগ্রহ করি
আপনার ব্যক্তিগত পরিচয় সংক্রান্ত কোনো তথ্য সংগ্রহ করা হয় না। আপনার তৈরি ইভেন্ট, রিমাইন্ডার ও সেটিংস শুধুমাত্র আপনার ডিভাইসেই সংরক্ষিত থাকে।

অ্যানালিটিক্স
অ্যাপের উন্নতির জন্য বেনামী ব্যবহার পরিসংখ্যান সংগ্রহ করা হতে পারে। এতে কোনো ব্যক্তিগত তথ্য থাকে না।

তৃতীয় পক্ষ
আমরা কোনো তৃতীয় পক্ষের সাথে আপনার তথ্য বিক্রি বা ভাগ করি না।

যোগাযোগ
কোনো প্রশ্ন থাকলে আমাদের সাথে যোগাযোগ করুন।'''
        : '''Ekush Ponji respects your privacy.

What We Collect
We do not collect any personally identifiable information. Events, reminders, and settings you create are stored locally on your device only.

Analytics
Anonymous usage statistics may be collected to improve the app. No personal data is included.

Third Parties
We do not sell or share your data with any third parties.

Contact
If you have any questions, please reach out to us.''';

    _showScrollableDialog(
      context: context,
      title: l10n.privacyPolicy,
      content: content,
      closeLabel: l10n.close,
      theme: theme,
    );
  }

  void _showTermsDialog(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isBn = l10n.languageCode == 'bn';

    final content = isBn
        ? '''একুশ পঞ্জি ব্যবহার করে আপনি নিচের শর্তাবলি মেনে নিচ্ছেন।

ব্যবহারের অনুমতি
এই অ্যাপটি ব্যক্তিগত ও অ-বাণিজ্যিক উদ্দেশ্যে ব্যবহারের জন্য আপনাকে বিনামূল্যে লাইসেন্স প্রদান করা হয়।

দায়মুক্তি
অ্যাপটি "যেমন আছে" ভিত্তিতে সরবরাহ করা হয়। ক্যালেন্ডার বা প্রার্থনার সময়সূচির নির্ভুলতার কোনো গ্যারান্টি দেওয়া হয় না। গুরুত্বপূর্ণ বিষয়ে দাপ্তরিক সূত্র থেকে তথ্য যাচাই করুন।

পরিবর্তন
আমরা যেকোনো সময় এই শর্তাবলি পরিবর্তন করার অধিকার রাখি। পরিবর্তন কার্যকর হওয়ার পর অ্যাপ ব্যবহার অব্যাহত রাখলে আপনি নতুন শর্ত মেনে নিয়েছেন বলে ধরা হবে।

যোগাযোগ
কোনো প্রশ্ন থাকলে আমাদের সাথে যোগাযোগ করুন।'''
        : '''By using Ekush Ponji, you agree to the following terms.

License
You are granted a free, non-exclusive license to use this app for personal, non-commercial purposes.

Disclaimer
The app is provided "as is". We make no guarantees about the accuracy of calendar dates or prayer times. Please verify critical information from official sources.

Changes
We reserve the right to modify these terms at any time. Continued use of the app after changes constitutes your acceptance of the updated terms.

Contact
If you have any questions, please reach out to us.''';

    _showScrollableDialog(
      context: context,
      title: l10n.termsOfService,
      content: content,
      closeLabel: l10n.close,
      theme: theme,
    );
  }

  void _showScrollableDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String closeLabel,
    required ThemeData theme,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              content,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(closeLabel),
          ),
        ],
      ),
    );
  }
}

// ── Private widgets ──────────────────────────────────────────────────────────

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
        style: theme.textTheme.bodyLarge?.copyWith(color: titleColor),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
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
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            )
          : null,
      value: value,
      onChanged: onChanged,
    );
  }
}