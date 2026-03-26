// lib/core/widgets/navigation/app_header.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  // ── Content ────────────────────────────────────────────────────────────────

  final String? pageTitle;
  final String? logoAsset;
  final String? titleAsset;

  // ── Logo styling ───────────────────────────────────────────────────────────

  final double? logoSize;
  final EdgeInsetsGeometry? logoPadding;

  // ── Title styling ──────────────────────────────────────────────────────────

  final double? titleFontSize;
  final Color? titleColor;
  final EdgeInsetsGeometry? titlePadding;

  /// Title image height (home screen only)
  final double? titleImageHeight;

  // ── AppBar ─────────────────────────────────────────────────────────────────

  final EdgeInsetsGeometry? margin;
  final VoidCallback? onDrawerTap;
  final VoidCallback? onSettingsTap;

  // ── Defaults ───────────────────────────────────────────────────────────────

  static const String _defaultLogoAsset = 'assets/images/app_logo.png';
  static const String _defaultTitleAsset = 'assets/images/app_title.png';

  static const double _defaultLogoSize = 32;
  static const double _defaultTitleImageHeight = 42;
  static const double _defaultFontSize = 26;

  const AppHeader({
    super.key,
    this.pageTitle,
    this.logoAsset,
    this.titleAsset,
    this.logoSize,
    this.logoPadding,
    this.titleFontSize,
    this.titleColor,
    this.titlePadding,
    this.titleImageHeight,
    this.margin,
    this.onDrawerTap,
    this.onSettingsTap,
  });

  // ── Static helper ──────────────────────────────────────────────────────────

  static Widget title(
    BuildContext context,
    String pageTitle, {
    String? logoAsset,
    double? logoSize,
    Color? titleColor,
    double? fontSize,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveLogoSize = logoSize ?? _defaultLogoSize;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          logoAsset ?? _defaultLogoAsset,
          width: effectiveLogoSize,
          height: effectiveLogoSize,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => Icon(
            Icons.calendar_month_rounded,
            size: effectiveLogoSize * 0.6,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          pageTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: titleColor ?? colorScheme.primary,
            fontSize: fontSize ?? _defaultFontSize,
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

    final canPop = context.canPop();
    final isPageScreen = pageTitle != null;

    final effectiveLogoSize = logoSize ?? _defaultLogoSize;
    final effectiveTitleHeight = titleImageHeight ?? _defaultTitleImageHeight;

    final appBar = AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      centerTitle: true,

      // ── Leading ───────────────────────────────────────
      leading: isPageScreen && canPop
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: colorScheme.onSurface),
              onPressed: () => context.pop(),
              tooltip: 'Back',
            )
          : isPageScreen
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: colorScheme.onSurface),
                  onPressed: () => context.go(RouteNames.home),
                  tooltip: 'Back',
                )
              : IconButton(
                  icon: Icon(Icons.menu_rounded, color: colorScheme.onSurface),
                  onPressed: onDrawerTap ??
                      () => Scaffold.maybeOf(context)?.openDrawer(),
                  tooltip: 'Menu',
                ),

      // ── Title ─────────────────────────────────────────
      title: Padding(
        padding: titlePadding ?? EdgeInsets.zero,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Padding(
              padding: logoPadding ?? EdgeInsets.zero,
              child: SizedBox(
                width: effectiveLogoSize,
                height: effectiveLogoSize,
                child: Center(
                  child: Image.asset(
                    logoAsset ?? _defaultLogoAsset,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.calendar_month_rounded,
                      size: effectiveLogoSize * 0.7,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Title
            if (!isPageScreen)
              SizedBox(
                height: effectiveTitleHeight,
                child: Center(
                  child: Image.asset(
                    titleAsset ?? _defaultTitleAsset,
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
                  color: titleColor ?? colorScheme.primary,
                  fontSize: titleFontSize ?? _defaultFontSize,
                ),
              ),
          ],
        ),
      ),

      // ── Actions ───────────────────────────────────────
      actions: !isPageScreen
          ? [
              IconButton(
                icon:
                    Icon(Icons.settings_outlined, color: colorScheme.onSurface),
                onPressed:
                    onSettingsTap ?? () => context.push(RouteNames.settings),
                tooltip: 'Settings',
              ),
            ]
          : null,
    );

    if (margin != null) {
      return Container(margin: margin, child: appBar);
    }

    return appBar;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
