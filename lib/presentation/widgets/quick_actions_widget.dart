import 'package:flutter/material.dart';
import 'package:ekush_ponji/l10n/localization_helper.dart';
import 'package:ekush_ponji/constants/constants.dart';
import 'package:ekush_ponji/presentation/pages/reminders/add_reminder_screen.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationHelper.isBengali(context) 
                  ? 'দ্রুত কাজ' 
                  : 'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.add_alert,
                  label: LocalizationHelper.getAddReminder(context),
                  onTap: () => _addReminder(context),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.calendar_today,
                  label: LocalizationHelper.getCalendar(context),
                  onTap: () => _openCalendar(context),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.settings,
                  label: LocalizationHelper.getSettings(context),
                  onTap: () => _openSettings(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _addReminder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddReminderScreen(),
      ),
    );
  }

  void _openCalendar(BuildContext context) {
    // Navigate to calendar - you can implement this
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocalizationHelper.isBengali(context) 
            ? 'ক্যালেন্ডার শীঘ্রই আসছে' 
            : 'Calendar coming soon'),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    // Navigate to settings - you can implement this
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocalizationHelper.isBengali(context) 
            ? 'সেটিংস শীঘ্রই আসছে' 
            : 'Settings coming soon'),
      ),
    );
  }
}