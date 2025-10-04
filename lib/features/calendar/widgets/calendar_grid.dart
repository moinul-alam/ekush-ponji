import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/calendar/models/calendar_day.dart';
import 'package:ekush_ponji/features/calendar/widgets/calendar_day_cell.dart';

/// Main calendar grid widget
/// Displays 42 cells (6 rows × 7 days) with swipe detection
/// Handles month navigation through swipe gestures
class CalendarGrid extends StatelessWidget {
  final List<CalendarDay> days;
  final Function(CalendarDay) onDayTap;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const CalendarGrid({
    super.key,
    required this.days,
    required this.onDayTap,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure we have exactly 42 days
    assert(days.length == 42,
        'Calendar grid must have exactly 42 days (6 rows × 7 days)');

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Detect swipe direction
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < 0) {
            // Swiped left -> next month
            onSwipeLeft();
          } else if (details.primaryVelocity! > 0) {
            // Swiped right -> previous month
            onSwipeRight();
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.8, // Slightly taller than wide
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final day = days[index];
            return CalendarDayCell(
              day: day,
              onTap: () => onDayTap(day),
            );
          },
        ),
      ),
    );
  }
}
