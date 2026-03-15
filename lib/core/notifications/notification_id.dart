// lib/core/notifications/notification_id.dart
//
// Single source of truth for all notification ID ranges and ID generation.
//
// ID ranges — guaranteed non-overlapping:
//   Prayer times : 100 – 114              (fixed IDs, small range)
//   Events       : 200_000_000 – 299_999_999
//   Reminders    : 400_000_000 – 499_999_999
//   Holidays     : 600_000_000 – 699_999_999
//   Quote today  : 700_000_001             (single fixed ID, overwritten daily)
//   Quote tomorrow: 700_000_002            (single fixed ID, overwritten daily)
//   Word today   : 700_000_003             (single fixed ID, overwritten daily)
//   Word tomorrow: 700_000_004             (single fixed ID, overwritten daily)

class NotificationId {
  NotificationId._();

  // ── Prayer (fixed small IDs) ──────────────────────────────────────────────
  // Today: 100–104, Tomorrow: 110–114
  // Managed directly by PrayerNotificationService using Prayer enum map.

  // ── Events ────────────────────────────────────────────────────────────────
  static const int _eventBase = 200000000;

  static int forEvent(String eventId) => _stableId(eventId, base: _eventBase);

  // ── Reminders ─────────────────────────────────────────────────────────────
  static const int _reminderBase = 400000000;

  static int forReminder(String reminderId) =>
      _stableId(reminderId, base: _reminderBase);

  // ── Holidays ──────────────────────────────────────────────────────────────
  static const int _holidayBase = 600000000;

  static int forHoliday(String holidayId) =>
      _stableId(holidayId, base: _holidayBase);

  // ── Quotes ────────────────────────────────────────────────────────────────
  static const int quoteToday = 700000001;
  static const int quoteTomorrow = 700000002;

  // ── Words ─────────────────────────────────────────────────────────────────
  static const int wordToday = 700000003;
  static const int wordTomorrow = 700000004;

  // ── djb2-style hash ───────────────────────────────────────────────────────
  //
  // Produces a stable, non-negative 31-bit integer from any string.
  // Using (hash << 5) + hash + unit (djb2 variant) for good distribution.
  // The 0x7FFFFFFF mask keeps the value positive on all 64-bit Dart platforms,
  // avoiding the .abs() pitfall where int.minValue.abs() stays negative.
  //
  // Used by events, reminders, and holidays — all of which have string IDs
  // that must map to stable int notification IDs across app restarts.
  static int _stableId(String rawId, {required int base}) {
    int hash = 5381;
    for (final unit in rawId.codeUnits) {
      hash = ((hash << 5) + hash) + unit;
      hash &= 0x7FFFFFFF;
    }
    return (base + (hash % 100000000)).abs();
  }
}
