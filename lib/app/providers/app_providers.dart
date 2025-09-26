// lib/app/providers/app_providers.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ekush_ponji/app/state/app_state_manager.dart';

class AppProviders {
  static List<ChangeNotifierProvider> get providers => [
    ChangeNotifierProvider(
      create: (context) => AppStateManager(),
    ),
    // Add more providers here as your app grows
    // ChangeNotifierProvider(create: (context) => UserManager()),
    // ChangeNotifierProvider(create: (context) => DataManager()),
  ];
}
