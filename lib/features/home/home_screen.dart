// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_drawer.dart';
import 'package:ekush_ponji/features/home/home_viewmodel.dart';
import 'package:ekush_ponji/features/home/widgets/app_greeter.dart';
import 'package:ekush_ponji/features/home/widgets/today_date_widget.dart';
import 'package:ekush_ponji/features/home/widgets/home_holidays_widget.dart';
import 'package:ekush_ponji/features/home/widgets/home_events_widget.dart';
import 'package:ekush_ponji/features/home/widgets/daily_quote_widget.dart';
import 'package:ekush_ponji/features/home/widgets/daily_word_widget.dart';
import 'package:ekush_ponji/features/quotes/quotes_viewmodel.dart';
import 'package:ekush_ponji/features/words/words_viewmodel.dart';

class HomeScreen extends BaseScreen {
  const HomeScreen({super.key});

  @override
  BaseScreenState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseScreenState<HomeScreen> {
  @override
  NotifierProvider<HomeViewModel, ViewState> get viewModelProvider =>
      homeViewModelProvider;

  @override
  bool get useSafeArea => false;

  @override
  bool get resizeToAvoidBottomInset => true;

  @override
  bool get enablePullToRefresh => true;

  @override
  bool get showLoadingOverlay => false;

  @override
  Future<void> onRefresh() async {
    await ref.read(homeViewModelProvider.notifier).refresh();
  }

  @override
  void onRetry() {
    ref.read(homeViewModelProvider.notifier).loadHomeData();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return const AppHeader();
  }

  @override
  Widget? buildDrawer(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(homeViewModelProvider.notifier).userName;
    return AppDrawer(userName: userName);
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(homeViewModelProvider);

    if (viewState is ViewStateLoading && !viewState.isRefreshing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewState is ViewStateError) {
      return buildErrorWidget(viewState);
    }

    final viewModel = ref.watch(homeViewModelProvider.notifier);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppGreeter(),
              const SizedBox(height: 8),
              const TodayDateWidget(),
              const SizedBox(height: 8),

              // Holidays → Calendar screen
              InkWell(
                onTap: () => context.goNamed('calendar'),
                borderRadius: BorderRadius.circular(12),
                child: HomeHolidaysWidget(
                  holidays: viewModel.holidays,
                ),
              ),
              const SizedBox(height: 8),

              // Events → Events list screen
              InkWell(
                onTap: () => context.goNamed('eventsList'),
                borderRadius: BorderRadius.circular(12),
                child: UpcomingEventsWidget(
                  events: viewModel.events,
                ),
              ),
              const SizedBox(height: 8),

              // Daily Quote → Quotes screen
              // Uses pushNamed so the back button and swipe-back work correctly
              InkWell(
                onTap: () {
                  final quotesVm = ref.read(quotesViewModelProvider.notifier);
                  final dailyQuote = quotesVm.dailyQuote;
                  final allQuotes = quotesVm.allQuotes;
                  final index = (dailyQuote != null && allQuotes.isNotEmpty)
                      ? allQuotes
                          .indexOf(dailyQuote)
                          .clamp(0, allQuotes.length - 1)
                      : 0;
                  context.pushNamed('quotes', extra: index);
                },
                borderRadius: BorderRadius.circular(12),
                child: const DailyQuoteWidget(),
              ),
              const SizedBox(height: 8),

              // Daily Word → Words screen
              // Uses pushNamed so the back button and swipe-back work correctly
              InkWell(
                onTap: () {
                  final wordsVm = ref.read(wordsViewModelProvider.notifier);
                  final dailyWord = wordsVm.dailyWord;
                  final allWords = wordsVm.allWords;
                  final index = (dailyWord != null && allWords.isNotEmpty)
                      ? allWords
                          .indexOf(dailyWord)
                          .clamp(0, allWords.length - 1)
                      : 0;
                  context.pushNamed('words', extra: index);
                },
                borderRadius: BorderRadius.circular(12),
                child: const DailyWordWidget(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        // Reserved for ad banner
      ],
    );
  }
}