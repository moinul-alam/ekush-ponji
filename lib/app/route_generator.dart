import 'package:flutter/material.dart';
import 'package:ekush_ponji/presentation/pages/home/home_screen.dart';
import 'package:ekush_ponji/constants/route_constants.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            onThemeChanged: (theme) {},
            onLocaleChanged: (locale) {},
          ),
        );

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Page not found")),
      ),
    );
  }
}
