import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ekush_ponji/core/themes/color_schemes.dart';

class AppTheme {
  AppTheme._();

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

  // Text Theme (using Google Fonts)
  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge:
          GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.w400),
      displayMedium:
          GoogleFonts.poppins(fontSize: 45, fontWeight: FontWeight.w400),
      displaySmall:
          GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w400),
      headlineLarge:
          GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w600),
      headlineMedium:
          GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
      headlineSmall:
          GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge:
          GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500),
      titleMedium:
          GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      titleSmall:
          GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium:
          GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.roboto(fontSize: 11, fontWeight: FontWeight.w500),
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
