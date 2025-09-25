// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

// import 'themes.dart';
// import '../constants/constants.dart';
// import '../presentation/pages/home/home_screen.dart';
// import '../app/route_generator.dart';

// class EkushPonjiApp extends StatelessWidget {
//   const EkushPonjiApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: AppConstants.appName,
//       debugShowCheckedModeBanner: false,
      
//       // ====================
//       // Theme Configuration
//       // ====================
//       theme: AppThemes.lightTheme,
//       darkTheme: AppThemes.darkTheme,
//       themeMode: ThemeMode.system,
      
//       // ====================
//       // Localization
//       // ====================
//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: AppConstants.supportedLocales,
//       locale: AppConstants.defaultLocale,
      
//       // ====================
//       // Routing
//       // ====================

//       onGenerateRoute: RouteGenerator.generateRoute,
      
//       // ====================
//       // Home Page fallback
//       // ====================
//       home: const HomePage(), 
      
//       // ====================
//       // Future enhancements
//       // ====================
//       // navigatorObservers: [AnalyticsObserver()], // For analytics/logging
//       // builder: (context, child) {
//       //   // Wrap with providers or error handling
//       //   return MultiProvider(
//       //     providers: [
//       //       ChangeNotifierProvider(create: (_) => SomeProvider()),
//       //     ],
//       //     child: child!,
//       //   );
//       // },
//       // onUnknownRoute: (settings) => MaterialPageRoute(
//       //   builder: (_) => const UnknownPage(),
//       // ),
//     );
//   }
// }
