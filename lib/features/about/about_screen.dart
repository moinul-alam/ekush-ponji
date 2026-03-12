// lib/features/about/about_screen.dart

import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/about/about_content.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isBn = l10n.languageCode == 'bn';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.about),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // ── Hero ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                // App logo — falls back to icon if asset is missing
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/about.png',
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        size: 52,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isBn ? 'একুশ পঞ্জি' : 'Ekush Ponji',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  isBn ? 'সংস্করণ ১.০.০' : 'Version 1.0.0',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    AboutContent.appDescription(isBn),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // ── Legal ────────────────────────────────────────────────
          ListTile(
            leading:
                Icon(Icons.privacy_tip_outlined, color: colorScheme.primary),
            title: Text(l10n.privacyPolicy, style: theme.textTheme.bodyLarge),
            subtitle: Text(
              l10n.privacyPolicySubtitle,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLegalSheet(
              context: context,
              title: l10n.privacyPolicy,
              content: AboutContent.privacyPolicy(isBn),
              closeLabel: l10n.close,
            ),
          ),
          ListTile(
            leading: Icon(Icons.gavel_outlined, color: colorScheme.primary),
            title: Text(l10n.termsOfService, style: theme.textTheme.bodyLarge),
            subtitle: Text(
              l10n.termsOfServiceSubtitle,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLegalSheet(
              context: context,
              title: l10n.termsOfService,
              content: AboutContent.termsOfService(isBn),
              closeLabel: l10n.close,
            ),
          ),

          const SizedBox(height: 40),

        ],
      ),
    );
  }

  // ── Legal bottom sheet ──────────────────────────────────────────

  void _showLegalSheet({
    required BuildContext context,
    required String title,
    required String content,
    required String closeLabel,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title + close button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title, style: theme.textTheme.titleLarge),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Text(
                  content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.75,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}