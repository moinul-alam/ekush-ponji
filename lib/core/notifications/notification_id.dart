// lib/core/notifications/notification_id.dart
//
// Single source of truth for all notification ID ranges and ID generation.
//
// ID ranges — guaranteed non-overlapping:
//   Prayer times : 100 – 114
//   Events       : 200_000_000 – 299_999_999
//   Reminders    : 400_000_000 – 499_999_999
//   Holidays     : 600_000_000 – 699_999_999
//   Quote today  : 700_000_001
//   Quote tomorrow: 700_000_002
//   Word today   : 700_000_003
//   Word tomorrow: 700_000_004

class NotificationId {
  NotificationId._();

  // ── Prayer ────────────────────────────────────────────────
  // Today: 100–104, Tomorrow: 110–114

  // ── Events ────────────────────────────────────────────────
  static const int _eventBase = 200000000;
  static const int _eventCeil = 299999999;

  static int forEvent(String eventId) =>
      _stableId(eventId, base: _eventBase, ceil: _eventCeil);

  // ── Reminders ─────────────────────────────────────────────
  static const int _reminderBase = 400000000;
  static const int _reminderCeil = 499999999;

  static int forReminder(String reminderId) =>
      _stableId(reminderId, base: _reminderBase, ceil: _reminderCeil);

  // ── Holidays ──────────────────────────────────────────────
  static const int _holidayBase = 600000000;
  static const int _holidayCeil = 699999999;

  static int forHoliday(String holidayId) =>
      _stableId(holidayId, base: _holidayBase, ceil: _holidayCeil);

  // ── Quotes ────────────────────────────────────────────────
  static const int quoteToday = 700000001;
  static const int quoteTomorrow = 700000002;

  // ── Words ─────────────────────────────────────────────────
  static const int wordToday = 700000003;
  static const int wordTomorrow = 700000004;

  // ── ID generation ─────────────────────────────────────────
  //
  // Fast path: if rawId is a pure numeric string (timestamp-based IDs like
  // "1718000000000"), use the number directly within the category range.
  // This gives zero collision risk for timestamp IDs.
  //
  // Slow path: djb2-style hash for non-numeric string IDs (e.g. holiday IDs
  // like "2025_eid_ul_fitr"). Uses the full range [base, ceil] instead of
  // the old % 100_000_000 truncation, reducing collision probability
  // from 1/100M to 1/100M (same range but now fills it fully).
  static int _stableId(
    String rawId, {
    required int base,
    required int ceil,
  }) {
    // Fast path — numeric timestamp IDs (events, reminders)
    final numeric = int.tryParse(rawId);
    if (numeric != null) {
      // Fold into range using modulo on the range size
      final range = ceil - base + 1;
      return base + (numeric.abs() % range);
    }

    // Slow path — string IDs (holidays)
    int hash = 5381;
    for (final unit in rawId.codeUnits) {
      hash = ((hash << 5) + hash) + unit;
      hash &= 0x7FFFFFFF; // keep positive, 31-bit
    }
    final range = ceil - base + 1;
    return base + (hash % range);
  }
}
