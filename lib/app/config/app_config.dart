class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  // App Information
  static const String appName = 'Ekush Ponji';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // API Configuration
  static const String apiBaseUrl = 'https://api.example.com'; // Replace with actual API
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;

  // Firebase Configuration (will be set in firebase_config.dart)
  static const bool useFirebaseEmulator = false;
  static const String firestoreEmulatorHost = 'localhost';
  static const int firestoreEmulatorPort = 8080;

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableRemoteConfig = false;

  // Environment
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
}