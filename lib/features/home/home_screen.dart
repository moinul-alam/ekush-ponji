// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_drawer.dart';
import 'package:ekush_ponji/features/home/home_viewmodel.dart';
import 'package:ekush_ponji/features/home/widgets/today_date_widget.dart';
import 'package:ekush_ponji/features/home/widgets/home_holidays_widget.dart';
import 'package:ekush_ponji/features/home/widgets/home_events_widget.dart';
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

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(homeViewModelProvider);

    if (viewState is ViewStateLoading && !viewState.isRefreshing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewState is ViewStateError) {
      return buildErrorWidget(viewState);
    }

    final viewModel = ref.watch(homeViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // const AppGreeter(),
          const SizedBox(height: 8),
          const HomeDateGreeterWidget(),
          const SizedBox(height: 8),
          HomeHolidaysWidget(holidays: viewModel.holidays),
          const SizedBox(height: 8),
          UpcomingEventsWidget(events: viewModel.events),
          const SizedBox(height: 8),
          const DailyQuoteWidget(),
          const SizedBox(height: 8),
          const DailyWordWidget(),
        ],
      ),
    );
  }
}
