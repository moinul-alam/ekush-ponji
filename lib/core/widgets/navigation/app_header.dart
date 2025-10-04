import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';

/// App header with logo, drawer icon, and settings icon
/// Displays at the top of the home screen
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
        icon: Icon(
          Icons.menu_rounded,
          color: colorScheme.onSurface,
        ),
        onPressed: onDrawerTap ?? () => Scaffold.of(context).openDrawer(),
        tooltip: 'Menu',
      ),
      title: Center(
        child: Image.asset(
          'assets/images/app_title.png',
          height: 40,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if image doesn't exist
            return Text(
              'একুশ পঞ্জি',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            );
          },
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings_outlined,
            color: colorScheme.onSurface,
          ),
          onPressed: onSettingsTap ?? () => context.push(RouteNames.settings),
          tooltip: 'Settings',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
