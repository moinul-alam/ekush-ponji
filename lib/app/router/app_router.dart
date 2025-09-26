// lib/app/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:ekush_ponji/presentation/pages/home/home_screen.dart';
import 'package:ekush_ponji/app/widgets/not_found_screen.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: settings,
        );
        
      // Add more routes here as your app grows
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(), // Will navigate to settings tab
          settings: settings,
        );
        
      default:
        return MaterialPageRoute(
          builder: (context) => const NotFoundScreen(),
          settings: settings,
        );
    }
  }
}

class AppRoutes {
  static const String home = '/';
  static const String settings = '/settings';
  static const String calendar = '/calendar';
  static const String reminders = '/reminders';
  
  // Add more routes as needed
}