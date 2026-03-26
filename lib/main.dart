// lib/main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ekush_ponji/app/app.dart';
import 'package:ekush_ponji/app/config/app_initializer.dart';
import 'package:ekush_ponji/core/widgets/error/app_init_error_screen.dart';
import 'package:ekush_ponji/core/widgets/error/app_error_boundary.dart';

String? pendingNotificationPayload;

Future<void> main() async {
  runZonedGuarded(() async {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    // ── Set up Flutter error widget handler ───────────────
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return AppErrorWidget(details: details);
    };

    // ── Attempt core initialization ───────────────────────
    try {
      await AppInitializer.initializeCore();
    } catch (e, st) {
      // Remove splash before showing error screen
      FlutterNativeSplash.remove();

      debugPrint('🔥 Core initialization failed: $e');
      debugPrintStack(stackTrace: st);

      runApp(
        AppInitErrorScreen(
          error: e,
          stackTrace: st,
          onRetry: () => _retryInit(),
        ),
      );
      return;
    }

    pendingNotificationPayload = await AppInitializer.getColdStartPayload();

    final container = ProviderContainer();

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const EkushPonjiApp(),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    unawaited(_runBackgroundInit(container));
  }, (error, stack) {
    debugPrint('🔥 Uncaught App Error: $error');
    debugPrintStack(stackTrace: stack);
  });
}

/// Called by AppInitErrorScreen retry button.
/// Re-runs the full initialization sequence and relaunches the app.
Future<void> _retryInit() async {
  await AppInitializer.initializeCore();

  final payload = await AppInitializer.getColdStartPayload();
  pendingNotificationPayload = payload;

  final container = ProviderContainer();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const EkushPonjiApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });

  unawaited(_runBackgroundInit(container));
}

Future<void> _runBackgroundInit(ProviderContainer container) async {
  try {
    await AppInitializer.initializeBackground(container);
  } catch (e, st) {
    debugPrint('⚠️ Background initialization failed: $e');
    debugPrintStack(stackTrace: st);
  }
}
