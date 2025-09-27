import 'package:flutter/material.dart';
import 'package:ekush_ponji/app/config/app_config.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      home: const Scaffold(
        backgroundColor: Colors.white, // Or your brand color
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add your app logo here
              FlutterLogo(size: 100), // Replace with your logo
              SizedBox(height: 24),
              Text(
                'Ekush Ponji',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
      debugShowCheckedModeBanner: AppConfig.debugShowCheckedModeBanner,
    );
  }
}