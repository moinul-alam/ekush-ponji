// lib/app/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ekush_ponji/app/router/app_router.dart';
import 'package:ekush_ponji/core/themes/app_theme.dart';
import 'package:ekush_ponji/app/providers/app_providers.dart';
import 'package:ekush_ponji/app/config/app_config.dart';
import 'package:ekush_ponji/app/config/app_initializer.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/constants/app_constants.dart';

class EkushPonjiApp extends ConsumerStatefulWidget {
  const EkushPonjiApp({super.key});

  @override
  ConsumerState<EkushPonjiApp> createState() => _EkushPonjiAppState();
}

class _EkushPonjiAppState extends ConsumerState<EkushPonjiApp> {
  bool _systemUIInitialized = false;

  @override
  void dispose() {
    _systemUIInitialized = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    // Update system UI on theme changes
    ref.listen<ThemeMode>(
      themeModeProvider,
      (previous, next) {
        if (previous != next && mounted) {
          AppInitializer.updateSystemUIFromTheme(context, next);
        }
      },
    );

    // Set system UI once on first build
    if (!_systemUIInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AppInitializer.updateSystemUIFromTheme(context, themeMode);
          setState(() => _systemUIInitialized = true);
        }
      });
    }

    // ScreenUtilInit wraps MaterialApp.router so it has access to real screen
    // dimensions before any widget builds. Since orientation is locked to
    // portrait, this effectively initializes once per app session.
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      // ensureScreenSize waits for the first frame so dimensions are accurate
      ensureScreenSize: true,
      builder: (context, child) => MaterialApp.router(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,

        // Localization
        locale: locale,
        supportedLocales: AppConstants.supportedLocales,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale != null) {
            for (final supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode) {
                return supported;
              }
            }
          }
          return AppConstants.defaultLocale;
        },

        // Router
        routerConfig: AppRouter.router,

        // Clamp system text scaling to prevent layout breaks on
        // devices with very large or very small accessibility font sizes
        builder: (context, widget) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.textScalerOf(context).clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.2,
            ),
          ),
          child: widget ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}