// 6. Loading Screen Widget
// lib/app/widgets/loading_screen.dart
import 'package:flutter/material.dart';
import 'package:ekush_ponji/app/config/app_config.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo or Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.calendar_today,
                size: 40,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            
            // App Name
            Text(
              AppConfig.appName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Loading Indicator
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            
            // Loading Text
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
