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
    return _safeBuilder('HomeScreen', () {
      return Consumer<AppStateManager>(
        builder: (context, appState, child) {
          return _safeBuilder('HomeScreen Consumer', () {
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
                  _safePage('Calendar', () => const CalendarScreen()),
                  _safePage('Reminders', () => const RemindersScreen()),
                  _safePage('Settings', () => const SettingsScreen()),
                ],
              ),
              bottomNavigationBar: _safeBuilder('NavigationBar', () {
                return NavigationBar(
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
                );
              }),
              floatingActionButton: _selectedIndex == 2
                  ? _safeBuilder('FloatingActionButton', () {
                      return FloatingActionButton(
                        onPressed: _addReminder,
                        tooltip: _getLocalizedText('Add Reminder'),
                        child: const Icon(Icons.add),
                      );
                    })
                  : null,
            );
          });
        },
      );
    });
  }

  Widget _buildHomeContent() {
    return _safeBuilder('HomeContent', () {
      return CustomScrollView(
        slivers: [
          _safeSliver('AppBar', () {
            return SliverAppBar(
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
            );
          }),
          _safeSliver('Content', () {
            return SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _safeWidget('TodayWidget', () => const TodayWidget()),
                  const SizedBox(height: 16),
                  _safeWidget('QuickActionsWidget', () => const QuickActionsWidget()),
                  const SizedBox(height: 16),
                  _safeWidget('UpcomingEventsWidget', () => const UpcomingEventsWidget()),
                  const SizedBox(height: 16),
                  _buildStatsCard(),
                ]),
              ),
            );
          }),
        ],
      );
    });
  }

  Widget _buildStatsCard() {
    return _safeBuilder('StatsCard', () {
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
    });
  }

  Widget _buildStatItem(IconData icon, String count, String label) {
    return _safeBuilder('StatItem', () {
      return Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            count,
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
    });
  }

  // Safe widget builder - catches errors and shows placeholder
  Widget _safeWidget(String widgetName, Widget Function() builder) {
    try {
      return builder();
    } catch (e, stackTrace) {
      debugPrint('Error building $widgetName: $e');
      debugPrint('Stack trace: $stackTrace');
      return _buildErrorPlaceholder(widgetName, e.toString());
    }
  }

  // Safe builder for general widgets
  Widget _safeBuilder(String componentName, Widget Function() builder) {
    try {
      return builder();
    } catch (e, stackTrace) {
      debugPrint('Error in $componentName: $e');
      debugPrint('Stack trace: $stackTrace');
      return _buildErrorScreen(componentName, e.toString());
    }
  }

  // Safe page builder for navigation pages
  Widget _safePage(String pageName, Widget Function() builder) {
    try {
      return builder();
    } catch (e, stackTrace) {
      debugPrint('Error loading $pageName page: $e');
      debugPrint('Stack trace: $stackTrace');
      return _buildPageError(pageName, e.toString());
    }
  }

  // Safe sliver builder
  Widget _safeSliver(String sliverName, Widget Function() builder) {
    try {
      return builder();
    } catch (e, stackTrace) {
      debugPrint('Error building $sliverName sliver: $e');
      debugPrint('Stack trace: $stackTrace');
      return SliverToBoxAdapter(
        child: _buildErrorPlaceholder(sliverName, e.toString()),
      );
    }
  }

  // Error placeholder for small widgets
  Widget _buildErrorPlaceholder(String widgetName, String error) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 32),
            const SizedBox(height: 8),
            Text(
              '$widgetName Error',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Error screen for major components
  Widget _buildErrorScreen(String componentName, String error) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$componentName Error'),
        backgroundColor: Colors.red.shade100,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error in $componentName',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() {}),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Error page for navigation pages
  Widget _buildPageError(String pageName, String error) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageName),
        backgroundColor: Colors.orange.shade100,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              '$pageName Unavailable',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('This page is under construction'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 0; // Go back to home
                });
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }

  void _onDestinationSelected(int index) {
    try {
      setState(() {
        _selectedIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      debugPrint('Error in navigation: $e');
    }
  }

  void _addReminder() {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddReminderScreen(),
        ),
      );
    } catch (e) {
      debugPrint('Error opening AddReminderScreen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot open Add Reminder: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleLanguage() {
    try {
      final appState = context.read<AppStateManager>();
      final currentLocale = appState.locale;
      final newLocale = currentLocale.languageCode == 'bn' 
          ? const Locale('en', 'US')
          : const Locale('bn', 'BD');
      
      appState.updateLocale(newLocale);
    } catch (e) {
      debugPrint('Error toggling language: $e');
    }
  }

  bool _isBengali() {
    try {
      final appState = context.watch<AppStateManager>();
      return appState.locale.languageCode == 'bn';
    } catch (e) {
      debugPrint('Error checking language: $e');
      return true; // Default to Bengali
    }
  }

  String _getLocalizedText(String key) {
    try {
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
    } catch (e) {
      debugPrint('Error in localization: $e');
      return key; // Return the key itself if localization fails
    }
  }
}