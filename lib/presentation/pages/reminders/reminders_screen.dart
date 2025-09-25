import 'package:flutter/material.dart';
import 'package:ekush_ponji/l10n/localization_helper.dart';
import 'package:ekush_ponji/constants/constants.dart';
import 'package:ekush_ponji/services/reminder_service.dart';
import 'package:ekush_ponji/data/models/reminder.dart';
import 'add_reminder_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  late ReminderService _reminderService;
  List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _reminderService = ReminderService();
    _loadReminders();
  }

  void _loadReminders() {
    setState(() {
      _reminders = _reminderService.getAllReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(LocalizationHelper.getReminders(context)),
            floating: true,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: _addReminder,
                icon: const Icon(Icons.add),
                tooltip: LocalizationHelper.getAddReminder(context),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            sliver: _reminders.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          Text(
                            LocalizationHelper.getNoRemindersFound(context),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final reminder = _reminders[index];
                        return _buildReminderCard(reminder);
                      },
                      childCount: _reminders.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: ListTile(
        leading: Checkbox(
          value: reminder.isCompleted,
          onChanged: (bool? value) {
            if (value != null) {
              _toggleReminder(reminder);
            }
          },
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
            color: reminder.isCompleted 
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reminder.description?.isNotEmpty == true)
              Text(reminder.description!),
            const SizedBox(height: 4),
            Text(_formatDateTime(context, reminder.dateTime)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'delete':
                _deleteReminder(reminder);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(LocalizationHelper.getDelete(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final day = LocalizationHelper.formatNumber(context, dateTime.day);
    final month = LocalizationHelper.getMonthName(context, dateTime.month - 1);
    final year = LocalizationHelper.formatNumber(context, dateTime.year);
    final hour = LocalizationHelper.formatNumber(context, dateTime.hour);
    final minute = LocalizationHelper.formatNumber(context, dateTime.minute);
    
    return LocalizationHelper.isBengali(context)
        ? '$day $month $year, $hour:${minute.padLeft(2, '০')}'
        : '$day $month $year, $hour:${minute.padLeft(2, '0')}';
  }

  void _toggleReminder(Reminder reminder) async {
    await _reminderService.markAsCompleted(reminder.id);
    _loadReminders();
  }

  void _deleteReminder(Reminder reminder) async {
    await _reminderService.deleteReminder(reminder.id);
    _loadReminders();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocalizationHelper.isBengali(context) 
              ? 'স্মারক মুছে ফেলা হয়েছে' 
              : 'Reminder deleted'),
        ),
      );
    }
  }

  void _addReminder() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddReminderScreen(),
      ),
    );
    
    if (result == true) {
      _loadReminders();
    }
  }
}