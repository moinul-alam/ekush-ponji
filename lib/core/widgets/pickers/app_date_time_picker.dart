// lib/core/widgets/pickers/app_date_time_picker.dart
//
// Custom date+time picker shown as a bottom sheet with two tabs:
//   📅 Date — full-width month grid, same style as the app calendar
//   🕐 Time — full-width hour + minute CupertinoPicker wheels
//
// A summary bar at the top always shows the current selection.
// Tapping a day on the Date tab automatically switches to the Time tab.
//
// Usage:
//   final result = await AppDateTimePicker.show(
//     context: context,
//     initial: someDateTime,
//     l10n: AppLocalizations.of(context),
//   );
//   if (result != null) use(result);

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

class AppDateTimePicker {
  AppDateTimePicker._();

  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initial,
    required AppLocalizations l10n,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        initial: initial ?? DateTime.now(),
        l10n: l10n,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PickerSheet extends StatefulWidget {
  final DateTime initial;
  final AppLocalizations l10n;

  const _PickerSheet({required this.initial, required this.l10n});

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late int _year;
  late int _month;
  late int _day;
  late int _hour;
  late int _minute;

  // Month being viewed in the grid (may differ from selected month)
  late int _viewYear;
  late int _viewMonth;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final d = widget.initial;
    _year = d.year;
    _month = d.month;
    _day = d.day;
    _hour = d.hour;
    _minute = d.minute;
    _viewYear = d.year;
    _viewMonth = d.month;

    _hourController = FixedExtentScrollController(initialItem: _hour);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  void _prevMonth() => setState(() {
        if (_viewMonth == 1) {
          _viewMonth = 12;
          _viewYear--;
        } else {
          _viewMonth--;
        }
      });

  void _nextMonth() => setState(() {
        if (_viewMonth == 12) {
          _viewMonth = 1;
          _viewYear++;
        } else {
          _viewMonth++;
        }
      });

  void _selectDay(int day) {
    setState(() {
      _year = _viewYear;
      _month = _viewMonth;
      _day = day;
    });
    // Auto-advance to Time tab after picking a day
    _tabController.animateTo(1);
  }

  bool _isSelectedDay(int day) =>
      _viewYear == _year && _viewMonth == _month && _day == day;

  bool _isToday(int day) {
    final now = DateTime.now();
    return _viewYear == now.year && _viewMonth == now.month && day == now.day;
  }

  void _confirm() {
    Navigator.of(context).pop(
      DateTime(_year, _month, _day, _hour, _minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isBn = widget.l10n.languageCode == 'bn';

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // Use a fixed height so the sheet doesn't jump between tabs
      height: MediaQuery.of(context).size.height * 0.62,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          // ── Drag handle ──────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withOpacity(0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Summary bar ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Row(
              children: [
                Icon(Icons.event_rounded, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _buildSummary(isBn),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Tab bar ──────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: cs.onPrimary,
              unselectedLabelColor: cs.onSurfaceVariant,
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(isBn ? 'তারিখ' : 'Date'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(isBn ? 'সময়' : 'Time'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Tab views ────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── Date tab ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _DateGrid(
                    viewYear: _viewYear,
                    viewMonth: _viewMonth,
                    daysInMonth: _daysInMonth(_viewYear, _viewMonth),
                    isSelectedDay: _isSelectedDay,
                    isToday: _isToday,
                    onSelectDay: _selectDay,
                    onPrevMonth: _prevMonth,
                    onNextMonth: _nextMonth,
                    l10n: widget.l10n,
                    theme: theme,
                  ),
                ),

                // ── Time tab ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _TimeWheels(
                    hourController: _hourController,
                    minuteController: _minuteController,
                    onHourChanged: (h) => setState(() => _hour = h),
                    onMinuteChanged: (m) => setState(() => _minute = m),
                    theme: theme,
                    isBn: isBn,
                    l10n: widget.l10n,
                  ),
                ),
              ],
            ),
          ),

          // ── Action buttons ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(widget.l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(widget.l10n.done),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildSummary(bool isBn) {
    final l = widget.l10n;
    final day = l.localizeNumber(_day);
    final month = l.getMonthName(_month);
    final year = l.localizeNumber(_year);
    final h = l.localizeNumber(_hour.toString().padLeft(2, '0'));
    final m = l.localizeNumber(_minute.toString().padLeft(2, '0'));
    return '$day $month $year  •  $h:$m';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date grid — full width, same visual language as the app calendar
// ─────────────────────────────────────────────────────────────────────────────

class _DateGrid extends StatelessWidget {
  final int viewYear;
  final int viewMonth;
  final int daysInMonth;
  final bool Function(int) isSelectedDay;
  final bool Function(int) isToday;
  final void Function(int) onSelectDay;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _DateGrid({
    required this.viewYear,
    required this.viewMonth,
    required this.daysInMonth,
    required this.isSelectedDay,
    required this.isToday,
    required this.onSelectDay,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.l10n,
    required this.theme,
  });

  // weekday % 7 → Sun=0, Mon=1 … Sat=6
  int get _firstWeekdayOffset => DateTime(viewYear, viewMonth, 1).weekday % 7;

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final isBn = l10n.languageCode == 'bn';
    final monthName = l10n.getMonthName(viewMonth);
    final yearStr = l10n.localizeNumber(viewYear);
    final offset = _firstWeekdayOffset;
    final totalCells = offset + daysInMonth;

    final dayLabels = isBn
        ? ['র', 'স', 'ম', 'বু', 'বৃ', 'শু', 'শ']
        : ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    return Column(
      children: [
        // Month navigation header
        Row(
          children: [
            IconButton(
              onPressed: onPrevMonth,
              icon:
                  Icon(Icons.chevron_left_rounded, color: cs.onSurfaceVariant),
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Text(
                '$monthName $yearStr',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: onNextMonth,
              icon:
                  Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Day-of-week labels
        Row(
          children: dayLabels
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),

        const SizedBox(height: 4),

        // Day cells
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              if (index < offset) return const SizedBox.shrink();
              final day = index - offset + 1;
              final selected = isSelectedDay(day);
              final today = isToday(day);
              // col 5 = Fri, col 6 = Sat in Sunday-first grid
              final col = index % 7;
              final isWeekend = col == 5 || col == 6;

              return GestureDetector(
                onTap: () => onSelectDay(day),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? cs.primary
                        : today
                            ? cs.primary.withOpacity(0.12)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      l10n.localizeNumber(day),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        fontWeight: selected || today
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: selected
                            ? cs.onPrimary
                            : today
                                ? cs.primary
                                : isWeekend
                                    ? Colors.red.shade400
                                    : cs.onSurface,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Time wheels — full width, hour + minute side by side
// ─────────────────────────────────────────────────────────────────────────────

class _TimeWheels extends StatelessWidget {
  final FixedExtentScrollController hourController;
  final FixedExtentScrollController minuteController;
  final void Function(int) onHourChanged;
  final void Function(int) onMinuteChanged;
  final ThemeData theme;
  final bool isBn;
  final AppLocalizations l10n;

  const _TimeWheels({
    required this.hourController,
    required this.minuteController,
    required this.onHourChanged,
    required this.onMinuteChanged,
    required this.theme,
    required this.isBn,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Column labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    isBn ? 'ঘণ্টা' : 'Hour',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Center(
                  child: Text(
                    isBn ? 'মিনিট' : 'Minute',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Wheels row
        SizedBox(
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hour wheel
              Expanded(
                child: _Wheel(
                  controller: hourController,
                  itemCount: 24,
                  onChanged: onHourChanged,
                  label: (i) =>
                      l10n.localizeNumber(i.toString().padLeft(2, '0')),
                  theme: theme,
                ),
              ),

              // Separator
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  ':',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ),

              // Minute wheel
              Expanded(
                child: _Wheel(
                  controller: minuteController,
                  itemCount: 60,
                  onChanged: onMinuteChanged,
                  label: (i) =>
                      l10n.localizeNumber(i.toString().padLeft(2, '0')),
                  theme: theme,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single scroll wheel
// ─────────────────────────────────────────────────────────────────────────────

class _Wheel extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final void Function(int) onChanged;
  final String Function(int) label;
  final ThemeData theme;

  const _Wheel({
    required this.controller,
    required this.itemCount,
    required this.onChanged,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Selection highlight
        Container(
          height: 44,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        CupertinoPicker(
          scrollController: controller,
          itemExtent: 44,
          looping: true,
          selectionOverlay: const SizedBox.shrink(),
          onSelectedItemChanged: onChanged,
          children: List.generate(
            itemCount,
            (i) => Center(
              child: Text(
                label(i),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
