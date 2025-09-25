import 'package:flutter/material.dart';
import 'package:ekush_ponji/l10n/localization_helper.dart';
import 'package:ekush_ponji/constants/constants.dart';
import 'package:ekush_ponji/services/reminder_service.dart';
import 'package:ekush_ponji/data/models/reminder.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({Key? key}) : super(key: key);

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late ReminderService _reminderService;

  @override
  void initState() {
    super.initState();
    _reminderService = ReminderService();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationHelper.getAddReminder(context)),
        actions: [
          TextButton(
            onPressed: _saveReminder,
            child: Text(LocalizationHelper.getSave(context)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: LocalizationHelper.getReminderTitle(context),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return LocalizationHelper.getTitleRequired(context);
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: LocalizationHelper.isBengali(context) 
                      ? 'বিবরণ (ঐচ্ছিক)' 
                      : 'Description (Optional)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Date selection
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(LocalizationHelper.getSelectDate(context)),
                  subtitle: Text(_selectedDate != null 
                      ? _formatDate(context, _selectedDate!)
                      : LocalizationHelper.isBengali(context) 
                          ? 'তারিখ নির্বাচন করা হয়নি'
                          : 'No date selected'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _selectDate,
                ),
              ),
              
              const SizedBox(height: AppConstants.smallPadding),
              
              // Time selection
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(LocalizationHelper.getSelectTime(context)),
                  subtitle: Text(_selectedTime != null 
                      ? _formatTime(context, _selectedTime!)
                      : LocalizationHelper.isBengali(context) 
                          ? 'সময় নির্বাচন করা হয়নি'
                          : 'No time selected'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _selectTime,
                ),
              ),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveReminder,
                  icon: const Icon(Icons.save),
                  label: Text(LocalizationHelper.getSave(context)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
    final day = LocalizationHelper.formatNumber(context, date.day);
    final month = LocalizationHelper.getMonthName(context, date.month - 1);
    final year = LocalizationHelper.formatNumber(context, date.year);
    
    return LocalizationHelper.isBengali(context) 
        ? '$day $month $year'
        : '$day $month $year';
  }

  String _formatTime(BuildContext context, TimeOfDay time) {
    final hour = LocalizationHelper.formatNumber(context, time.hour);
    final minute = LocalizationHelper.formatNumber(context, time.minute);
    
    return '$hour:${minute.padLeft(2, LocalizationHelper.isBengali(context) ? '০' : '0')}';
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocalizationHelper.getDateRequired(context)),
        ),
      );
      return;
    }

    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime?.hour ?? 9,
      _selectedTime?.minute ?? 0,
    );

    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      dateTime: dateTime,
      createdAt: DateTime.now(),
    );

    try {
      await _reminderService.addReminder(reminder);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizationHelper.getReminderAdded(context)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizationHelper.getError(context)),
          ),
        );
      }
    }
  }
}