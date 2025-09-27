// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ekush_ponji/app/app.dart';
import 'package:ekush_ponji/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    debugPrint('Step 1: Setting orientations...');
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    debugPrint('Step 2: Initializing Hive...');
    // Initialize Hive
    final hiveInitialized = await HiveService.initialize();
    debugPrint('Hive initialized: $hiveInitialized');
    
    debugPrint('Step 3: Starting app...');
    runApp(EkushPonjiApp(hiveInitialized: hiveInitialized));
  } catch (e, stackTrace) {
    debugPrint('CRITICAL ERROR: $e');
    debugPrint('STACK TRACE: $stackTrace');
    
    // Run app with initialization failure flag
    runApp(const EkushPonjiApp(hiveInitialized: false));
  }
}