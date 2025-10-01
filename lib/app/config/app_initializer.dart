import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ekush_ponji/core/themes/app_theme.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';

class AppInitializer {
  /// Initialize app services
  static Future<void> initialize() async {
    try {
      await _setDeviceOrientation();
      await _initializeHive();
      debugPrint('App initialization completed successfully');
    } catch (e, stackTrace) {
      debugPrint('App initialization failed: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Lock device orientation to portrait only
  static Future<void> _setDeviceOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Initialize Hive local storage
  static Future<void> _initializeHive() async {
    await Hive.initFlutter();
    debugPrint('✅ Hive initialized successfully');
  }

  /// Listen to theme changes and update system UI automatically
  static void setupSystemUIListener(WidgetRef ref) {
    ref.listen<ThemeMode>(themeModeProvider, (previous, next) {
      _updateSystemUI(ref, next);
    });
  }

  /// Update system UI based on current ThemeMode and platform brightness
  static void _updateSystemUI(WidgetRef ref, ThemeMode themeMode) {
    final platformBrightness = WidgetsBinding.instance.window.platformBrightness;
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platformBrightness == Brightness.dark);

    final colorScheme =
        isDarkMode ? AppTheme.darkTheme.colorScheme : AppTheme.lightTheme.colorScheme;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: colorScheme.background,
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    ));
  }
}
