// lib/features/holidays/holidays_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/features/holidays/holidays_viewmodel.dart';
import 'package:ekush_ponji/features/holidays/widgets/holiday_gazette_section_widget.dart';
import 'package:ekush_ponji/features/holidays/widgets/holiday_month_section_widget.dart';

class HolidaysScreen extends BaseScreen {
  const HolidaysScreen({super.key});

  @override
  BaseScreenState<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends BaseScreenState<HolidaysScreen> {
  @override
  NotifierProvider<dynamic, ViewState> get viewModelProvider =>
      holidaysViewModelProvider;

  @override
  bool get enablePullToRefresh => true;

  @override
  Future<void> onRefresh() async {
    await ref.read(holidaysViewModelProvider.notifier).refresh();
  }

  @override
  void onRetry() {
    final vm = ref.read(holidaysViewModelProvider.notifier);
    vm.loadHolidaysForYear(vm.selectedYear);
  }

  // ── AppBar ───────────────────────────────────────────────

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final vm = ref.watch(holidaysViewModelProvider.notifier);
    final isBn = l10n.languageCode == 'bn';

    return AppBar(
      title: Text(
        isBn ? 'সকল ছুটির দিন' : 'All Holidays',
        style: theme.textTheme.titleLarge,
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: _YearNavigatorBar(
          year: vm.selectedYear,
          onPrevious: () => vm.goToPreviousYear(),
          onNext: () => vm.goToNextYear(),
          l10n: l10n,
        ),
      ),
    );
  }

  // ── Body ─────────────────────────────────────────────────

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(holidaysViewModelProvider);
    final vm = ref.watch(holidaysViewModelProvider.notifier);
    final l10n = AppLocalizations.of(context);

    // Full-screen loading (initial load only)
    if (viewState is ViewStateLoading && !viewState.isRefreshing) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error
    if (viewState is ViewStateError) {
      return buildErrorWidget(viewState);
    }

    // Empty
    if (vm.holidays.isEmpty) {
      return buildEmptyWidget(
        ViewStateEmpty(
          l10n.languageCode == 'bn'
              ? 'এই বছরের জন্য কোনো ছুটির তথ্য পাওয়া যায়নি'
              : 'No holidays found for this year',
        ),
      );
    }

    return Column(
      children: [
        // ── Controls bar ─────────────────────────────────────
        // Sync button (left) + View mode toggle (right)
        _ControlsBar(
          viewMode: vm.viewMode,
          isSyncing: vm.isSyncing,
          onSync: () => vm.syncHolidays(),
          onToggleView: () => vm.toggleViewMode(),
          l10n: l10n,
        ),

        // ── Holiday list ─────────────────────────────────────
        Expanded(
          child: vm.viewMode == HolidaysViewMode.gazetteType
              ? _GazetteTypeView(grouped: vm.groupedByGazetteType)
              : _MonthWiseView(
                  grouped: vm.groupedByMonth,
                  year: vm.selectedYear,
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// YEAR NAVIGATOR BAR
// ─────────────────────────────────────────────────────────────

class _YearNavigatorBar extends StatelessWidget {
  final int year;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final AppLocalizations l10n;

  const _YearNavigatorBar({
    required this.year,
    required this.onPrevious,
    required this.onNext,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: l10n.previous,
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.localizeNumber(year),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: l10n.next,
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CONTROLS BAR
// Sync button left · View mode toggle right
// Sits directly below the year navigator bar
// ─────────────────────────────────────────────────────────────

class _ControlsBar extends StatelessWidget {
  final HolidaysViewMode viewMode;
  final bool isSyncing;
  final VoidCallback onSync;
  final VoidCallback onToggleView;
  final AppLocalizations l10n;

  const _ControlsBar({
    required this.viewMode,
    required this.isSyncing,
    required this.onSync,
    required this.onToggleView,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isBn = l10n.languageCode == 'bn';
    final isMonthWise = viewMode == HolidaysViewMode.monthWise;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          // ── Sync button (left) ──────────────────────────────
          FilledButton.tonal(
            onPressed: isSyncing ? null : onSync,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: isSyncing
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sync_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        isBn ? 'আপডেট' : 'Sync',
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ),
          ),

          const Spacer(),

          // ── View mode toggle (right) ────────────────────────
          FilledButton.tonal(
            onPressed: onToggleView,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isMonthWise
                      ? Icons.list_alt_rounded
                      : Icons.calendar_month_rounded,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isMonthWise
                      ? (isBn ? 'গেজেট অনুযায়ী' : 'By Gazette')
                      : (isBn ? 'মাস অনুযায়ী' : 'By Month'),
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// GAZETTE TYPE VIEW
// ─────────────────────────────────────────────────────────────

class _GazetteTypeView extends StatelessWidget {
  final Map<GazetteType, List<Holiday>> grouped;
  const _GazetteTypeView({required this.grouped});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        return HolidayGazetteSectionWidget(
          gazetteType: entry.key,
          holidays: entry.value,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MONTH WISE VIEW
// ─────────────────────────────────────────────────────────────

class _MonthWiseView extends StatelessWidget {
  final Map<int, List<Holiday>> grouped;
  final int year;
  const _MonthWiseView({required this.grouped, required this.year});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        final month = entry.key;
        return HolidayMonthSectionWidget(
          month: month,
          year: year,
          holidays: entry.value,
          initiallyExpanded: month == now.month && year == now.year,
        );
      },
    );
  }
}