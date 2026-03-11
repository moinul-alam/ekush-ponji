// lib/features/calendar/widgets/calendar_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/features/calendar/services/hijri_calendar_service.dart';
import 'package:ekush_ponji/features/calendar/models/calendar_day.dart';
import 'package:ekush_ponji/features/calendar/providers/calendar_visibility_provider.dart';
import 'package:ekush_ponji/features/calendar/widgets/calendar_day_cell.dart';

class CalendarGrid extends ConsumerWidget {
  final List<CalendarDay> days;
  final Function(CalendarDay) onDayTap;

  const CalendarGrid({
    super.key,
    required this.days,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hijriService = ref.watch(hijriCalendarServiceProvider);
    final visibility = ref.watch(calendarVisibilityProvider);

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
        final hijriDate = hijriService.getHijriDate(day.gregorianDate);
        return CalendarDayCell(
          day: day,
          hijriDate: hijriDate,
          showBengaliDate: visibility.showBengaliDate,
          showHijriDate: visibility.showHijriDate,
          onTap: () => onDayTap(day),
        );
      },
    );
  }
}
