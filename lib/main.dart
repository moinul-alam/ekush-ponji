import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'data/models/holiday.dart';
// import 'data/models/reminder.dart';
// import 'data/models/personality.dart';
// import 'data/models/quote.dart';
// import 'data/models/app_settings.dart';
// import 'core/services/notification_service.dart';
// import 'core/services/ad_service.dart';
// import 'core/services/purchase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(HolidayAdapter());
  // Hive.registerAdapter(ReminderAdapter());
  // Hive.registerAdapter(PersonalityAdapter());
  // Hive.registerAdapter(QuoteAdapter());
  // Hive.registerAdapter(AppSettingsAdapter());

  // Open Hive boxes
  await Hive.openBox<Holiday>('holidaysBox');
  // await Hive.openBox<Reminder>('remindersBox');
  // await Hive.openBox<Personality>('personalitiesBox');
  // await Hive.openBox<Quote>('quotesBox');
  // await Hive.openBox<AppSettings>('appSettingsBox');

  // Initialize services
  // await NotificationService().init();
  // await AdService().init();
  // await PurchaseService().init();
  
  runApp(const EkushPonjiApp());
}