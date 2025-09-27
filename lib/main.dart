// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ekush_ponji/app/app.dart';
import 'package:ekush_ponji/app/config/app_config.dart';
import 'package:ekush_ponji/services/hive_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Initialize Hive
    final hiveInitialized = await HiveService.initialize();
    
    // Run the app
    runApp(EkushPonjiApp(hiveInitialized: hiveInitialized));
    
  } catch (error, stackTrace) {
    AppConfig.logError('Initialization failed', error, stackTrace);
    
    // Run app with failed initialization
    runApp(const EkushPonjiApp(hiveInitialized: false));
  }
}