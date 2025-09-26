// lib/presentation/pages/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ekush_ponji/constants/constants.dart';
import 'package:ekush_ponji/l10n/localization_helper.dart';
import 'package:ekush_ponji/app/state/app_state_manager.dart';
import 'package:ekush_ponji/presentation/widgets/today_widget.dart';
import 'package:ekush_ponji/presentation/widgets/quick_actions_widget.dart';
import 'package:ekush_ponji/presentation/widgets/upcoming_events_widget.dart';
import 'package:ekush_ponji/presentation/pages/calendar/calendar_screen.dart';
import 'package:ekush_ponji/presentation/pages/reminders/reminders_screen.dart';
import 'package:ekush_ponji/presentation/pages/settings/settings_screen.dart';
import 'package:ekush_ponji/presentation/pages/reminders/add_reminder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
    return Consumer<AppStateManager>(
      builder: (context, appState, child) {
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
              const SettingsScreen(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: _getLocalizedText('Home'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_today_outlined),
                selectedIcon: const Icon(Icons.calendar_today),
                label: _getLocalizedText('Calendar'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.notifications_outlined),
                selectedIcon: const Icon(Icons.notifications),
                label: _getLocalizedText('Reminders'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: _getLocalizedText('Settings'),
              ),
            ],
          ),
          floatingActionButton: _selectedIndex == 2
              ? FloatingActionButton(
                  onPressed: _addReminder,
                  tooltip: _getLocalizedText('Add Reminder'),
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
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
              _getLocalizedText('Ekush Ponji'),
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
              tooltip: _isBengali() ? 'English' : 'বাংলা',
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16.0), // Use hardcoded value for now
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const TodayWidget(),
              const SizedBox(height: 16),
              const QuickActionsWidget(),
              const SizedBox(height: 16),
              const UpcomingEventsWidget(),
              const SizedBox(height: 16),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isBengali() 
                  ? 'এই মাসের পরিসংখ্যান' 
                  : 'This Month\'s Statistics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.event,
                  '5',
                  _isBengali() ? 'ছুটির দিন' : 'Holidays',
                ),
                _buildStatItem(
                  Icons.notification_important,
                  '12',
                  _isBengali() ? 'স্মারক' : 'Reminders',
                ),
                _buildStatItem(
                  Icons.celebration,
                  '3',
                  _isBengali() ? 'উৎসব' : 'Events',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          count, // Simplified for now
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
      duration: const Duration(milliseconds: 300),
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
    final appState = context.read<AppStateManager>();
    final currentLocale = appState.locale;
    final newLocale = currentLocale.languageCode == 'bn' 
        ? const Locale('en', 'US')
        : const Locale('bn', 'BD');
    
    appState.updateLocale(newLocale);
  }

  bool _isBengali() {
    final appState = context.watch<AppStateManager>();
    return appState.locale.languageCode == 'bn';
  }

  String _getLocalizedText(String key) {
    // Simplified localization for debugging
    final isBengali = _isBengali();
    switch (key) {
      case 'Home': return isBengali ? 'হোম' : 'Home';
      case 'Calendar': return isBengali ? 'ক্যালেন্ডার' : 'Calendar';
      case 'Reminders': return isBengali ? 'স্মারক' : 'Reminders';
      case 'Settings': return isBengali ? 'সেটিংস' : 'Settings';
      case 'Add Reminder': return isBengali ? 'স্মারক যোগ করুন' : 'Add Reminder';
      case 'Ekush Ponji': return isBengali ? 'একুশ পঞ্জি' : 'Ekush Ponji';
      default: return key;
    }
  }
}