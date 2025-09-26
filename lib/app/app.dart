import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ekush_ponji/app/config/app_config.dart';
import 'package:ekush_ponji/app/widgets/app_builder.dart';
import 'package:ekush_ponji/app/state/app_state_manager.dart';

/// Root of the Ekush Ponji App
class EkushPonjiApp extends StatelessWidget {
  const EkushPonjiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppStateManager>(
      create: (_) => AppStateManager(),
      child: const AppBuilder(), // AppBuilder handles all states internally
    );
  }
}