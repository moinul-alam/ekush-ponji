// lib/app/state/app_state_manager.dart (Updated version)
import 'package:flutter/material.dart';
import 'package:ekush_ponji/services/settings_service.dart';

class AppStateManager extends ChangeNotifier {
  late final SettingsService _settingsService;
  
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('bn', 'BD');
  bool _isInitialized = false;
  String? _error;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  AppStateManager() {
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    try {
      _settingsService = SettingsService();
      
      // Load saved settings
      final settings = await _settingsService.loadSettings();
      
      _themeMode = settings.themeMode;
      _locale = settings.locale;
      _isInitialized = true;
      _error = null;
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isInitialized = true;
      
      // Use default values
      _themeMode = ThemeMode.system;
      _locale = const Locale('bn', 'BD');
      
      notifyListeners();
      print('Error initializing app state: $e');
    }
  }

  Future<void> updateTheme(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    
    final previousTheme = _themeMode;
    _themeMode = themeMode;
    notifyListeners();
    
    try {
      await _settingsService.saveThemeMode(themeMode);
    } catch (e) {
      _themeMode = previousTheme;
      notifyListeners();
      print('Error saving theme: $e');
    }
  }

  Future<void> updateLocale(Locale locale) async {
    if (_locale == locale) return;
    
    final previousLocale = _locale;
    _locale = locale;
    notifyListeners();
    
    try {
      await _settingsService.saveLocale(locale);
    } catch (e) {
      _locale = previousLocale;
      notifyListeners();
      print('Error saving locale: $e');
    }
  }
}