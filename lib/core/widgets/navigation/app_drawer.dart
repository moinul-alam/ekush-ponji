import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

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
                // Logo instead of avatar
                Image.asset(
                  'assets/images/app_title.png',
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      l10n.appName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Username (only if available)
                if (userName != null && userName!.isNotEmpty)
                  Text(
                    userName!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                // Welcome to [appName]
                Text(
                  l10n.formatNamed(l10n.welcomeToApp, {'appName': l10n.appName}),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),

          // Profile
          // ListTile(
          //   leading: const Icon(Icons.person_outline),
          //   title: Text(l10n.profile),
          //   onTap: () {
          //     Navigator.pop(context);
          //     _showComingSoon(context, l10n.profile);
          //   },
          // ),

          // Calendar
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: Text(l10n.navCalendar),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.calendar);
            },
          ),

          // Prayer Times
          ListTile(
            leading: const Icon(Icons.mosque_outlined),
            title: Text(l10n.navPrayerTimes),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.prayerTimes);
            },
          ),

          // Calculator
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: Text(l10n.navCalculator),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.calculator);
            },
          ),

          const Divider(),

          

          // // Help & Support
          // ListTile(
          //   leading: const Icon(Icons.help_outline),
          //   title: Text(l10n.helpSupport),
          //   onTap: () {
          //     Navigator.pop(context);
          //     _showComingSoon(context, l10n.helpSupport);
          //   },
          // ),

          // Settings
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(l10n.settings),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.settings);
            },
          ),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            onTap: () {
              Navigator.pop(context);
              _showComingSoon(context, l10n.about);
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