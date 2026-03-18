// lib/features/calendar/calendar_screen.dart
//
// CHANGED: Back button now triggers interstitial ad before navigating home.
// Everything else is identical to the original file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/services/ad_service.dart';
import 'package:ekush_ponji/features/calendar/services/hijri_calendar_service.dart';
import 'package:ekush_ponji/features/calendar/calendar_viewmodel.dart';
import 'package:ekush_ponji/features/calendar/widgets/calendar_header.dart';
import 'package:ekush_ponji/features/calendar/widgets/week_days_row.dart';
import 'package:ekush_ponji/features/calendar/widgets/calendar_grid.dart';
import 'package:ekush_ponji/features/calendar/widgets/calendar_visibilities.dart';
import 'package:ekush_ponji/features/calendar/widgets/day_details_panel.dart';
import 'package:ekush_ponji/features/calendar/widgets/calendar_holidays_widget.dart';
import 'package:ekush_ponji/core/widgets/pickers/custom_month_year_picker.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:go_router/go_router.dart';

class CalendarScreen extends BaseScreen {
  const CalendarScreen({super.key});

  @override
  BaseScreenState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends BaseScreenState<CalendarScreen> {
  // Track horizontal drag to detect left/right swipes for month navigation
  double _dragStartX = 0;

  @override
  NotifierProvider<CalendarViewModel, ViewState> get viewModelProvider =>
      calendarViewModelProvider;

  @override
  bool get showLoadingOverlay => false;

  @override
  bool get enablePullToRefresh => true;

  @override
  Future<void> onRefresh() async {
    await ref.read(calendarViewModelProvider.notifier).loadCurrentMonth();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      title: Text(l10n.navCalendar),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        // CHANGED: show interstitial before navigating home
        onPressed: () {
          ref.read(adServiceProvider).showInterstitialIfAvailable(
            onClosed: () {
              if (mounted) context.go(RouteNames.home);
            },
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.today),
          tooltip: l10n.today,
          onPressed: () {
            ref.read(calendarViewModelProvider.notifier).loadCurrentMonth();
          },
        ),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    // Watch state — any change (selectDate, jumpToMonth) triggers rebuild.
    // Read notifier for calling actions (stable reference, no rebuild loop).
    final viewState = ref.watch(calendarViewModelProvider);
    final viewModel = ref.read(calendarViewModelProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final hijriService = ref.watch(hijriCalendarServiceProvider);

    final monthData = viewModel.currentMonthData;

    // Full-screen loading only on very first load when there is no data yet
    if (viewState is ViewStateLoading && monthData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              l10n.loadingData,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (viewState is ViewStateError) {
      return buildErrorWidget(viewState);
    }

    if (monthData == null) {
      return Center(child: Text(l10n.loadingData));
    }

    final hijriMonthsDisplay = hijriService.getHijriMonthsDisplay(
      gregorianYear: monthData.gregorianYear,
      gregorianMonth: monthData.gregorianMonth,
      languageCode: l10n.languageCode,
    );

    return GestureDetector(
      // Swipe left/right to change month — only triggers on fast horizontal
      // swipes, does not interfere with cell taps
      onHorizontalDragStart: (details) {
        _dragStartX = details.globalPosition.dx;
      },
      onHorizontalDragEnd: (details) {
        final dx = details.globalPosition.dx - _dragStartX;
        final velocity = details.primaryVelocity ?? 0;

        // Swipe right → go home (original behaviour, fast swipe only)
        if (velocity > 600 && dx > 60) {
          context.go(RouteNames.home);
          return;
        }
        // Swipe right (slower) → previous month
        if (dx > 60) {
          viewModel.goToPreviousMonth();
          return;
        }
        // Swipe left → next month
        if (dx < -60) {
          viewModel.goToNextMonth();
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // ─── Unified Calendar Card ───────────────────────
            Container(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  CalendarHeader(
                    gregorianYear: monthData.gregorianYear,
                    gregorianMonth: monthData.gregorianMonth,
                    bengaliMonthsDisplay: monthData.getBengaliMonthsDisplay(
                      useBangla: l10n.languageCode == 'bn',
                    ),
                    hijriMonthsDisplay: hijriMonthsDisplay,
                    onPreviousMonth: () => viewModel.goToPreviousMonth(),
                    onNextMonth: () => viewModel.goToNextMonth(),
                    onMonthTap: () => _showMonthPicker(context, ref),
                    onYearTap: () => _showYearPicker(context, ref),
                  ),

                  const WeekDaysRow(),

                  // Direct CalendarGrid — no PageView wrapper so taps
                  // reach CalendarDayCell's GestureDetector unobstructed
                  CalendarGrid(
                    days: viewModel.calendarDays,
                    onDayTap: (day) => viewModel.selectDate(day.gregorianDate),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ─── Date Visibility Controls ────────────────────
            const CalendarLegend(),

            // ─── Day Details Panel ───────────────────────────
            // Shown when viewState changes trigger a rebuild and
            // hasDateBeenSelected becomes true
            DayDetailsPanel(
              selectedDay: viewModel.selectedDay,
              isExpanded: viewModel.isDayDetailsPanelExpanded,
              onToggleExpanded: () => viewModel.toggleDayDetailsPanel(),
            ),

            // ─── All Month Holidays ──────────────────────────
            CalendarHolidaysWidget(
              monthName: l10n.getMonthName(monthData.gregorianMonth),
              holidays: viewModel.monthHolidays,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void onRetry() {
    ref.read(calendarViewModelProvider.notifier).loadCurrentMonth();
  }

  Future<void> _showMonthPicker(BuildContext context, WidgetRef ref) async {
    final viewModel = ref.read(calendarViewModelProvider.notifier);
    final monthData = viewModel.currentMonthData;
    if (monthData == null) return;
    final l10n = AppLocalizations.of(context);

    await showDialog(
      context: context,
      builder: (context) => MonthYearPickerDialog(
        initialYear: monthData.gregorianYear,
        initialMonth: monthData.gregorianMonth,
        l10n: l10n,
        onSelected: (year, month) {
          viewModel.jumpToMonth(year, month);
        },
      ),
    );
  }

  Future<void> _showYearPicker(BuildContext context, WidgetRef ref) async {
    await _showMonthPicker(context, ref);
  }
}
