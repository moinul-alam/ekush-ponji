import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ekush_ponji/app/router/app_router.dart';
import 'package:ekush_ponji/core/themes/app_theme.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';
import 'package:ekush_ponji/app/config/app_config.dart';
import 'package:ekush_ponji/app/config/app_initializer.dart';

class EkushPonjiApp extends ConsumerStatefulWidget {
  const EkushPonjiApp({super.key});

  @override
  ConsumerState<EkushPonjiApp> createState() => _EkushPonjiAppState();
}

class _EkushPonjiAppState extends ConsumerState<EkushPonjiApp> {
  bool _systemUIInitialized = false;

  @override
  Widget build(BuildContext context) {
    // Watch theme mode - returns ThemeMode enum directly
    final themeMode = ref.watch(themeModeProvider);

    // Listen to theme changes and update system UI
    ref.listen<ThemeMode>(themeModeProvider, (previous, next) {
      if (previous != next) {
        AppInitializer.updateSystemUIFromTheme(context, next);
      }
    });

    // Set initial system UI ONLY ONCE on first build
    if (!_systemUIInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AppInitializer.updateSystemUIFromTheme(context, themeMode);
          _systemUIInitialized = true;
        }
      });
    }

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      builder: (context, widget) {
        // Initialize ScreenUtil here, once per route
        ScreenUtil.init(
          context,
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
        );

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
          ),
          child: widget ?? const SizedBox.shrink(),
        );
      },
    );
  }
}