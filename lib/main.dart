// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:ekush_ponji/app/app.dart';
import 'package:ekush_ponji/app/config/app_initializer.dart';
import 'package:ekush_ponji/core/services/background_task_dispatcher.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized for async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize workmanager with our background task dispatcher.
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false, // set true during development to see task notifications
  );

  // Initialize services and app state before running the app
  await AppInitializer.initialize();

  // Run the app with Riverpod's ProviderScope for state management
  runApp(
    const ProviderScope(
      child: EkushPonjiApp(),
    ),
  );
}