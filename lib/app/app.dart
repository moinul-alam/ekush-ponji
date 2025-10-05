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
    // Watch theme mode - returns ThemeMode enum directly
    final themeMode = ref.watch(themeModeProvider);

    // Watch locale changes
    final locale = ref.watch(localeProvider);

    // Listen to theme changes and update system UI
    ref.listen<ThemeMode>(
      themeModeProvider,
      (previous, next) {
        if (previous != next && mounted) {
          AppInitializer.updateSystemUIFromTheme(context, next);
        }
      },
    );

    // Set initial system UI ONLY ONCE on first build
    if (!_systemUIInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AppInitializer.updateSystemUIFromTheme(context, themeMode);
          setState(() {
            _systemUIInitialized = true;
          });
        }
      });
    }

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Localization configuration
      locale: locale,
      supportedLocales: AppConstants.supportedLocales,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current locale is supported
        if (locale != null) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        // Return default locale if not supported
        return AppConstants.defaultLocale;
      },

      // Router configuration
      routerConfig: AppRouter.router,

      // Builder for ScreenUtil and responsive text
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
            textScaler: MediaQuery.textScalerOf(context).clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.2,
            ),
          ),
          child: widget ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
