// lib/core/notifications/notification_permission_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_prefs.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_service.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_provider.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/quotes/services/quote_notification_prefs.dart';
import 'package:ekush_ponji/features/quotes/services/quote_notification_service.dart';
import 'package:ekush_ponji/features/quotes/providers/quote_notification_prefs_provider.dart';
import 'package:ekush_ponji/features/words/services/word_notification_prefs.dart';
import 'package:ekush_ponji/features/words/services/word_notification_service.dart';
import 'package:ekush_ponji/features/words/providers/word_notification_prefs_provider.dart';
import 'package:ekush_ponji/features/holidays/providers/holiday_notification_provider.dart';
import 'package:ekush_ponji/features/holidays/holidays_viewmodel.dart';

class NotificationPermissionDialog extends ConsumerWidget {
  const NotificationPermissionDialog({super.key});

  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final shouldAsk = await NotificationPermissionPrefs.shouldAsk();
    if (!shouldAsk) return;
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const NotificationPermissionDialog(),
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
        // ── Not Now ───────────────────────────────────────
        OutlinedButton(
          onPressed: () async {
            await NotificationPermissionPrefs.markAsked();
            await NotificationPermissionPrefs.markDenied();
            if (context.mounted) Navigator.of(context).pop();
          },
          child: Text(l10n.notNow),
        ),
        const SizedBox(width: 8),
        // ── Enable ────────────────────────────────────────
        FilledButton(
          onPressed: () async {
            await NotificationPermissionPrefs.markAsked();

            final languageCode = AppLocalizations.of(context).languageCode;
            final quoteNotifier =
                ref.read(quoteNotificationPrefsProvider.notifier);
            final wordNotifier =
                ref.read(wordNotificationPrefsProvider.notifier);
            final holidayNotifier =
                ref.read(holidayNotificationProvider.notifier);
            final holidays =
                ref.read(holidaysViewModelProvider.notifier).holidays;
            final permNotifier =
                ref.read(notificationPermissionProvider.notifier);

            Navigator.of(context).pop();

            final granted =
                await NotificationPermissionService.ensurePermission();

            debugPrint('🔔 Permission granted: $granted');

            if (granted) {
              await NotificationPermissionPrefs.markGranted();
              permNotifier.refresh();

              final quotePrefs = await QuoteNotificationPrefs.load();
              debugPrint('🔔 Quote prefs before: ${quotePrefs.enabled}');
              final enabledQuotePrefs = quotePrefs.copyWith(enabled: true);
              await enabledQuotePrefs.save();
              quoteNotifier.forceState(enabledQuotePrefs);
              debugPrint(
                  '🔔 Quote prefs after forceState: ${enabledQuotePrefs.enabled}');
              await QuoteNotificationService.scheduleUpcoming(
                prefs: enabledQuotePrefs,
                languageCode: languageCode,
              );

              final wordPrefs = await WordNotificationPrefs.load();
              debugPrint('🔔 Word prefs before: ${wordPrefs.enabled}');
              final enabledWordPrefs = wordPrefs.copyWith(enabled: true);
              await enabledWordPrefs.save();
              wordNotifier.forceState(enabledWordPrefs);
              debugPrint(
                  '🔔 Word prefs after forceState: ${enabledWordPrefs.enabled}');
              await WordNotificationService.scheduleUpcoming(
                prefs: enabledWordPrefs,
                languageCode: languageCode,
              );

              debugPrint('🔔 Holidays count: ${holidays.length}');
              await holidayNotifier.rescheduleIfEnabled(
                holidays: holidays,
                languageCode: languageCode,
              );
            } else {
              debugPrint('🔔 Permission denied');
              await NotificationPermissionPrefs.markDenied();
            }
          },
          child: Text(l10n.enable),
        ),
      ],
    );
  }
}
