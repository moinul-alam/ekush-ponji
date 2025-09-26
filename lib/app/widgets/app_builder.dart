// lib/app/widgets/app_builder.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ekush_ponji/app/config/app_config.dart';
import 'package:ekush_ponji/app/state/app_state_manager.dart';
import 'package:ekush_ponji/app/themes/app_themes.dart';
import 'package:ekush_ponji/app/router/app_router.dart';
import 'package:ekush_ponji/app/widgets/loading_screen.dart';
import 'package:ekush_ponji/app/widgets/error_screen.dart';

class AppBuilder extends StatelessWidget {
  const AppBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateManager>(
      builder: (context, appState, child) {
        // Fallbacks to ensure non-null values
        final themeMode = appState.themeMode ?? ThemeMode.system;
        final locale = appState.locale;
        final error = appState.error;

        // Show loading while initializing
        if (!appState.isInitialized) {
          return MaterialApp(
            title: AppConfig.appName,
            home: const LoadingScreen(),
            debugShowCheckedModeBanner: AppConfig.debugShowCheckedModeBanner,
          );
        }

        // Show error if initialization failed
        if (error != null) {
          return MaterialApp(
            title: AppConfig.appName,
            home: ErrorScreen(error: error),
            debugShowCheckedModeBanner: AppConfig.debugShowCheckedModeBanner,
          );
        }

        // Main app
        return MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: AppConfig.debugShowCheckedModeBanner,

          // Theme
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeMode,

          // Localization
          localizationsDelegates: AppConfig.localizationsDelegates,
          supportedLocales: AppConfig.supportedLocales,
          locale: locale,

          // Navigation
          initialRoute: AppRoutes.home,
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}
