// lib/core/widgets/pickers/app_date_picker.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';

/// A date-only bottom-sheet picker (no time tab).
/// Shares the same visual language as [AppDateTimePicker] but is leaner —
/// no tab bar, no time wheels. Use this wherever only a calendar date is needed.
class AppDatePicker {
  AppDatePicker._();

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
      builder: (_) => _DatePickerSheet(
        initial: initial ?? DateTime.now(),
        l10n: l10n,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DatePickerSheet extends StatefulWidget {
  final DateTime initial;
  final AppLocalizations l10n;

  const _DatePickerSheet({required this.initial, required this.l10n});

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  late int _year;
  late int _month;
  late int _day;

  late int _viewYear;
  late int _viewMonth;

  bool _showingMonthYearPicker = false;

  late FixedExtentScrollController _monthWheelController;
  late FixedExtentScrollController _yearWheelController;

  static const int _minYear = 1924;
  static const int _maxYear = 2124;
  static const int _yearCount = _maxYear - _minYear + 1;

  @override
  void initState() {
    super.initState();
    final d = widget.initial;
    _year = d.year;
    _month = d.month;
    _day = d.day;
    _viewYear = d.year;
    _viewMonth = d.month;

    _monthWheelController =
        FixedExtentScrollController(initialItem: _viewMonth - 1);
    _yearWheelController = FixedExtentScrollController(
      initialItem: (_viewYear - _minYear).clamp(0, _yearCount - 1),
    );
  }

  @override
  void dispose() {
    _monthWheelController.dispose();
    _yearWheelController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  void _clampDay() {
    final maxDay = _daysInMonth(_year, _month);
    if (_day > maxDay) _day = maxDay;
  }

  void _syncWheelsToView() {
    _monthWheelController.jumpToItem(_viewMonth - 1);
    final yearIdx = (_viewYear - _minYear).clamp(0, _yearCount - 1);
    _yearWheelController.jumpToItem(yearIdx);
  }

  // ── Navigation ─────────────────────────────────────────────

  void _prevMonth() => setState(() {
        if (_viewMonth == 1) {
          _viewMonth = 12;
          _viewYear--;
        } else {
          _viewMonth--;
        }
        _syncWheelsToView();
      });

  void _nextMonth() => setState(() {
        if (_viewMonth == 12) {
          _viewMonth = 1;
          _viewYear++;
        } else {
          _viewMonth++;
        }
        _syncWheelsToView();
      });

  void _openMonthYearPicker() => setState(() => _showingMonthYearPicker = true);
  void _closeMonthYearPicker() =>
      setState(() => _showingMonthYearPicker = false);

  void _onMonthYearConfirm() {
    setState(() {
      _clampDay();
      _showingMonthYearPicker = false;
    });
  }

  // ── Day selection ──────────────────────────────────────────

  void _selectDay(int day) => setState(() {
        _year = _viewYear;
        _month = _viewMonth;
        _day = day;
      });

  bool _isSelectedDay(int day) =>
      _viewYear == _year && _viewMonth == _month && _day == day;

  bool _isToday(int day) {
    final now = DateTime.now();
    return _viewYear == now.year && _viewMonth == now.month && day == now.day;
  }

  // ── Confirm ────────────────────────────────────────────────

  void _confirm() => Navigator.of(context).pop(DateTime(_year, _month, _day));

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final day = widget.l10n.localizeNumber(_day);
    final monthName = widget.l10n.getMonthName(_month);
    final year = widget.l10n.localizeNumber(_year);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // Slightly shorter than the date-time picker (no time tab needed)
      height: MediaQuery.of(context).size.height * 0.54,
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
              color: cs.onSurfaceVariant.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Summary bar ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Icon(Icons.event_rounded, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  '$day $monthName $year',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),

          // ── Date section ─────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: _showingMonthYearPicker
                    ? _MonthYearPicker(
                        key: const ValueKey('mypicker'),
                        viewYear: _viewYear,
                        viewMonth: _viewMonth,
                        monthController: _monthWheelController,
                        yearController: _yearWheelController,
                        minYear: _minYear,
                        yearCount: _yearCount,
                        l10n: widget.l10n,
                        theme: theme,
                        onMonthChanged: (m) =>
                            setState(() => _viewMonth = m + 1),
                        onYearChanged: (idx) =>
                            setState(() => _viewYear = _minYear + idx),
                        onCancel: _closeMonthYearPicker,
                        onConfirm: _onMonthYearConfirm,
                      )
                    : _DateGrid(
                        key: const ValueKey('dategrid'),
                        viewYear: _viewYear,
                        viewMonth: _viewMonth,
                        daysInMonth: _daysInMonth(_viewYear, _viewMonth),
                        isSelectedDay: _isSelectedDay,
                        isToday: _isToday,
                        onSelectDay: _selectDay,
                        onPrevMonth: _prevMonth,
                        onNextMonth: _nextMonth,
                        onHeaderTap: _openMonthYearPicker,
                        l10n: widget.l10n,
                        theme: theme,
                      ),
              ),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Date grid  (self-contained copy — no dependency on app_date_time_picker.dart)
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
  final VoidCallback onHeaderTap;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _DateGrid({
    super.key,
    required this.viewYear,
    required this.viewMonth,
    required this.daysInMonth,
    required this.isSelectedDay,
    required this.isToday,
    required this.onSelectDay,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onHeaderTap,
    required this.l10n,
    required this.theme,
  });

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
        // ── Month navigation header ──────────────────────────
        Row(
          children: [
            IconButton(
              onPressed: onPrevMonth,
              icon:
                  Icon(Icons.chevron_left_rounded, color: cs.onSurfaceVariant),
              visualDensity: VisualDensity.compact,
              tooltip: isBn ? 'আগের মাস' : 'Previous month',
            ),
            Expanded(
              child: GestureDetector(
                onTap: onHeaderTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$monthName $yearStr',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        size: 20,
                        color: cs.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onNextMonth,
              icon:
                  Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              visualDensity: VisualDensity.compact,
              tooltip: isBn ? 'পরের মাস' : 'Next month',
            ),
          ],
        ),

        const SizedBox(height: 4),

        // ── Day-of-week labels ───────────────────────────────
        Row(
          children: dayLabels
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),

        const SizedBox(height: 4),

        // ── Day cells ────────────────────────────────────────
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
              final col = index % 7;
              final isWeekend = col == 5 || col == 6;

              return GestureDetector(
                onTap: () => onSelectDay(day),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? cs.primary
                        : today
                            ? cs.primary.withValues(alpha: 0.12)
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
// Inline month + year picker
// ─────────────────────────────────────────────────────────────────────────────

class _MonthYearPicker extends StatelessWidget {
  final int viewYear;
  final int viewMonth;
  final FixedExtentScrollController monthController;
  final FixedExtentScrollController yearController;
  final int minYear;
  final int yearCount;
  final AppLocalizations l10n;
  final ThemeData theme;
  final void Function(int) onMonthChanged;
  final void Function(int) onYearChanged;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _MonthYearPicker({
    super.key,
    required this.viewYear,
    required this.viewMonth,
    required this.monthController,
    required this.yearController,
    required this.minYear,
    required this.yearCount,
    required this.l10n,
    required this.theme,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final isBn = l10n.languageCode == 'bn';

    return Column(
      children: [
        // ── Header row ───────────────────────────────────────
        Row(
          children: [
            TextButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(isBn ? 'ফিরুন' : 'Back'),
              style: TextButton.styleFrom(
                foregroundColor: cs.onSurfaceVariant,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const Spacer(),
            Text(
              isBn ? 'মাস ও বছর' : 'Month & Year',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onConfirm,
              style: TextButton.styleFrom(
                foregroundColor: cs.primary,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(
                isBn ? 'ঠিক আছে' : 'OK',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ── Column labels ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    isBn ? 'বছর' : 'Year',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    isBn ? 'মাস' : 'Month',
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

        const SizedBox(height: 8),

        // ── Wheels ───────────────────────────────────────────
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 44,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // Year wheel
                    Expanded(
                      flex: 2,
                      child: CupertinoPicker(
                        scrollController: yearController,
                        itemExtent: 44,
                        looping: false,
                        selectionOverlay: const SizedBox.shrink(),
                        onSelectedItemChanged: onYearChanged,
                        children: List.generate(yearCount, (i) {
                          final y = minYear + i;
                          return Center(
                            child: Text(
                              l10n.localizeNumber(y),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    // Month wheel (wider)
                    Expanded(
                      flex: 3,
                      child: CupertinoPicker(
                        scrollController: monthController,
                        itemExtent: 44,
                        looping: true,
                        selectionOverlay: const SizedBox.shrink(),
                        onSelectedItemChanged: onMonthChanged,
                        children: List.generate(12, (i) {
                          return Center(
                            child: Text(
                              l10n.getMonthName(i + 1),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
