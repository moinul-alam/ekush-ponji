import 'package:flutter/material.dart';
import 'package:ekush_ponji/l10n/localization_helper.dart';
import 'package:ekush_ponji/constants/constants.dart';
import 'package:ekush_ponji/services/reminder_service.dart';
import 'package:ekush_ponji/data/models/reminder.dart';

class UpcomingEventsWidget extends StatelessWidget {
  const UpcomingEventsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reminderService = ReminderService();
    final upcomingReminders = reminderService.getUpcomingReminders().take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.upcoming,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  LocalizationHelper.isBengali(context) 
                      ? 'আসন্ন ইভেন্ট' 
                      : 'Upcoming Events',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            if (upcomingReminders.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Text(
                    LocalizationHelper.getNoRemindersFound(context),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...upcomingReminders.map((reminder) => _buildReminderItem(context, reminder)),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderItem(BuildContext context, Reminder reminder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDateTime(context, reminder.dateTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final day = LocalizationHelper.formatNumber(context, dateTime.day);
    final month = LocalizationHelper.getMonthName(context, dateTime.month - 1);
    final hour = LocalizationHelper.formatNumber(context, dateTime.hour);
    final minute = LocalizationHelper.formatNumber(context, dateTime.minute);
    
    return LocalizationHelper.isBengali(context)
        ? '$day $month, $hour:${minute.padLeft(2, '0')}'
        : '$day $month, $hour:${minute.padLeft(2, '0')}';
  }
}