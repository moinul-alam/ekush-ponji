import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:ekush_ponji/app/app.dart';
import 'package:ekush_ponji/app/config/app_initializer.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';
import 'package:ekush_ponji/core/services/background_task_dispatcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // WorkManager must be initialized before runApp — it registers
  // the callback dispatcher which needs to be available immediately
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  // Phase 1 — Hive only. Pure Dart, ~20ms, no black screen.
  await AppInitializer.initializeCore();

  final container = ProviderContainer();

  // runApp fires immediately after Hive is ready —
  // theme + locale load from Hive on first frame correctly
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const EkushPonjiApp(),
    ),
  );

  // Phase 2 — Firebase, notifications, sync run while splash is visible
  await AppInitializer.initializeBackground();

  // Signal splash to navigate now that everything is ready
  container.read(appReadyProvider.notifier).setReady();
}