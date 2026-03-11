// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ekush_ponji/app/app.dart';
import 'package:ekush_ponji/app/config/app_initializer.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';

Future<void> main() async {
  // Lock splash open until we explicitly release it
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Phase 1 — Hive (settings box only) + orientation lock, concurrently.
  // Target: ~20-30ms total.
  await AppInitializer.initializeCore();

  // Providers can now read theme + locale from Hive on first frame
  final container = ProviderContainer();

  // First frame renders immediately — custom splash screen appears
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const EkushPonjiApp(),
    ),
  );

  // ✅ Native splash dismissed — custom Flutter splash is now visible.
  FlutterNativeSplash.remove();

  // Phase 2 — All heavy work runs behind the custom splash.
  // container is passed so DataSyncService singleton is reused,
  // not instantiated a second time.
  await AppInitializer.initializeBackground(container);

  // Custom splash navigates to home screen
  container.read(appReadyProvider.notifier).setReady();
}
