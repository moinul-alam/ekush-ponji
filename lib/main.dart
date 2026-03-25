import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ekush_ponji/app/app.dart';
import 'package:ekush_ponji/app/config/app_initializer.dart';

String? pendingNotificationPayload;

Future<void> main() async {
  runZonedGuarded(() async {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    await AppInitializer.initializeCore();

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

Future<void> _runBackgroundInit(ProviderContainer container) async {
  try {
    await AppInitializer.initializeBackground(container);
  } catch (e, st) {
    debugPrint('⚠️ Background initialization failed: $e');
    debugPrintStack(stackTrace: st);
  }
}
