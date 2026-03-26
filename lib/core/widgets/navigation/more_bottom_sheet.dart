// lib/core/widgets/navigation/more_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

void showMoreBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _MoreBottomSheet(),
  );
}

class _MoreBottomSheet extends StatelessWidget {
  const _MoreBottomSheet();

  void _navigate(BuildContext context, String route, {Object? extra}) {
    Navigator.of(context, rootNavigator: true).pop();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = GoRouter.of(context);

      // Event/reminder add screens benefit from being pushed so back
      // returns somewhere sensible; all others replace the stack cleanly
      const pushRoutes = {
        RouteNames.calendarAddEvent,
        RouteNames.calendarAddReminder,
      };

      if (pushRoutes.contains(route)) {
        router.push(route, extra: extra);
      } else {
        router.go(route, extra: extra);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag handle ─────────────────────────────
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Grid of items ────────────────────────────
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.1,
                children: [
                  _MoreItem(
                    icon: Icons.event_outlined,
                    label: l10n.navAddEvent,
                    onTap: () => _navigate(
                      context,
                      RouteNames.calendarAddEvent,
                      extra: DateTime.now(),
                    ),
                  ),
                  _MoreItem(
                    icon: Icons.alarm_outlined,
                    label: l10n.navAddReminder,
                    onTap: () => _navigate(
                      context,
                      RouteNames.calendarAddReminder,
                      extra: DateTime.now(),
                    ),
                  ),
                  _MoreItem(
                    icon: Icons.calculate_outlined,
                    label: l10n.navCalculatorFull,
                    onTap: () => _navigate(
                      context,
                      RouteNames.calculator,
                    ),
                  ),
                  _MoreItem(
                    icon: Icons.format_quote_outlined,
                    label: l10n.navSavedQuotes,
                    onTap: () => _navigate(
                      context,
                      RouteNames.savedQuotes,
                    ),
                  ),
                  _MoreItem(
                    icon: Icons.bookmark_outline,
                    label: l10n.navSavedWords,
                    onTap: () => _navigate(
                      context,
                      RouteNames.savedWords,
                    ),
                  ),
                  _MoreItem(
                    icon: Icons.settings_outlined,
                    label: l10n.navSettings,
                    onTap: () => _navigate(
                      context,
                      RouteNames.settings,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Single item tile ─────────────────────────────────────────
class _MoreItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MoreItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
