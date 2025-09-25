import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modern theme configuration following Material 3 design principles
class AppThemes {
  // -------------------
  // Color Tokens (Material 3 approach)
  // -------------------
  static const _lightColorSeed = Color(0xFF1B5E20);
  static const _darkColorSeed = Color(0xFF4CAF50);
  
  // Custom semantic colors
  static const Color successLight = Color(0xFF1B5E20);
  static const Color successDark = Color(0xFF4CAF50);
  static const Color errorLight = Color(0xFFE53935);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color warningLight = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFFFB74D);

  // -------------------
  // System UI Configuration
  // -------------------
  static SystemUiOverlayStyle _getSystemUIStyle(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: colorScheme.surface,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    );
  }

  // -------------------
  // Light Theme
  // -------------------
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _lightColorSeed,
      brightness: Brightness.light,
    ).copyWith(
      // Override specific colors for brand consistency
      primary: _lightColorSeed,
      error: errorLight,
    );

    SystemChrome.setSystemUIOverlayStyle(_getSystemUIStyle(colorScheme));

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // Modern typography using Material 3 scale
      textTheme: _createTextTheme(colorScheme),
      
      // Component themes
      appBarTheme: _createAppBarTheme(colorScheme),
      cardTheme: _createCardTheme(colorScheme),
      filledButtonTheme: _createFilledButtonTheme(colorScheme),
      outlinedButtonTheme: _createOutlinedButtonTheme(colorScheme),
      floatingActionButtonTheme: _createFabTheme(colorScheme),
      bottomNavigationBarTheme: _createBottomNavTheme(colorScheme),
      navigationBarTheme: _createNavigationBarTheme(colorScheme),
      inputDecorationTheme: _createInputDecorationTheme(colorScheme),
      elevatedButtonTheme: _createElevatedButtonTheme(colorScheme),
      
      // Modern page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      
      // Splash and focus colors
      splashFactory: InkRipple.splashFactory,
    );
  }

  // -------------------
  // Dark Theme
  // -------------------
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _darkColorSeed,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _darkColorSeed,
      error: errorDark,
    );

    SystemChrome.setSystemUIOverlayStyle(_getSystemUIStyle(colorScheme));

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      textTheme: _createTextTheme(colorScheme),
      
      appBarTheme: _createAppBarTheme(colorScheme),
      cardTheme: _createCardTheme(colorScheme),
      filledButtonTheme: _createFilledButtonTheme(colorScheme),
      outlinedButtonTheme: _createOutlinedButtonTheme(colorScheme),
      floatingActionButtonTheme: _createFabTheme(colorScheme),
      bottomNavigationBarTheme: _createBottomNavTheme(colorScheme),
      navigationBarTheme: _createNavigationBarTheme(colorScheme),
      inputDecorationTheme: _createInputDecorationTheme(colorScheme),
      elevatedButtonTheme: _createElevatedButtonTheme(colorScheme),
      
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      
      splashFactory: InkRipple.splashFactory,
    );
  }

  // -------------------
  // Component Theme Builders
  // -------------------
  
  static TextTheme _createTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      // Display styles (largest text)
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: colorScheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      
      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      
      // Title styles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: colorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      ),
      
      // Body text
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: colorScheme.onSurfaceVariant,
      ),
      
      // Label text
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  static AppBarTheme _createAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      centerTitle: false, // Modern Material 3 default
      elevation: 0,
      scrolledUnderElevation: 3,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: colorScheme.surfaceTint,
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w400,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
    );
  }

  static CardThemeData _createCardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // More rounded for modern look
      ),
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: colorScheme.surfaceTint,
    );
  }

  static FilledButtonThemeData _createFilledButtonTheme(ColorScheme colorScheme) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _createOutlinedButtonTheme(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(color: colorScheme.outline),
      ),
    );
  }

  static ElevatedButtonThemeData _createElevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  static FloatingActionButtonThemeData _createFabTheme(ColorScheme colorScheme) {
    return FloatingActionButtonThemeData(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  static BottomNavigationBarThemeData _createBottomNavTheme(ColorScheme colorScheme) {
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: 3,
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
    );
  }

  static NavigationBarThemeData _createNavigationBarTheme(ColorScheme colorScheme) {
    return NavigationBarThemeData(
      elevation: 3,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      indicatorColor: colorScheme.secondaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          );
        }
        return TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        );
      }),
    );
  }

  static InputDecorationTheme _createInputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // -------------------
  // Utility Extensions
  // -------------------
  
  /// Get semantic colors for success, warning, etc.
  static ColorScheme getSemanticColors(ColorScheme baseScheme) {
    return baseScheme.copyWith(
      // You can add custom semantic colors here if needed
    );
  }
}

/// Extension to add semantic colors to ColorScheme
extension SemanticColors on ColorScheme {
  Color get success => brightness == Brightness.dark 
    ? AppThemes.successDark 
    : AppThemes.successLight;
    
  Color get warning => brightness == Brightness.dark 
    ? AppThemes.warningDark 
    : AppThemes.warningLight;
    
  Color get onSuccess => brightness == Brightness.dark 
    ? Colors.black 
    : Colors.white;
    
  Color get onWarning => brightness == Brightness.dark 
    ? Colors.black 
    : Colors.white;
}