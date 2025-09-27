// lib/services/hive_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekush_ponji/data/models/holiday.dart';
import 'package:ekush_ponji/data/models/reminder.dart';
import 'package:ekush_ponji/constants/constants.dart';

class HiveService {
  static bool _isInitialized = false;
  static String? _initError;
  static final Map<String, Box> _openBoxes = {};

  static bool get isInitialized => _isInitialized;
  static String? get initError => _initError;

  /// Initialize Hive and open all required boxes
  static Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      debugPrint('Initializing Hive...');
      
      // Initialize Hive
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(HolidayAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ReminderAdapter());
      }
      
      // Open boxes with timeout for better UX
      final List<Box> boxes = await Future.wait([
        _openBoxSafely<Holiday>(AppConstants.holidaysBoxName),
        _openBoxSafely<Reminder>(AppConstants.remindersBoxName),
        _openBoxSafely<dynamic>(AppConstants.settingsBoxName),
      ]).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Hive initialization timed out', const Duration(seconds: 15)),
      );
      
      // Store references to opened boxes
      _openBoxes[AppConstants.holidaysBoxName] = boxes[0];
      _openBoxes[AppConstants.remindersBoxName] = boxes[1];
      _openBoxes[AppConstants.settingsBoxName] = boxes[2];
      
      _isInitialized = true;
      _initError = null;
      debugPrint('Hive initialized successfully');
      return true;
      
    } catch (e, stackTrace) {
      _initError = e.toString();
      _isInitialized = false;
      
      debugPrint('Hive initialization failed: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      
      return false;
    }
  }

  /// Helper method to open box safely
  static Future<Box<T>> _openBoxSafely<T>(String boxName) async {
    try {
      // Check if box is already open
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box<T>(boxName);
      }
      
      // Open the box
      return await Hive.openBox<T>(boxName);
    } catch (e) {
      debugPrint('Failed to open box $boxName: $e');
      rethrow;
    }
  }

  /// Retry initialization (useful for error recovery)
  static Future<bool> retryInitialization() async {
    await closeBoxes();
    _isInitialized = false;
    _initError = null;
    _openBoxes.clear();
    return await initialize();
  }

  /// Get a box safely with error handling
  static Box<T>? getBox<T>(String boxName) {
    try {
      if (!_isInitialized) {
        debugPrint('Hive not initialized, cannot get box: $boxName');
        return null;
      }
      
      // First check our cache
      if (_openBoxes.containsKey(boxName)) {
        return _openBoxes[boxName] as Box<T>?;
      }
      
      // Fallback to Hive.box if not in cache
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box<T>(boxName);
        _openBoxes[boxName] = box;
        return box;
      }
      
      debugPrint('Box $boxName is not open');
      return null;
    } catch (e) {
      debugPrint('Error getting box $boxName: $e');
      return null;
    }
  }

  /// Check if a specific box is available
  static bool isBoxAvailable(String boxName) {
    return _isInitialized && 
           (_openBoxes.containsKey(boxName) || Hive.isBoxOpen(boxName));
  }

  /// Close all boxes (call this in app disposal)
  static Future<void> closeBoxes() async {
    try {
      final List<Future<void>> closeFutures = [];
      
      for (final boxName in _openBoxes.keys.toList()) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            closeFutures.add(Hive.box(boxName).close());
          }
        } catch (e) {
          debugPrint('Error closing box $boxName: $e');
        }
      }
      
      if (closeFutures.isNotEmpty) {
        await Future.wait(closeFutures);
      }
      
      _openBoxes.clear();
      debugPrint('All Hive boxes closed');
    } catch (e) {
      debugPrint('Error closing Hive boxes: $e');
    }
  }

  // Instance method for compatibility with existing AppStateManager
  Future<void> initHive() async {
    // This method now just ensures static initialization is complete
    if (!_isInitialized) {
      final success = await HiveService.initialize();
      if (!success) {
        throw Exception('Failed to initialize Hive: $_initError');
      }
    }
  }
}