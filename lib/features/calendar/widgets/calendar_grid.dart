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
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.85,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: days.length,
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
