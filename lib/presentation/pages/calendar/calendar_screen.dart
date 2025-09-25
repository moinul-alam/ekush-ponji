import 'package:flutter/material.dart';
import 'package:ekush_ponji/l10n/localization_helper.dart';
import 'package:ekush_ponji/constants/constants.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(LocalizationHelper.getCalendar(context)),
            floating: true,
            automaticallyImplyLeading: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      LocalizationHelper.isBengali(context) 
                          ? 'ক্যালেন্ডার শীঘ্রই আসছে' 
                          : 'Calendar Coming Soon',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      LocalizationHelper.isBengali(context)
                          ? 'আমরা একটি সুন্দর ক্যালেন্ডার তৈরি করছি।'
                          : 'We are working on a beautiful calendar for you.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}