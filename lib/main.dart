import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/app/app.dart';
import 'package:ekush_ponji/app/config/app_initializer.dart';

void main() async {
  // Ensure Flutter binding is initialized for async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services (Hive, orientation, etc.)
  await AppInitializer.initialize();

  // Run the app with Riverpod support
  runApp(
    const ProviderScope(
      child: EkushPonjiApp(),
    ),
  );
}
