import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ekush_ponji/constants/constants.dart';
import 'package:ekush_ponji/app/themes.dart';
import 'package:ekush_ponji/services/settings_service.dart';
import 'package:ekush_ponji/presentation/pages/home/home_screen.dart';


class EkushPonjiApp extends StatefulWidget {
  const EkushPonjiApp({Key? key}) : super(key: key);

  @override
  State<EkushPonjiApp> createState() => _EkushPonjiAppState();
}

class _EkushPonjiAppState extends State<EkushPonjiApp> {
  late SettingsService _settingsService;
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = AppConstants.defaultLocale;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    _settingsService = SettingsService();
    
    // Load saved settings
    final settings = await _settingsService.loadSettings();
    
    setState(() {
      _themeMode = settings.themeMode;
      _locale = settings.locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _themeMode,
      
      // Localization configuration
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppConstants.supportedLocales,
      locale: _locale,
      
      // Home screen
      home: HomeScreen(
        onThemeChanged: _updateTheme,
        onLocaleChanged: _updateLocale,
      ),
      
      // Navigation configuration
      onGenerateRoute: _generateRoute,
    );
  }

  void _updateTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    _settingsService.saveThemeMode(themeMode);
  }

  void _updateLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    _settingsService.saveLocale(locale);
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    // Add your route generation logic here
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (context) => HomeScreen(
            onThemeChanged: _updateTheme,
            onLocaleChanged: _updateLocale,
          ),
        );
      // Add more routes as needed
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(
              child: Text('404 - Page not found'),
            ),
          ),
        );
    }
  }
}