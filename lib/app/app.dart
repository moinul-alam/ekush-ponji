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
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppInitializer.updateSystemUIFromTheme(
      context,
      ref.read(themeModeProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    ref.listen<ThemeMode>(themeModeProvider, (previous, next) {
      if (previous != next && mounted) {
        AppInitializer.updateSystemUIFromTheme(context, next);
      }
    });

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: false,
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

        // Router — wrapped in RootScaffold for persistent banner + nav bar
        routerConfig: AppRouter.router,

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