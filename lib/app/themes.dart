import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppThemes {
  // Color constants
  static const Color primaryGreenLight = Color(0xFF1B5E20);
  static const Color primaryGreenDark = Color(0xFF4CAF50);
  static const Color accentRedLight = Color(0xFFE53935);
  static const Color accentRedDark = Color(0xFFEF5350);

  /// Call this once in `main.dart` to set system UI overlays consistently
  static void setSystemUI({bool isDark = false}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? const Color(0xFF121212) : Colors.white,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    setSystemUI(isDark: false);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreenLight,
        brightness: Brightness.light,
        primary: primaryGreenLight,
        secondary: accentRedLight,
        surface: Colors.white,
        background: const Color(0xFFF5F5F5),
      ),
      appBarTheme: _lightAppBarTheme,
      cardTheme: _lightCardTheme,
      floatingActionButtonTheme: _lightFabTheme,
      textTheme: _textTheme,
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    setSystemUI(isDark: true);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreenDark,
        brightness: Brightness.dark,
        primary: primaryGreenDark,
        secondary: accentRedDark,
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
      ),
      appBarTheme: _darkAppBarTheme,
      cardTheme: _darkCardTheme,
      floatingActionButtonTheme: _darkFabTheme,
      textTheme: _textTheme,
    );
  }

  // --- Component Styles ---

  // AppBars
  static const AppBarTheme _lightAppBarTheme = AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 1,
    backgroundColor: Colors.white,
    foregroundColor: primaryGreenLight,
    titleTextStyle: TextStyle(
      color: primaryGreenLight,
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
  );

  static const AppBarTheme _darkAppBarTheme = AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 1,
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: primaryGreenDark,
    titleTextStyle: TextStyle(
      color: primaryGreenDark,
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
  );

  // Cards
  static const CardThemeData _lightCardTheme = CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );

  static const CardThemeData _darkCardTheme = CardThemeData(
    elevation: 4,
    color: Color(0xFF2C2C2C),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );

  // FABs
  static const FloatingActionButtonThemeData _lightFabTheme =
      FloatingActionButtonThemeData(
    backgroundColor: primaryGreenLight,
    foregroundColor: Colors.white,
    elevation: 4,
  );

  static const FloatingActionButtonThemeData _darkFabTheme =
      FloatingActionButtonThemeData(
    backgroundColor: primaryGreenDark,
    foregroundColor: Colors.black,
    elevation: 4,
  );

  // Text (shared)
  static const TextTheme _textTheme = TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
  );
}
