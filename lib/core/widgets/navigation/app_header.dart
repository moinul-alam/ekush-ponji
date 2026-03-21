// lib/core/widgets/navigation/app_header.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';

/// Unified app header used across all screens.
///
/// ── Usage patterns ──────────────────────────────────────────────────────────
///
/// 1. Home screen — default logo + app_title image, drawer + settings icon:
///      return const AppHeader();
///
/// 2. Named screen — default logo + text title, back button auto-shown:
///      return AppHeader(pageTitle: l10n.settingsTitle);
///
/// 3. Named screen with custom logo size and title color:
///      return AppHeader(
///        pageTitle: l10n.settingsTitle,
///        logoSize: 32,
///        titleColor: Colors.teal,
///        titleFontSize: 24,
///      );
///
/// 4. Home screen with custom logo asset and top padding:
///      return AppHeader(
///        logoAsset: 'assets/images/my_logo.png',
///        titlePadding: const EdgeInsets.only(top: 5),
///      );
///
/// 5. Screens with their own AppBar (use static helper for title: slot):
///      return AppBar(
///        title: AppHeader.title(context, l10n.allHolidays),
///        centerTitle: true,
///        actions: [...],
///      );
///
/// ────────────────────────────────────────────────────────────────────────────
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  // ── Content ────────────────────────────────────────────────────────────────

  /// Title text for non-home screens.
  /// When null, [titleAsset] image is shown instead (home behavior).
  final String? pageTitle;

  /// Custom logo asset path. Defaults to 'assets/images/header_logo.png'.
  final String? logoAsset;

  /// Custom title image asset path (home screen only, when [pageTitle] is null).
  /// Defaults to 'assets/images/app_title.png'.
  final String? titleAsset;

  // ── Logo styling ───────────────────────────────────────────────────────────

  /// Logo width & height in logical pixels. Defaults to 40.
  final double? logoSize;

  /// Padding around the logo widget. Defaults to none.
  final EdgeInsetsGeometry? logoPadding;

  // ── Title styling ──────────────────────────────────────────────────────────

  /// Title text font size. Defaults to 26.
  final double? titleFontSize;

  /// Title text color. Defaults to [ColorScheme.primary].
  final Color? titleColor;

  /// Padding inside the title row (wraps logo + title together).
  /// Defaults to none.
  final EdgeInsetsGeometry? titlePadding;

  // ── AppBar ─────────────────────────────────────────────────────────────────

  /// Margin around the entire AppBar. Defaults to none.
  final EdgeInsetsGeometry? margin;

  /// Callbacks for leading/action buttons (optional overrides).
  final VoidCallback? onDrawerTap;
  final VoidCallback? onSettingsTap;

  // ── Defaults ───────────────────────────────────────────────────────────────
  static const String _defaultLogoAsset = 'assets/images/header_logo.png';
  static const String _defaultTitleAsset = 'assets/images/app_title.png';
  static const double _defaultLogoSize = 40;
  static const double _defaultFontSize = 26;

  const AppHeader({
    super.key,
    // content
    this.pageTitle,
    this.logoAsset,
    this.titleAsset,
    // logo styling
    this.logoSize,
    this.logoPadding,
    // title styling
    this.titleFontSize,
    this.titleColor,
    this.titlePadding,
    // appbar
    this.margin,
    this.onDrawerTap,
    this.onSettingsTap,
  });

  // ── Static helper ──────────────────────────────────────────────────────────
  /// Use this as the `title:` argument when a screen already builds its own
  /// AppBar (e.g. screens with actions or a bottom bar).
  ///
  /// Example:
  ///   AppBar(
  ///     title: AppHeader.title(context, l10n.allHolidays),
  ///     centerTitle: true,
  ///     actions: [...],
  ///   )
  ///
  /// Optional overrides:
  ///   AppHeader.title(
  ///     context, l10n.allHolidays,
  ///     logoAsset: 'assets/images/my_logo.png',
  ///     logoSize: 32,
  ///     titleColor: Colors.teal,
  ///     fontSize: 24,
  ///   )
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

    final appBar = AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      centerTitle: true,
      // Back button for named screens, drawer for home
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
      title: Padding(
        padding: titlePadding ?? EdgeInsets.zero,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Logo ──────────────────────────────────────
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

            // ── Title image (home) or text (named screen) ──
            if (!isPageScreen)
              SizedBox(
                height: effectiveLogoSize,
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
      // Settings icon only on home screen
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
