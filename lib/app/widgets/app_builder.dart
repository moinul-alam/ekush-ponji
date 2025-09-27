// lib/app/widgets/app_builder.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ekush_ponji/app/config/app_config.dart';
import 'package:ekush_ponji/app/state/app_state_manager.dart';
import 'package:ekush_ponji/app/themes/app_themes.dart';
import 'package:ekush_ponji/app/router/app_router.dart';
import 'package:ekush_ponji/app/widgets/loading_screen.dart';
import 'package:ekush_ponji/app/widgets/error_screen.dart';
import 'package:ekush_ponji/app/widgets/hive_error_screen.dart';
import 'package:ekush_ponji/presentation/pages/home/home_screen.dart';

class AppBuilder extends StatelessWidget {
  final bool hiveInitialized;
  
  const AppBuilder({
    Key? key,
    required this.hiveInitialized,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _safeBuilder('AppBuilder', () {
      // Show Hive initialization error first
      if (!hiveInitialized) {
        return _buildMaterialApp(
          title: _safeGetAppName(),
          home: _safeWidget('HiveErrorScreen', () => const HiveErrorScreen()),
        );
      }

      return Consumer<AppStateManager>(
        builder: (context, appState, child) {
          return _safeBuilder('AppStateConsumer', () {
            final themeMode = appState.themeMode;
            final locale = appState.locale;
            final error = appState.error;

            // Show loading while initializing app state
            if (!appState.isInitialized) {
              return _buildMaterialApp(
                title: _safeGetAppName(),
                home: _safeWidget('LoadingScreen', () => const LoadingScreen()),
              );
            }

            // Show error if app state initialization failed
            if (error != null) {
              return _buildMaterialApp(
                title: _safeGetAppName(),
                home: _safeWidget('ErrorScreen', () => ErrorScreen(error: error)),
              );
            }

            // Main app
            return _buildMaterialApp(
              title: _safeGetAppName(),
              theme: _safeGetLightTheme(),
              darkTheme: _safeGetDarkTheme(),
              themeMode: themeMode,
              localizationsDelegates: _safeGetLocalizationDelegates(),
              supportedLocales: _safeGetSupportedLocales(),
              locale: locale,
              initialRoute: _safeGetInitialRoute(),
              onGenerateRoute: _safeGenerateRoute,
              home: _buildHomePage(),
            );
          });
        },
      );
    });
  }

  // Safe MaterialApp builder with all parameters
  Widget _buildMaterialApp({
    required String title,
    Widget? home,
    ThemeData? theme,
    ThemeData? darkTheme,
    ThemeMode? themeMode,
    List<LocalizationsDelegate<dynamic>>? localizationsDelegates,
    List<Locale>? supportedLocales,
    Locale? locale,
    String? initialRoute,
    RouteFactory? onGenerateRoute,
  }) {
    return _safeBuilder('MaterialApp', () {
      return MaterialApp(
        title: title,
        debugShowCheckedModeBanner: _safeGetDebugFlag(),
        home: home,
        theme: theme,
        darkTheme: darkTheme,
        themeMode: themeMode ?? ThemeMode.system,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales ?? _getDefaultLocales(),
        locale: locale,
        initialRoute: initialRoute,
        onGenerateRoute: onGenerateRoute,
      );
    });
  }

  // Safe getters for app configuration
  String _safeGetAppName() {
    try {
      return AppConfig.appName;
    } catch (e) {
      debugPrint('Error getting app name: $e');
      return 'Ekush Ponji';
    }
  }

  bool _safeGetDebugFlag() {
    try {
      return AppConfig.debugShowCheckedModeBanner;
    } catch (e) {
      debugPrint('Error getting debug flag: $e');
      return false;
    }
  }

  ThemeData _safeGetLightTheme() {
    try {
      return AppThemes.lightTheme;
    } catch (e) {
      debugPrint('Error getting light theme: $e');
      return _getFallbackLightTheme();
    }
  }

  ThemeData _safeGetDarkTheme() {
    try {
      return AppThemes.darkTheme;
    } catch (e) {
      debugPrint('Error getting dark theme: $e');
      return _getFallbackDarkTheme();
    }
  }

  List<LocalizationsDelegate<dynamic>>? _safeGetLocalizationDelegates() {
    try {
      return AppConfig.localizationsDelegates;
    } catch (e) {
      debugPrint('Error getting localization delegates: $e');
      return null;
    }
  }

  List<Locale> _safeGetSupportedLocales() {
    try {
      return AppConfig.supportedLocales;
    } catch (e) {
      debugPrint('Error getting supported locales: $e');
      return _getDefaultLocales();
    }
  }

  String? _safeGetInitialRoute() {
    try {
      return AppRoutes.home;
    } catch (e) {
      debugPrint('Error getting initial route: $e');
      return null; // Will use home instead
    }
  }

  // Fallback themes
  ThemeData _getFallbackLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E7D32),
        brightness: Brightness.light,
      ),
    );
  }

  ThemeData _getFallbackDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4CAF50),
        brightness: Brightness.dark,
      ),
    );
  }

  List<Locale> _getDefaultLocales() {
    return const [
      Locale('bn', 'BD'),
      Locale('en', 'US'),
    ];
  }

  // Safe route generation
  Route<dynamic>? _safeGenerateRoute(RouteSettings settings) {
    return _safeBuilder('RouteGeneration', () {
      try {
        // Try to use AppRouter
        final route = AppRouter.generateRoute(settings);
        if (route != null) {
          return route;
        }
      } catch (e) {
        debugPrint('Error using AppRouter: $e');
      }
      
      // Fallback route generation
      return _createFallbackRoute(settings);
    });
  }

  // Create fallback route if AppRouter fails
  Route<dynamic> _createFallbackRoute(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (context) => _buildHomePage(),
    );
  }

  // Safe home page builder - this is the key fix!
  Widget _buildHomePage() {
    return _safeWidget('HomeScreen', () {
      return const HomeScreen();
    });
  }

  // Generic safe widget builder
  Widget _safeWidget(String widgetName, Widget Function() builder) {
    try {
      return builder();
    } catch (e, stackTrace) {
      debugPrint('Error building $widgetName: $e');
      debugPrint('Stack trace: $stackTrace');
      return _buildWidgetError(widgetName, e.toString());
    }
  }

  // Generic safe builder for any component
  T _safeBuilder<T>(String componentName, T Function() builder) {
    try {
      return builder();
    } catch (e, stackTrace) {
      debugPrint('Error in $componentName: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // For Widget types, return error widget
      if (T == Widget) {
        return _buildComponentError(componentName, e.toString()) as T;
      }
      
      // For other types, rethrow the error
      rethrow;
    }
  }

  // Error widget for specific widgets
  Widget _buildWidgetError(String widgetName, String error) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$widgetName Error'),
        backgroundColor: Colors.red.shade100,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load $widgetName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Try to restart the app or navigate to a safe state
                  debugPrint('Attempting to recover from $widgetName error');
                },
                child: const Text('Retry'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  // Provide fallback functionality
                  debugPrint('Using fallback for $widgetName');
                },
                child: const Text('Continue Anyway'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Error widget for major components
  Widget _buildComponentError(String componentName, String error) {
    return MaterialApp(
      title: 'Ekush Ponji - Error',
      home: Scaffold(
        appBar: AppBar(
          title: Text('$componentName Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                Text(
                  'Critical Error in $componentName',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    debugPrint('Attempting app restart...');
                    // Here you could implement app restart logic
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Restart App'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'If this error persists, please contact support.',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}