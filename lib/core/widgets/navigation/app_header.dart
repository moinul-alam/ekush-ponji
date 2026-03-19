// lib/core/widgets/navigation/app_header.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';

/// App header with logo+title centered, drawer icon left, settings icon right.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onDrawerTap;
  final VoidCallback? onSettingsTap;

  const AppHeader({
    super.key,
    this.onDrawerTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.menu_rounded, color: colorScheme.onSurface),
        onPressed: onDrawerTap ?? () => Scaffold.of(context).openDrawer(),
        tooltip: 'Menu',
      ),
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- Logo Container WITH TOP MARGIN ---
          Padding(
            padding: const EdgeInsets.only(
                top: 5.0), // Adds 4dp top margin only here
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Image.asset(
                  'assets/images/splash_logo.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.calendar_month_rounded,
                    size: 36,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          // ------------------------------------

          const SizedBox(width: 8),

          // Title Container (unchanged)
          SizedBox(
            height: 40,
            child: Center(
              child: Image.asset(
                'assets/images/app_title.png',
                fit: BoxFit.contain,
                alignment: Alignment.center,
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
