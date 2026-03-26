// lib/features/calendar/widgets/calendar_legend.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/calendar/providers/calendar_visibility_provider.dart';
import 'package:ekush_ponji/core/themes/app_theme_extensions.dart';

class CalendarLegend extends ConsumerWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibility = ref.watch(calendarVisibilityProvider);
    final notifier = ref.read(calendarVisibilityProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.languageCode == 'bn';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hijriExt = theme.extension<AppThemeExtension>();

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _DateToggleChip(
              label: visibility.showBengaliDate
                  ? (isBn ? 'বাংলা তারিখ লুকান' : 'Hide Bengali Date')
                  : (isBn ? 'বাংলা তারিখ দেখুন' : 'Show Bengali Date'),
              isActive: visibility.showBengaliDate,
              activeColor: colorScheme.primaryContainer,
              activeLabelColor: colorScheme.onPrimaryContainer,
              activeIconColor: colorScheme.primary,
              icon: Icons.wb_sunny_rounded,
              onTap: notifier.toggleBengaliDate,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _DateToggleChip(
              label: visibility.showHijriDate
                  ? (isBn ? 'হিজরি তারিখ লুকান' : 'Hide Hijri Date')
                  : (isBn ? 'হিজরি তারিখ দেখুন' : 'Show Hijri Date'),
              isActive: visibility.showHijriDate,
              activeColor:
                  hijriExt?.hijriContainer ?? colorScheme.tertiaryContainer,
              activeLabelColor:
                  hijriExt?.onHijriContainer ?? colorScheme.onTertiaryContainer,
              activeIconColor: hijriExt?.hijriColor ?? colorScheme.tertiary,
              icon: Icons.dark_mode_rounded,
              onTap: notifier.toggleHijriDate,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chip widget ──────────────────────────────────────────────────────────────

class _DateToggleChip extends StatefulWidget {
  const _DateToggleChip({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.activeLabelColor,
    required this.activeIconColor,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color activeColor;
  final Color activeLabelColor;
  final Color activeIconColor;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_DateToggleChip> createState() => _DateToggleChipState();
}

class _DateToggleChipState extends State<_DateToggleChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _pressController.forward();
    _pressController.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = widget.isActive;

    // Colors
    final bgColor = isActive
        ? widget.activeColor
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55);
    final labelColor =
        isActive ? widget.activeLabelColor : colorScheme.onSurfaceVariant;
    final iconColor = isActive
        ? widget.activeIconColor
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.55);
    final borderColor = isActive
        ? widget.activeColor.withValues(alpha: 0.0) // no border when active
        : colorScheme.outlineVariant.withValues(alpha: 0.5);

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: widget.activeColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with animated switcher
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: CurvedAnimation(
                    parent: anim,
                    curve: Curves.elasticOut,
                  ),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Icon(
                  isActive ? widget.icon : Icons.visibility_off_rounded,
                  key: ValueKey(isActive),
                  size: 15,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 6),
              // Label with fade+slide
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.15),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: anim,
                        curve: Curves.easeOut,
                      )),
                      child: child,
                    ),
                  ),
                  child: Text(
                    widget.label,
                    key: ValueKey(widget.label),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
