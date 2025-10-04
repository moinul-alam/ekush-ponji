import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

/// App Drawer with navigation menu
/// Provides consistent navigation across all screens
class AppDrawer extends StatelessWidget {
  final String? userName;

  const AppDrawer({
    super.key,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.primary,
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName ?? l10n.welcome,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  l10n.appName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),

          // Profile
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.profile),
            onTap: () {
              Navigator.pop(context);
              _showComingSoon(context, l10n.profile);
            },
          ),

          // Calendar
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: const Text('Calendar'),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.calendar);
            },
          ),

          // Calculator
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('Calculator'),
            onTap: () {
              Navigator.pop(context);
              _showComingSoon(context, 'Calculator');
            },
          ),

          const Divider(),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            onTap: () {
              Navigator.pop(context);
              _showComingSoon(context, l10n.about);
            },
          ),

          // Help & Support
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.helpSupport),
            onTap: () {
              Navigator.pop(context);
              _showComingSoon(context, l10n.helpSupport);
            },
          ),

          // Settings
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(l10n.settings),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.settings);
            },
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - ${AppLocalizations.of(context).comingSoon}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
