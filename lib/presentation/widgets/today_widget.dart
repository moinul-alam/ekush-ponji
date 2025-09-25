import 'package:flutter/material.dart';
import 'package:ekush_ponji/l10n/localization_helper.dart';
import 'package:ekush_ponji/constants/constants.dart';

class TodayWidget extends StatelessWidget {
  const TodayWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.today,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  LocalizationHelper.getToday(context),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              _formatDate(context, now),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatWeekday(context, now),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final day = LocalizationHelper.formatNumber(context, date.day);
    final month = LocalizationHelper.getMonthName(context, date.month - 1);
    final year = LocalizationHelper.formatNumber(context, date.year);
    
    return LocalizationHelper.isBengali(context) 
        ? '$day $month $year'
        : '$day $month $year';
  }

  String _formatWeekday(BuildContext context, DateTime date) {
    return LocalizationHelper.getWeekdayName(context, date.weekday - 1);
  }
}