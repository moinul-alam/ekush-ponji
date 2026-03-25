// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_drawer.dart';
import 'package:ekush_ponji/core/services/app_review_service.dart';
import 'package:ekush_ponji/features/home/home_viewmodel.dart';
import 'package:ekush_ponji/features/home/widgets/home_date_greeter_widget.dart';
import 'package:ekush_ponji/features/home/widgets/home_holidays_widget.dart';
import 'package:ekush_ponji/features/home/widgets/home_events_widget.dart';
import 'package:ekush_ponji/features/home/widgets/daily_quote_widget.dart';
import 'package:ekush_ponji/features/home/widgets/daily_word_widget.dart';
import 'package:ekush_ponji/features/home/widgets/app_review_banner.dart';
import 'package:ekush_ponji/core/widgets/ads/native_ad_widget.dart';

class HomeScreen extends BaseScreen {
  const HomeScreen({super.key});

  @override
  BaseScreenState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseScreenState<HomeScreen> {
  bool _showReviewBanner = false;

  @override
  NotifierProvider<HomeViewModel, ViewState> get viewModelProvider =>
      homeViewModelProvider;

  @override
  bool get useSafeArea => false;

  @override
  bool get resizeToAvoidBottomInset => true;

  @override
  bool get enablePullToRefresh => true;

  // Never show a loading overlay — home renders immediately from cache
  @override
  bool get showLoadingOverlay => false;

  @override
  void onScreenInit() {
    _checkAppReview();
  }

  Future<void> _checkAppReview() async {
    await AppReviewService.onAppLaunch();
    final showBanner = await AppReviewService.shouldShowFallbackBanner();
    if (mounted) {
      setState(() => _showReviewBanner = showBanner);
    }
  }

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
    return const AppHeader(
      logoPadding: EdgeInsets.only(top: 5),
    );
  }

  @override
  Widget? buildDrawer(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(homeViewModelProvider.notifier).userName;
    return AppDrawer(userName: userName);
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(homeViewModelProvider);

    // On error show error widget, otherwise always show content
    // Even during loading — Hive data loads fast enough that
    // the widgets populate before the first frame is visible
    if (viewState is ViewStateError) {
      return buildErrorWidget(viewState);
    }

    final viewModel = ref.watch(homeViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const HomeDateGreeterWidget(),
          const SizedBox(height: 8),
          HomeHolidaysWidget(holidays: viewModel.holidays),
          const SizedBox(height: 8),
          UpcomingEventsWidget(events: viewModel.events),
          const SizedBox(height: 8),
          const DailyQuoteWidget(),
          const SizedBox(height: 8),
          const NativeAdWidget(
            style: NativeAdStyle.card,
            cardMargin: EdgeInsets.fromLTRB(4, 4, 4, 4),
            cardBorderRadius: 16,
            cardSurfaceAlpha: 0.35,
          ),
          const SizedBox(height: 8),
          const DailyWordWidget(),
          if (_showReviewBanner) ...[
            const SizedBox(height: 8),
            AppReviewBanner(
              onDismiss: () {
                setState(() => _showReviewBanner = false);
              },
            ),
          ],
        ],
      ),
    );
  }
}
