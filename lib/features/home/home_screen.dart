// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_drawer.dart';
import 'package:ekush_ponji/core/widgets/ads/app_ad_banner_bottom.dart';
import 'package:ekush_ponji/features/home/home_viewmodel.dart';
import 'package:ekush_ponji/features/home/widgets/app_greeter.dart';
import 'package:ekush_ponji/features/home/widgets/today_date_widget.dart';
import 'package:ekush_ponji/features/home/widgets/upcoming_holidays_widget.dart';
import 'package:ekush_ponji/features/home/widgets/upcoming_events_widget.dart';
import 'package:ekush_ponji/features/home/widgets/daily_quote_widget.dart';
import 'package:ekush_ponji/features/home/widgets/daily_word_widget.dart';
import 'package:ekush_ponji/features/home/widgets/home_grid_layout.dart';

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
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return const AppHeader();
  }

  @override
  Widget? buildDrawer(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(homeViewModelProvider.notifier);
    return AppDrawer(userName: viewModel.userName);
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    if (viewState is ViewStateLoading && !viewState.isRefreshing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewState is ViewStateError) {
      return buildErrorWidget(viewState);
    }

    final holidays = viewModel.holidays;
    final events = viewModel.events;
    final userName = viewModel.userName;

    return Column(
      children: [
        Expanded(
          child: HomeGridLayout(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              AppGreeter(userName: userName),
              const TodayDateWidget(),
              UpcomingHolidaysWidget(
                holidays: holidays.isEmpty ? null : holidays,
              ),
              UpcomingEventsWidget(
                events: events.isEmpty ? null : events,
              ),
              const DailyQuoteWidget(),
              const DailyWordWidget(),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const AppAdBannerBottom(),
      ],
    );
  }

  @override
  void onRetry() {
    ref.read(homeViewModelProvider.notifier).loadHomeData();
  }
}