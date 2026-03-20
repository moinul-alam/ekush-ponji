// lib/features/calendar/data/remote/calendar_remote_datasource.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';

/// Remote datasource for calendar data
/// Fetches government holidays from GitHub raw JSON
/// Sync logic (versioning, throttle, seeding) is handled by HolidaySyncService.
/// This datasource is a thin HTTP client — fetch only, no caching.
class CalendarRemoteDatasource {
  final Dio _dio;

  // ── GitHub raw base URL ───────────────────────────────
  static const String _baseUrl =
      'https://raw.githubusercontent.com/moinul-alam/ekush_ponji/main/assets/data';

  CalendarRemoteDatasource({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
            ));

  // ── Public API ────────────────────────────────────────

  /// Fetch government holidays for a specific year from GitHub.
  /// Returns empty list on any network or parse failure.
  Future<List<Holiday>> fetchGovtHolidays(int year) async {
    final url = '$_baseUrl/holidays/holidays_$year.json';
    try {
      debugPrint('🌐 Fetching holidays for $year from GitHub: $url');

      final response = await _dio.get<String>(url);

      if (response.statusCode != 200 || response.data == null) {
        debugPrint('⚠️ Unexpected response for $year: ${response.statusCode}');
        return [];
      }

      final holidays = _parseHolidayJson(response.data!);
      debugPrint('✅ Fetched ${holidays.length} holidays for $year');
      return holidays;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('ℹ️ No remote holiday file found for $year (404)');
        return [];
      }
      debugPrint('⚠️ Network error fetching holidays for $year: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching holidays for $year: $e');
      return [];
    }
  }

  /// Fetch holidays for multiple years.
  /// Failures per year are non-fatal — returns empty list for that year.
  Future<Map<int, List<Holiday>>> fetchGovtHolidaysForYears(
      List<int> years) async {
    final Map<int, List<Holiday>> result = {};
    for (final year in years) {
      result[year] = await fetchGovtHolidays(year);
    }
    return result;
  }

  /// Check if a holiday file exists for a year on GitHub (HEAD request).
  Future<bool> hasHolidaysForYear(int year) async {
    final url = '$_baseUrl/holidays_$year.json';
    try {
      final response = await _dio.head<void>(url);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Private helpers ───────────────────────────────────

  List<Holiday> _parseHolidayJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final list = data['holidays'] as List<dynamic>;
    return list
        .map((h) => Holiday.fromJson(h as Map<String, dynamic>))
        .toList();
  }
}
