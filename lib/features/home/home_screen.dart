import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_bottom_nav.dart';
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
import 'package:ekush_ponji/app/router/route_names.dart';

class HomeScreen extends BaseScreen {
  const HomeScreen({super.key});

  @override
  BaseScreenState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseScreenState<HomeScreen> {
  int _currentNavIndex = 0;

  @override
  NotifierProvider<HomeViewModel, ViewState> get viewModelProvider =>
      homeViewModelProvider;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return const AppHeader();
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final holidays = viewModel.holidays;
    final events = viewModel.events;
    final userName = viewModel.userName;

    return Column(
      children: [
        // Main scrollable content
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => viewModel.refreshHomeData(),
            child: HomeGridLayout(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                // Greeter
                AppGreeter(userName: userName),

                // Today's Date
                const TodayDateWidget(),

                // Upcoming Holidays
                UpcomingHolidaysWidget(
                  holidays: holidays.isEmpty ? null : holidays,
                ),

                // Upcoming Events
                UpcomingEventsWidget(
                  events: events.isEmpty ? null : events,
                ),

                // Daily Quote
                const DailyQuoteWidget(),

                // Daily Word
                const DailyWordWidget(),

                // Bottom spacing for ad banner
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        // Ad Banner
        const AppAdBannerBottom(),
      ],
    );
  }

  @override
  Widget? buildBottomNavigationBar(BuildContext context, WidgetRef ref) {
    return AppBottomNav(
      currentIndex: _currentNavIndex,
      onTap: _onNavTap,
    );
  }

  @override
  Widget? buildDrawer(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(homeViewModelProvider.notifier);
    return AppDrawer(userName: viewModel.userName);
  }

  // Event handlers
  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;

    setState(() {
      _currentNavIndex = index;
    });

    // Navigate to respective screens
    switch (index) {
      case 0:
        // Already on Home
        break;
      case 1:
        context.go(RouteNames.calendar);
        break;
      case 2:
        context.go(RouteNames.calculator);
        break;
      case 3:
        context.go(RouteNames.settings);
        break;
    }
  }

  @override
  bool get useSafeArea => false; // AppHeader handles safe area

  @override
  bool get resizeToAvoidBottomInset => true;
}
