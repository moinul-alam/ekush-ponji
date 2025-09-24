import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'themes.dart';
import 'constants.dart';
import '../presentation/pages/home/home_page.dart';

class EkushPonjiApp extends StatelessWidget {
  const EkushPonjiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme Configuration
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      
      // Localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppConstants.supportedLocales,
      locale: AppConstants.defaultLocale,
      
      // Routes
      initialRoute: AppConstants.homeRoute,
      routes: {
        AppConstants.homeRoute: (context) => const HomePage(),
        // TODO: Add more routes as we build features
        // AppConstants.settingsRoute: (context) => const SettingsPage(),
        // AppConstants.addReminderRoute: (context) => const AddReminderPage(),
        // AppConstants.premiumRoute: (context) => const PremiumPage(),
      },
      
      // Home Page (fallback)
      home: const HomePage(),
    );
  }
}