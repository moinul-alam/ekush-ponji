import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ekush_ponji/core/themes/color_schemes.dart';

class AppTheme {
  AppTheme._();

  // Public font name constants — may be referenced by other files
  static const String englishFont = 'Syne';
  static const String bengaliFont = 'Tiro Bangla';

  // Cache font family names once — avoids repeated object creation
  static final String _syneFamily = GoogleFonts.syne().fontFamily!;
  static final String _tiroBanglaFamily = GoogleFonts.tiroBangla().fontFamily!;
  static final List<String> _fontFallback = [_tiroBanglaFamily];

  // Cache the entire textTheme — same for light and dark, built exactly once
  static final TextTheme _cachedTextTheme = _buildTextTheme();

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorSchemes.lightColorScheme,
      textTheme: _cachedTextTheme,
      appBarTheme: _lightAppBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      floatingActionButtonTheme: _fabTheme,
      snackBarTheme: _snackBarTheme,
      dialogTheme: _dialogTheme,
      bottomNavigationBarTheme: _lightBottomNavTheme,
      navigationBarTheme: _lightNavigationBarTheme,
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorSchemes.darkColorScheme,
      textTheme: _cachedTextTheme,
      appBarTheme: _darkAppBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      floatingActionButtonTheme: _fabTheme,
      snackBarTheme: _snackBarTheme,
      dialogTheme: _dialogTheme,
      bottomNavigationBarTheme: _darkBottomNavTheme,
      navigationBarTheme: _darkNavigationBarTheme,
    );
  }

  // Builds a single TextStyle with Syne primary and Tiro Bangla fallback
  static TextStyle _s({
    required double fontSize,
    required FontWeight fontWeight,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: _syneFamily,
      fontFamilyFallback: _fontFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }

  // Text Theme — English text → Syne, Bengali text → Tiro Bangla (automatically)
  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge:  _s(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
      displayMedium: _s(fontSize: 45, fontWeight: FontWeight.w400),
      displaySmall:  _s(fontSize: 36, fontWeight: FontWeight.w400),
      headlineLarge:  _s(fontSize: 32, fontWeight: FontWeight.w600),
      headlineMedium: _s(fontSize: 28, fontWeight: FontWeight.w600),
      headlineSmall:  _s(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge:  _s(fontSize: 22, fontWeight: FontWeight.w500),
      titleMedium: _s(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
      titleSmall:  _s(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      bodyLarge:  _s(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
      bodyMedium: _s(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      bodySmall:  _s(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
      labelLarge:  _s(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      labelMedium: _s(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      labelSmall:  _s(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    );
  }

  // AppBar Theme - Light
  static const AppBarTheme _lightAppBarTheme = AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 1,
  );

  // AppBar Theme - Dark
  static const AppBarTheme _darkAppBarTheme = AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 1,
  );

  // Card Theme
  static CardThemeData get _cardTheme => CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );

  // Elevated Button Theme
  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  // Outlined Button Theme
  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  // Text Button Theme
  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

  // Input Decoration Theme
  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );

  // FAB Theme
  static FloatingActionButtonThemeData get _fabTheme =>
      FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );

  // SnackBar Theme
  static SnackBarThemeData get _snackBarTheme => SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );

  // Dialog Theme
  static DialogThemeData get _dialogTheme => DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );

  // Bottom Navigation Bar Theme - Light
  static const BottomNavigationBarThemeData _lightBottomNavTheme =
      BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      );

  // Bottom Navigation Bar Theme - Dark
  static const BottomNavigationBarThemeData _darkBottomNavTheme =
      BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      );

  // Navigation Bar Theme - Light
  static NavigationBarThemeData get _lightNavigationBarTheme =>
      NavigationBarThemeData(
        elevation: 2,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 80,
        indicatorShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  // Navigation Bar Theme - Dark
  static NavigationBarThemeData get _darkNavigationBarTheme =>
      NavigationBarThemeData(
        elevation: 2,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 80,
        indicatorShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
}