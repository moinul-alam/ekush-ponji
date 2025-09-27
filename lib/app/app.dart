// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ekush_ponji/app/widgets/app_builder.dart';
import 'package:ekush_ponji/presentation/pages/splash/splash_screen.dart';
import 'package:ekush_ponji/app/state/app_state_manager.dart';
import 'package:ekush_ponji/services/hive_service.dart';

class EkushPonjiApp extends StatefulWidget {
  final bool hiveInitialized;
  
  const EkushPonjiApp({
    Key? key,
    required this.hiveInitialized,
  }) : super(key: key);

  @override
  State<EkushPonjiApp> createState() => _EkushPonjiAppState();
}

class _EkushPonjiAppState extends State<EkushPonjiApp> with WidgetsBindingObserver {
  bool _isAppReady = false;
  String _loadingMessage = 'Starting app...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAppState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    HiveService.closeBoxes();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      HiveService.closeBoxes();
    }
  }

  Future<void> _initializeAppState() async {
    try {
      // Show splash screen for minimum duration for better UX
      _updateLoadingMessage('Loading data...');
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Check if Hive initialization failed
      if (!widget.hiveInitialized) {
        _updateLoadingMessage('Database initialization failed');
        await Future.delayed(const Duration(milliseconds: 1000));
        
        setState(() {
          _hasError = true;
          _loadingMessage = 'Unable to load local database';
        });
        return;
      }
      
      _updateLoadingMessage('Finalizing...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mark app as ready
      setState(() {
        _isAppReady = true;
      });
      
    } catch (error, stackTrace) {
      debugPrint('App state initialization error: $error');
      debugPrint('Stack trace: $stackTrace');
      
      setState(() {
        _hasError = true;
        _loadingMessage = 'Failed to start app';
      });
    }
  }

  void _updateLoadingMessage(String message) {
    if (mounted) {
      setState(() {
        _loadingMessage = message;
      });
    }
  }

  void _retryInitialization() {
    setState(() {
      _hasError = false;
      _isAppReady = false;
      _loadingMessage = 'Retrying...';
    });
    _initializeAppState();
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen while app is initializing
    if (!_isAppReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(
          loadingMessage: _loadingMessage,
          hasError: _hasError,
          onRetry: _hasError ? _retryInitialization : null,
        ),
      );
    }

    // Show main app once ready
    return ChangeNotifierProvider<AppStateManager>(
      create: (_) => AppStateManager(hiveService: HiveService()),
      child: AppBuilder(hiveInitialized: widget.hiveInitialized),
    );
  }
}