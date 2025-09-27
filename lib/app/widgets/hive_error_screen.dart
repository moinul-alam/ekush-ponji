// lib/app/widgets/hive_error_screen.dart
import 'package:flutter/material.dart';
import 'package:ekush_ponji/services/hive_service.dart';
import 'package:ekush_ponji/app/app.dart';

class HiveErrorScreen extends StatefulWidget {
  const HiveErrorScreen({Key? key}) : super(key: key);

  @override
  State<HiveErrorScreen> createState() => _HiveErrorScreenState();
}

class _HiveErrorScreenState extends State<HiveErrorScreen> {
  bool _isRetrying = false;

  Future<void> _retryInitialization() async {
    setState(() => _isRetrying = true);
    
    final success = await HiveService.retryInitialization();
    
    setState(() => _isRetrying = false);
    
    if (success && mounted) {
      // Restart the app with successful initialization
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const EkushPonjiApp(hiveInitialized: true),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.storage,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Database Initialization Failed',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                HiveService.initError ?? 'Unknown error occurred',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _isRetrying
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _retryInitialization,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
