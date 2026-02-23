import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_drawer.dart';
import 'package:ekush_ponji/features/home/home_viewmodel.dart';
import 'package:ekush_ponji/features/home/widgets/app_greeter.dart';
import 'package:ekush_ponji/features/home/widgets/today_date_widget.dart';
import 'package:ekush_ponji/features/home/widgets/upcoming_holidays_widget.dart';
// import 'package:ekush_ponji/features/home/widgets/upcoming_events_widget.dart';
import 'package:ekush_ponji/features/home/widgets/daily_quote_widget.dart';
import 'package:ekush_ponji/features/home/widgets/daily_word_widget.dart';

class HomeScreen extends BaseScreen {
  const HomeScreen({super.key});

  @override
  BaseScreenState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseScreenState<HomeScreen> {
  @override
  NotifierProvider<HomeViewModel, ViewState> get viewModelProvider =>
      homeViewModelProvider;

  @override
  bool get useSafeArea => false;

  @override
  bool get resizeToAvoidBottomInset => true;

  @override
  bool get enablePullToRefresh => true;

  @override
  bool get showLoadingOverlay => false;

  @override
  Future<void> onRefresh() async {
    await ref.read(homeViewModelProvider.notifier).refresh();
  }

  @override
  void onRetry() {
    ref.read(homeViewModelProvider.notifier).loadHomeData();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return const AppHeader();
  }

  @override
  Widget? buildDrawer(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(homeViewModelProvider.notifier).userName;
    return AppDrawer(userName: userName);
  }

  String _getCurrentMonthName() {
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ];
    return months[DateTime.now().month - 1];
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(homeViewModelProvider);

    if (viewState is ViewStateLoading && !viewState.isRefreshing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewState is ViewStateError) {
      return buildErrorWidget(viewState);
    }

    final viewModel = ref.read(homeViewModelProvider.notifier);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppGreeter(),
              const SizedBox(height: 8),
              const TodayDateWidget(),
              const SizedBox(height: 8),
              UpcomingHolidaysWidget(
                monthName: _getCurrentMonthName(),
                holidays: viewModel.holidays,
              ),
              const SizedBox(height: 8),
              // UpcomingEventsWidget(
              //   events: viewModel.events,
              // ),
              // const SizedBox(height: 8),
              const DailyQuoteWidget(),
              const SizedBox(height: 8),
              const DailyWordWidget(),
              const SizedBox(height: 16),
            ],
          ),
        ),
        // Reserved for ad banner
      ],
    );
  }
}