// lib/core/widgets/navigation/app_header.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';

/// Unified app header used across all screens.
///
/// ── Usage patterns ──────────────────────────────────────────────────────────
///
/// 1. Home screen (logo + title image, drawer + settings):
///      return AppHeader();
///
/// 2. Simple screens (no extra actions/bottom — full AppBar replacement):
///      return AppHeader(pageTitle: l10n.someTitle);
///
/// 3. Complex screens (with actions, bottom bars, leading buttons — only
///    replace the title: argument of the existing AppBar):
///      title: AppHeader.title(context, l10n.someTitle),
///      centerTitle: true,
///
/// ────────────────────────────────────────────────────────────────────────────
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Title text for non-home screens.
  /// When null, the app title image asset is shown (home behavior).
  final String? pageTitle;

  final VoidCallback? onDrawerTap;
  final VoidCallback? onSettingsTap;

  const AppHeader({
    super.key,
    this.pageTitle,
    this.onDrawerTap,
    this.onSettingsTap,
  });

  // ── Static helper ──────────────────────────────────────────────────────────
  // Use this as the title: argument when you need logo + text but cannot
  // replace the whole AppBar (e.g. AppBar already has actions or a bottom).
  //
  // Example:
  //   return AppBar(
  //     title: AppHeader.title(context, l10n.allHolidays),
  //     centerTitle: true,
  //     actions: [...],
  //     bottom: ...,
  //   );
  static Widget title(BuildContext context, String pageTitle) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Image.asset(
            'assets/images/header_logo.png',
            width: 28,
            height: 28,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => Icon(
              Icons.calendar_month_rounded,
              size: 24,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          pageTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // ── Full AppBar ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.menu_rounded, color: colorScheme.onSurface),
        onPressed: onDrawerTap ?? () => Scaffold.of(context).openDrawer(),
        tooltip: 'Menu',
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo — same padding in both modes for visual consistency
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Image.asset(
                  'assets/images/header_logo.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.calendar_month_rounded,
                    size: 28,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Home: title image asset | Other screens: page title text
          if (pageTitle == null)
            SizedBox(
              height: 40,
              child: Center(
                child: Image.asset(
                  'assets/images/app_title.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, __, ___) => Text(
                    'একুশ পঞ্জি',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            )
          else
            Text(
              pageTitle!,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined, color: colorScheme.onSurface),
          onPressed: onSettingsTap ?? () => context.push(RouteNames.settings),
          tooltip: 'Settings',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
