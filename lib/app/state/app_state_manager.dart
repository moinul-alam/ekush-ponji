// lib/app/state/app_state_manager.dart
import 'package:flutter/material.dart';
import 'package:ekush_ponji/services/hive_service.dart';
import 'package:ekush_ponji/services/settings_service.dart';

class AppStateManager extends ChangeNotifier {
  final HiveService _hiveService;
  SettingsService? _settingsService;

  // App state
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('bn', 'BD');
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _isInitialized = false;
  String? _error;

  // Getters
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  AppStateManager({required HiveService hiveService}) : _hiveService = hiveService {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      debugPrint('Starting app initialization...');
      
      // Initialize Hive first (but don't fail if it doesn't work)
      try {
        if (!HiveService.isInitialized) {
          await _hiveService.initHive();
        }
        debugPrint('Hive initialization: ${HiveService.isInitialized ? 'SUCCESS' : 'FAILED'}');
      } catch (hiveError) {
        debugPrint('Hive initialization failed: $hiveError');
        // Continue with app initialization even if Hive fails
        // The app should still work with SharedPreferences
      }

      // Initialize settings service (this should work regardless of Hive status)
      _settingsService = SettingsService();
      
      // Load settings with proper error handling
      final settings = await _loadSettingsWithFallback();

      // Apply loaded settings
      _themeMode = settings.themeMode;
      _locale = settings.locale;
      _notificationsEnabled = settings.notificationsEnabled;
      _soundEnabled = settings.soundEnabled;
      _error = null;
      _isInitialized = true;

      notifyListeners();
      debugPrint('AppStateManager initialized successfully');
      debugPrint('Theme: $_themeMode, Locale: $_locale, Notifications: $_notificationsEnabled, Sound: $_soundEnabled');
      
    } catch (e, stackTrace) {
      _error = e.toString();
      _isInitialized = true;

      // Fallback defaults
      _themeMode = ThemeMode.system;
      _locale = const Locale('bn', 'BD');
      _notificationsEnabled = true;
      _soundEnabled = true;

      notifyListeners();
      debugPrint('Error initializing app: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Load settings with comprehensive fallback mechanism
  Future<AppSettings> _loadSettingsWithFallback() async {
    try {
      if (_settingsService == null) {
        debugPrint('SettingsService is null, creating default settings');
        return AppSettings();
      }
      
      final settings = await _settingsService!.loadSettings();
      debugPrint('Settings loaded from SettingsService');
      return settings;
      
    } catch (e, stackTrace) {
      debugPrint('Failed to load settings, using defaults: $e');
      debugPrint('Stack trace: $stackTrace');
      return AppSettings();
    }
  }

  // Theme management
  Future<void> updateTheme(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    
    final previous = _themeMode;
    _themeMode = themeMode;
    notifyListeners();

    try {
      if (_settingsService != null) {
        await _settingsService!.saveThemeMode(themeMode);
        debugPrint('Theme updated successfully: $themeMode');
      } else {
        throw Exception('SettingsService not initialized');
      }
    } catch (e) {
      // Revert on error
      _themeMode = previous;
      notifyListeners();
      debugPrint('Error saving theme: $e');
      _showTemporaryError('Failed to save theme preference');
    }
  }

  // Locale management
  Future<void> updateLocale(Locale locale) async {
    if (_locale == locale) return;
    
    final previous = _locale;
    _locale = locale;
    notifyListeners();

    try {
      if (_settingsService != null) {
        await _settingsService!.saveLocale(locale);
        debugPrint('Locale updated successfully: $locale');
      } else {
        throw Exception('SettingsService not initialized');
      }
    } catch (e) {
      // Revert on error
      _locale = previous;
      notifyListeners();
      debugPrint('Error saving locale: $e');
      _showTemporaryError('Failed to save language preference');
    }
  }

  // Notifications management
  Future<void> updateNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled == enabled) return;
    
    final previous = _notificationsEnabled;
    _notificationsEnabled = enabled;
    notifyListeners();

    try {
      if (_settingsService != null) {
        await _settingsService!.saveNotificationsEnabled(enabled);
        debugPrint('Notifications updated successfully: $enabled');
      } else {
        throw Exception('SettingsService not initialized');
      }
    } catch (e) {
      // Revert on error
      _notificationsEnabled = previous;
      notifyListeners();
      debugPrint('Error saving notifications setting: $e');
      _showTemporaryError('Failed to save notification preference');
    }
  }

  // Sound management
  Future<void> updateSoundEnabled(bool enabled) async {
    if (_soundEnabled == enabled) return;
    
    final previous = _soundEnabled;
    _soundEnabled = enabled;
    notifyListeners();

    try {
      if (_settingsService != null) {
        await _settingsService!.saveSoundEnabled(enabled);
        debugPrint('Sound updated successfully: $enabled');
      } else {
        throw Exception('SettingsService not initialized');
      }
    } catch (e) {
      // Revert on error
      _soundEnabled = previous;
      notifyListeners();
      debugPrint('Error saving sound setting: $e');
      _showTemporaryError('Failed to save sound preference');
    }
  }

  // Utility method to show temporary errors
  void _showTemporaryError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
    
    // Clear error after a short delay
    Future.delayed(const Duration(seconds: 3), () {
      if (_error == errorMessage) {
        _error = null;
        notifyListeners();
      }
    });
  }

  /// Retry initialization (useful for error recovery)
  Future<void> retryInitialization() async {
    debugPrint('Retrying app initialization...');
    _isInitialized = false;
    _error = null;
    
    // Clear settings service cache
    _settingsService?.clearCache();
    
    notifyListeners();
    await _initializeApp();
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    try {
      if (_settingsService != null) {
        await _settingsService!.resetToDefaults();
        
        // Update local state
        _themeMode = ThemeMode.system;
        _locale = const Locale('bn', 'BD');
        _notificationsEnabled = true;
        _soundEnabled = true;
        
        notifyListeners();
        debugPrint('Settings reset to defaults');
      }
    } catch (e) {
      debugPrint('Error resetting settings: $e');
      _showTemporaryError('Failed to reset settings');
    }
  }

  /// Get current settings as AppSettings object
  AppSettings get currentSettings => AppSettings(
    themeMode: _themeMode,
    locale: _locale,
    notificationsEnabled: _notificationsEnabled,
    soundEnabled: _soundEnabled,
  );
}