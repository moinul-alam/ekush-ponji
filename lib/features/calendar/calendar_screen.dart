import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/calendar/calendar_viewmodel.dart';
import 'package:ekush_ponji/features/calendar/widgets/calendar_header.dart';
import 'package:ekush_ponji/features/calendar/widgets/week_days_row.dart';
import 'package:ekush_ponji/features/calendar/widgets/calendar_grid.dart';
import 'package:ekush_ponji/features/calendar/widgets/calendar_legend.dart';
import 'package:ekush_ponji/features/calendar/widgets/day_details_panel.dart';
import 'package:ekush_ponji/features/calendar/widgets/upcoming_holidays_widget.dart';
import 'package:ekush_ponji/features/calendar/widgets/upcoming_events_widget.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:go_router/go_router.dart';

class CalendarScreen extends BaseScreen {
  const CalendarScreen({super.key});

  @override
  BaseScreenState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends BaseScreenState<CalendarScreen> {
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
        onPressed: () => context.go(RouteNames.home),
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
    final viewState = ref.watch(calendarViewModelProvider);
    final viewModel = ref.read(calendarViewModelProvider.notifier);
    final l10n = AppLocalizations.of(context);

    if (viewState is ViewStateLoading) {
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

    final monthData = viewModel.currentMonthData;
    if (monthData == null) {
      return Center(child: Text(l10n.loadingData));
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          context.go(RouteNames.home);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            CalendarHeader(
              gregorianYear: monthData.gregorianYear,
              gregorianMonth: monthData.gregorianMonth,
              bengaliMonthsDisplay: viewModel.bengaliMonthsDisplay,
              onPreviousMonth: () => viewModel.goToPreviousMonth(),
              onNextMonth: () => viewModel.goToNextMonth(),
              onMonthTap: () => _showMonthPicker(context, ref),
              onYearTap: () => _showYearPicker(context, ref),
            ),
            const WeekDaysRow(),
            CalendarGrid(
              days: viewModel.calendarDays,
              onDayTap: (day) => viewModel.selectDate(day.gregorianDate),
              onSwipeLeft: () => viewModel.goToNextMonth(),
              onSwipeRight: () => viewModel.goToPreviousMonth(),
            ),
            const SizedBox(height: 16),
            const CalendarLegend(),
            DayDetailsPanel(
              selectedDay: viewModel.selectedDay,
              isExpanded: viewModel.isDayDetailsPanelExpanded,
              onToggleExpanded: () => viewModel.toggleDayDetailsPanel(),
            ),
            if (viewModel.upcomingHolidays.isNotEmpty)
              UpcomingHolidaysWidget(
                monthName: monthData.monthName,
                holidays: viewModel.upcomingHolidays,
              ),
            if (viewModel.upcomingEvents.isNotEmpty)
              UpcomingEventsWidget(
                monthName: monthData.monthName,
                events: viewModel.upcomingEvents,
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

    final currentDate = DateTime(monthData.gregorianYear, monthData.gregorianMonth);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020, 1),
      lastDate: DateTime(2030, 12),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select Month',
    );

    if (selectedDate != null && context.mounted) {
      await viewModel.jumpToMonth(selectedDate.year, selectedDate.month);
    }
  }

  Future<void> _showYearPicker(BuildContext context, WidgetRef ref) async {
    final viewModel = ref.read(calendarViewModelProvider.notifier);
    final monthData = viewModel.currentMonthData;
    if (monthData == null) return;

    final currentDate = DateTime(monthData.gregorianYear, monthData.gregorianMonth);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020, 1),
      lastDate: DateTime(2030, 12),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select Year',
    );

    if (selectedDate != null && context.mounted) {
      await viewModel.jumpToMonth(selectedDate.year, monthData.gregorianMonth);
    }
  }
}
