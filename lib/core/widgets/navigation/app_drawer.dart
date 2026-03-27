// lib/core/widgets/navigation/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/quotes/quotes_viewmodel.dart';
import 'package:ekush_ponji/features/words/words_viewmodel.dart';

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
    final isBn = l10n.languageCode == 'bn';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Compact Header ────────────────────────────────
          Container(
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
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App logo — 3px top margin aligns it with app_title baseline
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.calendar_month_rounded,
                      size: 36,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // App title
                Image.asset(
                  'assets/images/app_title.png',
                  height: 44,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Text(
                    l10n.appName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

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
            leading: const Icon(Icons.flag_rounded),
            title: Text(l10n.allHolidays),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.holidays);
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

          // ── Events & Reminders ────────────────────────────
          _SectionLabel(
              label: isBn ? 'ইভেন্ট ও রিমাইন্ডার' : 'Events & Reminders'),
          ListTile(
            leading: const Icon(Icons.event_rounded),
            title: Text(isBn ? 'সব ইভেন্ট' : 'All Events'),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.eventsList);
            },
          ),
          ListTile(
            leading: const Icon(Icons.alarm_rounded),
            title: Text(isBn ? 'সব রিমাইন্ডার' : 'All Reminders'),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.reminders);
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
              final now = DateTime.now();
              final vm = ProviderScope.containerOf(context)
                  .read(quotesViewModelProvider.notifier);
              final index = vm.allQuotes.indexWhere(
                (q) => q.month == now.month && q.day == now.day,
              );
              context.push(RouteNames.quotes, extra: index < 0 ? 0 : index);
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
              final now = DateTime.now();
              final vm = ProviderScope.containerOf(context)
                  .read(wordsViewModelProvider.notifier);
              final index = vm.allWords.indexWhere(
                (w) => w.month == now.month && w.day == now.day,
              );
              context.push(RouteNames.words, extra: index < 0 ? 0 : index);
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
              context.push(RouteNames.about);
            },
          ),
        ],
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
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
