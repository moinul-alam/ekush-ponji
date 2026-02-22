import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/calendar/calendar_viewmodel.dart';
import 'package:ekush_ponji/features/calendar/widgets/calendar_header.dart';
import 'package:ekush_ponji/features/calendar/widgets/week_days_row.dart';
import 'package:ekush_ponji/features/calendar/widgets/calendar_grid.dart';
import 'package:ekush_ponji/features/calendar/widgets/day_details_panel.dart';
import 'package:ekush_ponji/features/calendar/widgets/upcoming_holidays_widget.dart';
// import 'package:ekush_ponji/features/calendar/widgets/upcoming_events_widget.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:go_router/go_router.dart';

class CalendarScreen extends BaseScreen {
  const CalendarScreen({super.key});

  @override
  BaseScreenState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends BaseScreenState<CalendarScreen> {
  late PageController _pageController;

  // Page index represents offset from initial month
  // We start at page 1000 to allow scrolling back in time
  static const int _initialPage = 1000;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
            _pageController.animateToPage(
              _initialPage,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
            ref
                .read(calendarViewModelProvider.notifier)
                .loadCurrentMonth();
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
        if (details.primaryVelocity != null &&
            details.primaryVelocity! > 300) {
          context.go(RouteNames.home);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // ─── Unified Calendar Card ───────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .shadow
                        .withOpacity(0.07),
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
                  // Header inside card
                  CalendarHeader(
                    gregorianYear: monthData.gregorianYear,
                    gregorianMonth: monthData.gregorianMonth,
                    bengaliMonthsDisplay:
                        monthData.getBengaliMonthsDisplay(
                      useBangla: l10n.languageCode == 'bn',
                    ),
                    onPreviousMonth: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                    },
                    onNextMonth: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                    },
                    onMonthTap: () => _showMonthPicker(context, ref),
                    onYearTap: () => _showYearPicker(context, ref),
                  ),

                  // Week days row inside card
                  const WeekDaysRow(),

                  // PageView for animated month switching
                  SizedBox(
                    height: _gridHeight(viewModel.calendarDays.length),
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (page) {
                        final offset = page - _initialPage;
                        _onPageChanged(offset, viewModel);
                      },
                      itemBuilder: (context, page) {
                        return CalendarGrid(
                          days: viewModel.calendarDays,
                          onDayTap: (day) =>
                              viewModel.selectDate(day.gregorianDate),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ─── Day Details Panel ───────────────────────────
            if (viewModel.hasDateBeenSelected)
              DayDetailsPanel(
                selectedDay: viewModel.selectedDay,
                isExpanded: viewModel.isDayDetailsPanelExpanded,
                onToggleExpanded: () =>
                    viewModel.toggleDayDetailsPanel(),
              ),

            // ─── Upcoming Holidays ───────────────────────────
            if (viewModel.upcomingHolidays.isNotEmpty)
              UpcomingHolidaysWidget(
                monthName:
                    l10n.getMonthName(monthData.gregorianMonth),
                holidays: viewModel.upcomingHolidays,
              ),

            // ─── Upcoming Events ─────────────────────────────
            // if (viewModel.upcomingEvents.isNotEmpty)
            //   UpcomingEventsWidget(
            //     monthName:
            //         l10n.getMonthName(monthData.gregorianMonth),
            //     events: viewModel.upcomingEvents,
            //   ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Calculate grid height based on number of day cells
  double _gridHeight(int cellCount) {
    final rows = (cellCount / 7).ceil();
    // Each row is approximately 56px tall
    return rows * 68.0 + 8;
  }

  /// Handle PageView page change → navigate months in ViewModel
  void _onPageChanged(int offset, CalendarViewModel viewModel) {
    final now = DateTime.now();
    int targetMonth = now.month + offset;
    int targetYear = now.year;

    // Normalize month overflow/underflow
    while (targetMonth > 12) {
      targetMonth -= 12;
      targetYear++;
    }
    while (targetMonth < 1) {
      targetMonth += 12;
      targetYear--;
    }

    viewModel.jumpToMonth(targetYear, targetMonth);
  }

  @override
  void onRetry() {
    ref.read(calendarViewModelProvider.notifier).loadCurrentMonth();
  }

  Future<void> _showMonthPicker(BuildContext context, WidgetRef ref) async {
    final viewModel = ref.read(calendarViewModelProvider.notifier);
    final monthData = viewModel.currentMonthData;
    if (monthData == null) return;

    final currentDate =
        DateTime(monthData.gregorianYear, monthData.gregorianMonth);
    final l10n = AppLocalizations.of(context);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020, 1),
      lastDate: DateTime(2030, 12),
      initialDatePickerMode: DatePickerMode.year,
      helpText: l10n.selectMonth,
    );

    if (selectedDate != null && context.mounted) {
      await viewModel.jumpToMonth(
          selectedDate.year, selectedDate.month);
    }
  }

  Future<void> _showYearPicker(BuildContext context, WidgetRef ref) async {
    final viewModel = ref.read(calendarViewModelProvider.notifier);
    final monthData = viewModel.currentMonthData;
    if (monthData == null) return;

    final currentDate =
        DateTime(monthData.gregorianYear, monthData.gregorianMonth);
    final l10n = AppLocalizations.of(context);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020, 1),
      lastDate: DateTime(2030, 12),
      initialDatePickerMode: DatePickerMode.year,
      helpText: l10n.selectYear,
    );

    if (selectedDate != null && context.mounted) {
      await viewModel.jumpToMonth(
          selectedDate.year, monthData.gregorianMonth);
    }
  }
}