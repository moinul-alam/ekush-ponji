import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ekush_ponji/app/app.dart';
import 'package:ekush_ponji/data/models/holiday.dart';
import 'package:ekush_ponji/data/models/reminder.dart';
import 'package:ekush_ponji/constants/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(HolidayAdapter());
  Hive.registerAdapter(ReminderAdapter());
  
  try {
    await Hive.openBox<Holiday>(AppConstants.holidaysBoxName);
    await Hive.openBox<Reminder>(AppConstants.remindersBoxName);
    await Hive.openBox(AppConstants.settingsBoxName);
    
    debugPrint('All Hive boxes opened successfully');
  } catch (e) {
    debugPrint('Error opening Hive boxes: $e');
  }

  runApp(const EkushPonjiApp());
}