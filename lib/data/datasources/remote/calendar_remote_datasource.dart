import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/home/models/holiday.dart';

/// Remote datasource for calendar data using Firebase Firestore
/// Fetches government holidays from Firebase
class CalendarRemoteDatasource {
  final FirebaseFirestore _firestore;

  CalendarRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection name
  static const String _holidaysCollection = 'holidays';

  // ------------------- Fetch Government Holidays -------------------

  /// Fetch government holidays for a specific year from Firebase
  Future<List<Holiday>> fetchGovtHolidays(int year) async {
    try {
      debugPrint('🔄 Fetching govt holidays for $year from Firebase...');

      // Document ID is the year (e.g., "2025", "2026")
      final docSnapshot = await _firestore
          .collection(_holidaysCollection)
          .doc(year.toString())
          .get();

      if (!docSnapshot.exists) {
        debugPrint('ℹ️ No holidays found in Firebase for $year');
        return [];
      }

      final data = docSnapshot.data();
      if (data == null || !data.containsKey('holidays')) {
        debugPrint('ℹ️ No holidays array found for $year');
        return [];
      }

      // Parse holidays array
      final holidaysArray = data['holidays'] as List<dynamic>;
      final holidays = holidaysArray
          .map((json) => Holiday.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      debugPrint('✅ Fetched ${holidays.length} govt holidays for $year from Firebase');
      return holidays;
    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase error fetching holidays: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Error fetching govt holidays: $e');
      rethrow;
    }
  }

  /// Fetch holidays for multiple years
  Future<Map<int, List<Holiday>>> fetchGovtHolidaysForYears(
      List<int> years) async {
    final Map<int, List<Holiday>> result = {};

    for (final year in years) {
      try {
        result[year] = await fetchGovtHolidays(year);
      } catch (e) {
        debugPrint('❌ Failed to fetch holidays for $year: $e');
        result[year] = []; // Empty list on error
      }
    }

    return result;
  }

  /// Check if holidays exist for a year (without fetching full data)
  Future<bool> hasHolidaysForYear(int year) async {
    try {
      final docSnapshot = await _firestore
          .collection(_holidaysCollection)
          .doc(year.toString())
          .get();

      return docSnapshot.exists;
    } catch (e) {
      debugPrint('❌ Error checking holidays existence: $e');
      return false;
    }
  }

  /// Get last updated timestamp for a year (if stored in Firebase)
  Future<DateTime?> getLastUpdatedTimestamp(int year) async {
    try {
      final docSnapshot = await _firestore
          .collection(_holidaysCollection)
          .doc(year.toString())
          .get();

      if (!docSnapshot.exists) return null;

      final data = docSnapshot.data();
      if (data == null || !data.containsKey('lastUpdated')) return null;

      final timestamp = data['lastUpdated'] as Timestamp;
      return timestamp.toDate();
    } catch (e) {
      debugPrint('❌ Error getting last updated timestamp: $e');
      return null;
    }
  }

  // ------------------- Admin Methods (Optional - for future admin panel) -------------------

  /// Upload holidays to Firebase (admin use)
  Future<void> uploadGovtHolidays(int year, List<Holiday> holidays) async {
    try {
      final holidaysJson = holidays.map((h) => h.toJson()).toList();

      await _firestore.collection(_holidaysCollection).doc(year.toString()).set({
        'holidays': holidaysJson,
        'lastUpdated': FieldValue.serverTimestamp(),
        'year': year,
        'count': holidays.length,
      });

      debugPrint('✅ Uploaded ${holidays.length} holidays for $year to Firebase');
    } catch (e) {
      debugPrint('❌ Error uploading holidays: $e');
      rethrow;
    }
  }

  /// Delete holidays for a year (admin use)
  Future<void> deleteGovtHolidays(int year) async {
    try {
      await _firestore
          .collection(_holidaysCollection)
          .doc(year.toString())
          .delete();

      debugPrint('✅ Deleted holidays for $year from Firebase');
    } catch (e) {
      debugPrint('❌ Error deleting holidays: $e');
      rethrow;
    }
  }
}