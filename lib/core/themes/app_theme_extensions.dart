import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color hijriColor;
  final Color hijriColorOnSpecial;
  final Color hijriContainer;
  final Color onHijriContainer;

  const AppThemeExtension({
    required this.hijriColor,
    required this.hijriColorOnSpecial,
    required this.hijriContainer,
    required this.onHijriContainer,
  });

  static const light = AppThemeExtension(
    hijriColor: Color(0xFFA06000),
    hijriColorOnSpecial: Color(0xFFFFE0A0),
    hijriContainer: Color(0xFFFFDEA0), // warm amber container
    onHijriContainer: Color(0xFF2B1800), // dark brown text on it
  );

  static const dark = AppThemeExtension(
    hijriColor: Color(0xFFFFB74D),
    hijriColorOnSpecial: Color(0xFFFFE0A0),
    hijriContainer: Color(0xFF5C3D00), // deep amber container
    onHijriContainer: Color(0xFFFFDEA0), // soft gold text on it
  );

  @override
  AppThemeExtension copyWith({
    Color? hijriColor,
    Color? hijriColorOnSpecial,
    Color? hijriContainer,
    Color? onHijriContainer,
  }) =>
      AppThemeExtension(
        hijriColor: hijriColor ?? this.hijriColor,
        hijriColorOnSpecial: hijriColorOnSpecial ?? this.hijriColorOnSpecial,
        hijriContainer: hijriContainer ?? this.hijriContainer,
        onHijriContainer: onHijriContainer ?? this.onHijriContainer,
      );

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other == null) return this;
    return AppThemeExtension(
      hijriColor: Color.lerp(hijriColor, other.hijriColor, t)!,
      hijriColorOnSpecial:
          Color.lerp(hijriColorOnSpecial, other.hijriColorOnSpecial, t)!,
      hijriContainer: Color.lerp(hijriContainer, other.hijriContainer, t)!,
      onHijriContainer:
          Color.lerp(onHijriContainer, other.onHijriContainer, t)!,
    );
  }
}
