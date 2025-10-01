import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ekush_ponji/core/themes/app_theme.dart';

class AppInitializer {
  /// Initialize app services
  static Future<void> initialize() async {
    try {
      await _setDeviceOrientation();
      await _initializeHive();
      await _openHiveBoxes();
      debugPrint('✅ App initialization completed successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ App initialization failed: $e');
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
    debugPrint('✅ Device orientation set to portrait');
  }

  /// Initialize Hive local storage
  static Future<void> _initializeHive() async {
    await Hive.initFlutter();
    debugPrint('✅ Hive initialized successfully');
  }

  /// Open all required Hive boxes
  static Future<void> _openHiveBoxes() async {
    try {
      // Open settings box - CRITICAL: This must be opened before app starts
      await Hive.openBox('settings');
      debugPrint('✅ Settings box opened successfully');
      
      // Add other boxes here as needed in the future
      // await Hive.openBox('calendar');
      // await Hive.openBox('events');
      // etc.
    } catch (e) {
      debugPrint('❌ Failed to open Hive boxes: $e');
      rethrow;
    }
  }

  /// Update system UI based on current ThemeMode and platform brightness
  /// This is called from app.dart using ref.listen
  static void updateSystemUIFromTheme(BuildContext context, ThemeMode themeMode) {
    final platformBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platformBrightness == Brightness.dark);

    final colorScheme =
        isDarkMode ? AppTheme.darkTheme.colorScheme : AppTheme.lightTheme.colorScheme;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent for modern look
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: colorScheme.surface,
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    ));
  }

  /// Close all Hive boxes - Call this on app dispose if needed
  static Future<void> dispose() async {
    try {
      await Hive.close();
      debugPrint('✅ Hive boxes closed successfully');
    } catch (e) {
      debugPrint('❌ Failed to close Hive boxes: $e');
    }
  }
}