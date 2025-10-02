import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_bottom_nav.dart';
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
  int _currentNavIndex = 0;

  @override
  NotifierProvider<HomeViewModel, ViewState> get viewModelProvider =>
      homeViewModelProvider;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppHeader(
      onSettingsTap: _onSettingsTap,
    );
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
    return _buildAppDrawer(context);
  }

  // Event handlers
  void _onSettingsTap() {
    // TODO: Navigate to settings screen
    showInfo('Settings screen - Coming soon');
  }

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;

    setState(() {
      _currentNavIndex = index;
    });

    // TODO: Navigate to respective screens
    switch (index) {
      case 0:
        // Already on Home
        break;
      case 1:
        showInfo('Calendar screen - Coming soon');
        break;
      case 2:
        showInfo('Calculator screen - Coming soon');
        break;
      case 3:
        showInfo('Settings screen - Coming soon');
        break;
    }
  }

  // App Drawer
  Widget _buildAppDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.primary,
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Welcome!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'একুশ পঞ্জি',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),

          // Drawer Items
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              showInfo('Profile - Coming soon');
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: const Text('Calendar'),
            onTap: () {
              Navigator.pop(context);
              showInfo('Calendar - Coming soon');
            },
          ),
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('Calculator'),
            onTap: () {
              Navigator.pop(context);
              showInfo('Calculator - Coming soon');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              showInfo('About - Coming soon');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              showInfo('Help & Support - Coming soon');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              _onSettingsTap();
            },
          ),
        ],
      ),
    );
  }

  @override
  bool get useSafeArea => false; // AppHeader handles safe area

  @override
  bool get resizeToAvoidBottomInset => true;
}
