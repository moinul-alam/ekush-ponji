import 'package:flutter/material.dart';

class AppColorSchemes {
  AppColorSchemes._();

  // Light Color Scheme - FIXED: Removed deprecated 'background' property
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF006B54),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF7FF9D4),
    onPrimaryContainer: Color(0xFF002117),
    secondary: Color(0xFF4A6359),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFCCE8DB),
    onSecondaryContainer: Color(0xFF062018),
    tertiary: Color(0xFF3D6373),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFC1E8FB),
    onTertiaryContainer: Color(0xFF001F29),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFFBFDF9), // Replaces 'background'
    onSurface: Color(0xFF191C1A), // Replaces 'onBackground'
    surfaceContainerHighest: Color(0xFFDBE5DF),
    onSurfaceVariant: Color(0xFF404943),
    outline: Color(0xFF707972),
    outlineVariant: Color(0xFFBFC9C3),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2E312F),
    onInverseSurface: Color(0xFFEFF1ED),
    inversePrimary: Color(0xFF5EDCB9),
    surfaceTint: Color(0xFF006B54),
  );

  // Dark Color Scheme - FIXED: Removed deprecated 'background' property
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF5EDCB9),
    onPrimary: Color(0xFF00382B),
    primaryContainer: Color(0xFF00513F),
    onPrimaryContainer: Color(0xFF7FF9D4),
    secondary: Color(0xFFB1CCBF),
    onSecondary: Color(0xFF1C352C),
    secondaryContainer: Color(0xFF334B42),
    onSecondaryContainer: Color(0xFFCCE8DB),
    tertiary: Color(0xFFA5CCDF),
    onTertiary: Color(0xFF073543),
    tertiaryContainer: Color(0xFF244C5A),
    onTertiaryContainer: Color(0xFFC1E8FB),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF191C1A), // Replaces 'background'
    onSurface: Color(0xFFE1E3DF), // Replaces 'onBackground'
    surfaceContainerHighest: Color(0xFF404943),
    onSurfaceVariant: Color(0xFFBFC9C3),
    outline: Color(0xFF89938D),
    outlineVariant: Color(0xFF404943),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE1E3DF),
    onInverseSurface: Color(0xFF191C1A),
    inversePrimary: Color(0xFF006B54),
    surfaceTint: Color(0xFF5EDCB9),
  );
}