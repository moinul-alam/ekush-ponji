import 'package:flutter/material.dart';
import 'package:ekush_ponji/constants/constants.dart';
import 'package:ekush_ponji/l10n/localization_helper.dart';
import 'package:ekush_ponji/presentation/widgets/today_widget.dart';
import 'package:ekush_ponji/presentation/widgets/quick_actions_widget.dart';
import 'package:ekush_ponji/presentation/widgets/upcoming_events_widget.dart';
import 'package:ekush_ponji/presentation/pages/calendar/calendar_screen.dart';
import 'package:ekush_ponji/presentation/pages/reminders/reminders_screen.dart';
import 'package:ekush_ponji/presentation/pages/settings/settings_screen.dart';
import 'package:ekush_ponji/presentation/pages/reminders/add_reminder_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final Function(Locale) onLocaleChanged;

  const HomeScreen({
    Key? key,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _buildHomeContent(),
          const CalendarScreen(),
          const RemindersScreen(),
          SettingsScreen(
            onThemeChanged: widget.onThemeChanged,
            onLocaleChanged: widget.onLocaleChanged,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: LocalizationHelper.getHome(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            label: LocalizationHelper.getCalendar(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_outlined),
            selectedIcon: const Icon(Icons.notifications),
            label: LocalizationHelper.getReminders(context),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: LocalizationHelper.getSettings(context),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 2 // Show only on reminders tab
          ? FloatingActionButton(
              onPressed: _addReminder,
              tooltip: LocalizationHelper.getAddReminder(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: true,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              LocalizationHelper.getAppName(context),
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: _toggleLanguage,
              icon: const Icon(Icons.language),
              tooltip: LocalizationHelper.isBengali(context) ? 'English' : 'বাংলা',
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Today's information
              const TodayWidget(),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Quick actions
              const QuickActionsWidget(),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Upcoming events
              const UpcomingEventsWidget(),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Statistics or additional info can go here
              _buildStatsCard(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationHelper.isBengali(context) 
                  ? 'এই মাসের পরিসংখ্যান' 
                  : 'This Month\'s Statistics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  Icons.event,
                  '5',
                  LocalizationHelper.isBengali(context) ? 'ছুটির দিন' : 'Holidays',
                ),
                _buildStatItem(
                  context,
                  Icons.notification_important,
                  '12',
                  LocalizationHelper.isBengali(context) ? 'স্মারক' : 'Reminders',
                ),
                _buildStatItem(
                  context,
                  Icons.celebration,
                  '3',
                  LocalizationHelper.isBengali(context) ? 'উৎসব' : 'Events',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String count, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          LocalizationHelper.formatNumber(context, int.parse(count)),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: AppConstants.mediumAnimationDuration,
      curve: Curves.easeInOut,
    );
  }

  void _addReminder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddReminderScreen(),
      ),
    );
  }

  void _toggleLanguage() {
    final currentLocale = Localizations.localeOf(context);
    final newLocale = currentLocale.languageCode == 'bn' 
        ? const Locale('en', 'US')
        : const Locale('bn', 'BD');
    
    widget.onLocaleChanged(newLocale);
  }
}