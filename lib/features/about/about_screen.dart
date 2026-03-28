// lib/features/about/about_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/services/app_version_service.dart';
import 'package:ekush_ponji/features/about/about_content.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isBn = l10n.languageCode == 'bn';
    final versionInfo = ref.watch(appVersionProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppHeader(pageTitle: l10n.about),
      body: ListView(
        children: [
          // ── Hero ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                // App logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/app_logo.png',
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

                // ── Version (from PackageInfo / pubspec at build time) ───
                Text(
                  isBn ? versionInfo.displayBn : versionInfo.displayEn,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 12),
                // Website link
                GestureDetector(
                  onTap: () => _launch(AboutContent.websiteUrl),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.language_rounded,
                          size: 15, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'ekushponji.ekushlabs.com',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
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
              fullPolicyUrl: AboutContent.privacyUrl,
              closeLabel: l10n.close,
              isBn: isBn,
              onLaunch: _launch,
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
              fullPolicyUrl: AboutContent.termsUrl,
              closeLabel: l10n.close,
              isBn: isBn,
              onLaunch: _launch,
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
    required String fullPolicyUrl,
    required String closeLabel,
    required bool isBn,
    required Future<void> Function(String) onLaunch,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final displayContent =
        content.replaceAll(RegExp(r'\nhttps?://\S+'), '').trim();

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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayContent,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.75,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => onLaunch(fullPolicyUrl),
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: Text(
                          isBn ? 'সম্পূর্ণ নীতি পড়ুন' : 'Read Full Policy',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
