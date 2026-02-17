import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/calendar/data/calendar_repository.dart';
import 'package:ekush_ponji/features/calendar/data/local/calendar_local_datasource.dart';
import 'package:ekush_ponji/features/calendar/data/remote/calendar_remote_datasource.dart';
import 'package:ekush_ponji/core/services/sync_service.dart';

/// Provider for CalendarLocalDatasource
final calendarLocalDatasourceProvider = Provider<CalendarLocalDatasource>((ref) {
  return CalendarLocalDatasource();
});

/// Provider for CalendarRemoteDatasource
final calendarRemoteDatasourceProvider = Provider<CalendarRemoteDatasource>((ref) {
  return CalendarRemoteDatasource();
});

/// Provider for CalendarRepository
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository(
    localDatasource: ref.watch(calendarLocalDatasourceProvider),
    remoteDatasource: ref.watch(calendarRemoteDatasourceProvider),
  );
});

/// Provider for SyncService
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    localDatasource: ref.watch(calendarLocalDatasourceProvider),
    remoteDatasource: ref.watch(calendarRemoteDatasourceProvider),
  );
});