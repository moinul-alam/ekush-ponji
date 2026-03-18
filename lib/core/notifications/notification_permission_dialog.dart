// lib/core/notifications/notification_permission_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_prefs.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_service.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_provider.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

class NotificationPermissionDialog extends ConsumerWidget {
  const NotificationPermissionDialog({super.key});

  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final shouldAsk = await NotificationPermissionPrefs.shouldAsk();
    if (!shouldAsk) return;
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => NotificationPermissionDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      icon: Icon(
        Icons.notifications_outlined,
        size: 40,
        color: colorScheme.primary,
      ),
      title: Text(
        l10n.notificationPermissionTitle,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge,
      ),
      content: Text(
        l10n.notificationPermissionMessage,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        // Not Now
        OutlinedButton(
          onPressed: () async {
            await NotificationPermissionPrefs.markAsked();
            await NotificationPermissionPrefs.markDenied();
            if (context.mounted) Navigator.of(context).pop();
          },
          child: Text(l10n.notNow),
        ),
        const SizedBox(width: 8),
        // Enable
        FilledButton(
          onPressed: () async {
            await NotificationPermissionPrefs.markAsked();
            Navigator.of(context).pop();

            final granted =
                await NotificationPermissionService.ensurePermission();

            if (granted) {
              await NotificationPermissionPrefs.markGranted();
            } else {
              await NotificationPermissionPrefs.markDenied();
            }

            ref.read(notificationPermissionProvider.notifier).refresh();
          },
          child: Text(l10n.enable),
        ),
      ],
    );
  }
}
