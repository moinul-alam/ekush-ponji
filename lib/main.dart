// lib/main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ekush_ponji/app/app.dart';
import 'package:ekush_ponji/app/config/app_initializer.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';

Future<void> main() async {
  // Catch ALL uncaught async + sync errors
  runZonedGuarded(() async {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    // Keep native splash until first Flutter frame is ready
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    // ─────────────────────────────────────────────
    // Phase 1 — Critical init (fast, blocking)
    // ─────────────────────────────────────────────
    try {
      await AppInitializer.initializeCore().timeout(const Duration(seconds: 3));
    } catch (e, st) {
      debugPrint('❌ Core initialization failed: $e');
      debugPrintStack(stackTrace: st);
      // App continues with safe defaults
    }

    // Pre-create provider container
    final container = ProviderContainer();

    // ─────────────────────────────────────────────
    // Run app ASAP → render Flutter splash
    // ─────────────────────────────────────────────
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const EkushPonjiApp(),
      ),
    );

    // Ensure first frame is rendered before removing native splash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    // ─────────────────────────────────────────────
    // Phase 2 — Background init (non-blocking UX)
    // ─────────────────────────────────────────────
    Future<void>(() async {
      try {
        await AppInitializer.initializeBackground(container)
            .timeout(const Duration(seconds: 6));
      } catch (e, st) {
        debugPrint('⚠️ Background initialization failed: $e');
        debugPrintStack(stackTrace: st);
        // Do NOT block user
      } finally {
        // Always release splash → never trap user
        container.read(appReadyProvider.notifier).setReady();
      }
    });
  }, (error, stack) {
    // Global crash handler
    debugPrint('🔥 Uncaught App Error: $error');
    debugPrintStack(stackTrace: stack);
  });
}
