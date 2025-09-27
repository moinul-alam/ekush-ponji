// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ekush_ponji/app/widgets/app_builder.dart';
import 'package:ekush_ponji/app/state/app_state_manager.dart';
import 'package:ekush_ponji/services/hive_service.dart';

class EkushPonjiApp extends StatefulWidget {
  final bool hiveInitialized;
  
  const EkushPonjiApp({
    Key? key,
    required this.hiveInitialized,
  }) : super(key: key);

  @override
  State<EkushPonjiApp> createState() => _EkushPonjiAppState();
}

class _EkushPonjiAppState extends State<EkushPonjiApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    HiveService.closeBoxes();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      HiveService.closeBoxes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppStateManager>(
      create: (_) => AppStateManager(hiveService: HiveService()),
      child: AppBuilder(hiveInitialized: widget.hiveInitialized),
    );
  }
}