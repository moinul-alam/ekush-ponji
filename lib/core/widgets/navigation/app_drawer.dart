// lib/core/widgets/navigation/app_drawer.dart

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
                if (userName != null && userName!.isNotEmpty)
                  Text(
                    userName!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                Text(
                  l10n.formatNamed(
                      l10n.welcomeToApp, {'appName': l10n.appName}),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),

          // ── Main Navigation ───────────────────────────────
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: Text(l10n.navCalendar),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.calendar);
            },
          ),
          ListTile(
            leading: const Icon(Icons.mosque_outlined),
            title: Text(l10n.navPrayerTimes),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.prayerTimes);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: Text(l10n.navCalculator),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.calculator);
            },
          ),

          const Divider(),

          // ── Quotes ────────────────────────────────────────
          _SectionLabel(label: l10n.quoteOfTheDay),
          ListTile(
            leading: const Icon(Icons.format_quote_rounded),
            title: Text(l10n.quoteOfTheDay),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.quotes);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_outline_rounded),
            title: Text(l10n.savedQuotes),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.savedQuotes);
            },
          ),

          const Divider(),

          // ── Words ─────────────────────────────────────────
          _SectionLabel(label: l10n.wordOfTheDay),
          ListTile(
            leading: const Icon(Icons.book_rounded),
            title: Text(l10n.wordOfTheDay),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.words);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_outline_rounded),
            title: Text(l10n.savedWords),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.savedWords);
            },
          ),

          const Divider(),

          // ── App ───────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(l10n.settings),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.settings);
            },
          ),
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
        content:
            Text('$feature - ${AppLocalizations.of(context).comingSoon}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}