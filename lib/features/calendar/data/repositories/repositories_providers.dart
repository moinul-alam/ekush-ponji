// lib/features/calendar/data/repositories/repositories_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/calendar/data/local/calendar_local_datasource.dart';
import 'package:ekush_ponji/features/calendar/data/remote/calendar_remote_datasource.dart';

/// Provider for CalendarLocalDatasource
final calendarLocalDatasourceProvider =
    Provider<CalendarLocalDatasource>((ref) {
  return CalendarLocalDatasource();
});

/// Provider for CalendarRemoteDatasource
final calendarRemoteDatasourceProvider =
    Provider<CalendarRemoteDatasource>((ref) {
  return CalendarRemoteDatasource();
});