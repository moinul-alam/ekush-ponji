import 'package:flutter/material.dart';
import 'package:ekush_ponji/features/calendar/models/calendar_day.dart';
import 'package:ekush_ponji/features/calendar/widgets/calendar_day_cell.dart';

class CalendarGrid extends StatelessWidget {
  final List<CalendarDay> days;
  final Function(CalendarDay) onDayTap;

  const CalendarGrid({
    super.key,
    required this.days,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.82,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        return CalendarDayCell(
          day: day,
          onTap: () => onDayTap(day),
        );
      },
    );
  }
}