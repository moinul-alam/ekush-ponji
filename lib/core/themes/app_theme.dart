// lib/core/themes/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ekush_ponji/core/themes/color_schemes.dart';

class AppTheme {
  AppTheme._();

  // Font families
  static const String englishFont = 'Syne'; 
  static const String bengaliFont = 'Tiro Bangla';

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorSchemes.lightColorScheme,
      textTheme: _textTheme,
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
      textTheme: _textTheme,
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

  // Text Theme with Automatic Font Fallback
  // English text → Syne, Bengali text → Tiro Bangla (automatically)
  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: GoogleFonts.syne(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ).copyWith(
        fontFamilyFallback: [GoogleFonts.tiroBangla().fontFamily!],
      ),
      displayMedium: GoogleFonts.syne(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ).copyWith(
        fontFamilyFallback: [GoogleFonts.tiroBangla().fontFamily!],
      ),
      displaySmall: GoogleFonts.syne(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ).copyWith(
        fontFamilyFallback: [GoogleFonts.tiroBangla().fontFamily!],
      ),
      headlineLarge: GoogleFonts.syne(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ).copyWith(
        fontFamilyFallback: [GoogleFonts.tiroBangla().fontFamily!],
      ),
      headlineMedium: GoogleFonts.syne(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ).copyWith(
        fontFamilyFallback: [GoogleFonts.tiroBangla().fontFamily!],
      ),
      headlineSmall: GoogleFonts.syne(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ).copyWith(
        fontFamilyFallback: [GoogleFonts.tiroBangla().fontFamily!],
      ),
      titleLarge: GoogleFonts.syne(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ).copyWith(
        fontFamilyFallback: [GoogleFonts.tiroBangla().fontFamily!],
      ),
      titleMedium: GoogleFonts.syne(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ).copyWith(
        fontFamilyFallback: [GoogleFonts.tiroBangla().fontFamily!],
      ),
      titleSmall: GoogleFonts.syne(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ).copyWith(
        fontFamilyFallback: [GoogleFonts.tiroBangla().fontFamily!],
      ),
      bodyLarge: GoogleFonts.syne(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ).copyWith(
        fontFamilyFallback: [GoogleFonts.tiroBangla().fontFamily!],
      ),
      bodyMedium: GoogleFonts.syne(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ).copyWith(
        fontFamilyFallback: [GoogleFonts.tiroBangla().fontFamily!],
      ),
      bodySmall: GoogleFonts.syne(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ).copyWith(
        fontFamilyFallback: [GoogleFonts.tiroBangla().fontFamily!],
      ),
      labelLarge: GoogleFonts.syne(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ).copyWith(
        fontFamilyFallback: [GoogleFonts.tiroBangla().fontFamily!],
      ),
      labelMedium: GoogleFonts.syne(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ).copyWith(
        fontFamilyFallback: [GoogleFonts.tiroBangla().fontFamily!],
      ),
      labelSmall: GoogleFonts.syne(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ).copyWith(
        fontFamilyFallback: [GoogleFonts.tiroBangla().fontFamily!],
      ),
    );
  }

  // AppBar Theme - Light
  static AppBarTheme get _lightAppBarTheme {
    return const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
    );
  }

  // AppBar Theme - Dark
  static AppBarTheme get _darkAppBarTheme {
    return const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
    );
  }

  // Card Theme
  static CardThemeData get _cardTheme {
    return CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Elevated Button Theme
  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Outlined Button Theme
  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Text Button Theme
  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Input Decoration Theme
  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
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
  }

  // FAB Theme
  static FloatingActionButtonThemeData get _fabTheme {
    return FloatingActionButtonThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  // SnackBar Theme
  static SnackBarThemeData get _snackBarTheme {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // Dialog Theme
  static DialogThemeData get _dialogTheme {
    return DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  // Bottom Navigation Bar Theme - Light
  static BottomNavigationBarThemeData get _lightBottomNavTheme {
    return const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }

  // Bottom Navigation Bar Theme - Dark
  static BottomNavigationBarThemeData get _darkBottomNavTheme {
    return const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }

  // Navigation Bar Theme - Light
  static NavigationBarThemeData get _lightNavigationBarTheme {
    return NavigationBarThemeData(
      elevation: 2,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 80,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Navigation Bar Theme - Dark
  static NavigationBarThemeData get _darkNavigationBarTheme {
    return NavigationBarThemeData(
      elevation: 2,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 80,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}