import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import 'home_viewmodel.dart';

// Provider for HomeViewModel
final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
  HomeViewModel.new,
);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeNotifier = ref.read(homeViewModelProvider.notifier);

    // Show error snackbar if there's an error
    ref.listen<HomeState>(homeViewModelProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ekush Ponji'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings - Coming Soon')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => homeNotifier.refreshHomeData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Card
                  _buildGreetingCard(context, homeState),

                  const SizedBox(height: 24),

                  // Placeholder sections
                  _buildPlaceholderSection(
                    context,
                    title: 'Today',
                    icon: Icons.today,
                    description: 'Today\'s date and events',
                  ),

                  const SizedBox(height: 16),

                  _buildPlaceholderSection(
                    context,
                    title: 'Upcoming Holidays',
                    icon: Icons.celebration,
                    description: 'View upcoming holidays',
                  ),

                  const SizedBox(height: 16),

                  _buildPlaceholderSection(
                    context,
                    title: 'Reminders',
                    icon: Icons.notifications,
                    description: 'Your pending reminders',
                  ),

                  const SizedBox(height: 16),

                  _buildPlaceholderSection(
                    context,
                    title: 'Daily Quote',
                    icon: Icons.format_quote,
                    description: 'Inspirational quote of the day',
                  ),

                  const SizedBox(height: 16),

                  _buildPlaceholderSection(
                    context,
                    title: 'Word of the Day',
                    icon: Icons.book,
                    description: 'Learn a new word today',
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (homeState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context, HomeState homeState) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.waving_hand,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    homeState.greetingMessage.isEmpty
                        ? 'Welcome!'
                        : homeState.greetingMessage,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome to Ekush Ponji',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your all-in-one calendar with Bengali dates, events, and reminders',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 32,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: theme.textTheme.bodySmall,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title - Coming Soon')),
          );
        },
      ),
    );
  }
}