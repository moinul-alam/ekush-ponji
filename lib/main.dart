// lib/main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ekush_ponji/app/app.dart';
import 'package:ekush_ponji/app/config/app_initializer.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';

/// Stores the notification payload from a cold-start tap.
/// Read once by SplashScreen, then cleared.
String? pendingNotificationPayload;

Future<void> main() async {
  runZonedGuarded(() async {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    // Keep native splash until first Flutter frame is ready
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    // ─────────────────────────────────────────────
    // Phase 1 — Absolute minimum before runApp
    // Only what ThemeModeNotifier / LocaleNotifier
    // need synchronously during their first build().
    // ─────────────────────────────────────────────
    try {
      await AppInitializer.initializeCore().timeout(const Duration(seconds: 3));
    } catch (e, st) {
      debugPrint('❌ Core initialization failed: $e');
      debugPrintStack(stackTrace: st);
    }

    // Read cold-start notification payload BEFORE runApp so SplashScreen
    // can route directly to the correct screen without any delay.
    pendingNotificationPayload = await AppInitializer.getColdStartPayload();

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

    // Remove native splash after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    // ─────────────────────────────────────────────
    // Phase 2 — Background init (non-blocking UX)
    // ─────────────────────────────────────────────
    Future<void>(() async {
      try {
        await AppInitializer.initializeBackground(container)
            .timeout(const Duration(seconds: 10));
      } catch (e, st) {
        debugPrint('⚠️ Background initialization failed: $e');
        debugPrintStack(stackTrace: st);
      } finally {
        container.read(appReadyProvider.notifier).setReady();
      }
    });
  }, (error, stack) {
    debugPrint('🔥 Uncaught App Error: $error');
    debugPrintStack(stackTrace: stack);
  });
}
