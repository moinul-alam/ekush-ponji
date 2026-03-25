// lib/features/holidays/holidays_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_provider.dart';
import 'package:ekush_ponji/core/widgets/ads/native_ad_widget.dart';
import 'package:ekush_ponji/core/widgets/loading/app_loading_spinner.dart';
import 'package:ekush_ponji/features/holidays/models/holiday.dart';
import 'package:ekush_ponji/features/holidays/holidays_viewmodel.dart';
import 'package:ekush_ponji/features/holidays/widgets/holiday_gazette_section_widget.dart';
import 'package:ekush_ponji/features/holidays/widgets/holiday_month_section_widget.dart';
import 'package:ekush_ponji/features/holidays/widgets/holiday_type_legend_widget.dart';
import 'package:ekush_ponji/features/holidays/providers/holiday_notification_provider.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';

class HolidaysScreen extends BaseScreen {
  const HolidaysScreen({super.key});

  @override
  BaseScreenState<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends BaseScreenState<HolidaysScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(notificationPermissionProvider.notifier).refresh();
    }
  }

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
    final l10n = AppLocalizations.of(context);
    vm.loadHolidaysForYear(vm.selectedYear, l10n);
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final vm = ref.watch(holidaysViewModelProvider.notifier);

    final notifPrefs = ref.watch(holidayNotificationProvider);
    final osGranted = ref.watch(notificationPermissionProvider).value ?? false;
    final notifEffective = notifPrefs.enabled && osGranted;

    final canPop = Navigator.of(context).canPop();

    return AppBar(
      title: AppHeader.title(context, l10n.allHolidays),
      centerTitle: true,
      leading: canPop
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go(RouteNames.home),
            ),
      actions: [
        IconButton(
          tooltip:
              notifEffective ? l10n.notificationsOn : l10n.notificationsOff,
          icon: Icon(
            notifEffective
                ? Icons.notifications_active_outlined
                : Icons.notifications_off_outlined,
            color: notifEffective
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          onPressed: () =>
              _showNotificationDialog(context, ref, l10n, osGranted),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: _YearNavigatorBar(
          year: vm.selectedYear,
          onPrevious: () => vm.goToPreviousYear(l10n),
          onNext: () => vm.goToNextYear(l10n),
          l10n: l10n,
        ),
      ),
    );
  }

  void _showNotificationDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    bool osGranted,
  ) {
    final currentlyEnabled = ref.read(holidayNotificationProvider).enabled;

    if (!osGranted) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.notificationPermissionTitle),
          content: Text(l10n.notificationPermissionMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await openAppSettings();
              },
              child: Text(l10n.openSettings),
            ),
          ],
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.holidayNotificationsTitle),
        content: Text(
          currentlyEnabled
              ? l10n.holidayNotifOnMessage
              : l10n.holidayNotifOffMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final holidays =
                  ref.read(holidaysViewModelProvider.notifier).holidays;
              await ref.read(holidayNotificationProvider.notifier).setEnabled(
                    !currentlyEnabled,
                    holidays: holidays,
                    languageCode: l10n.languageCode,
                  );
            },
            child: Text(currentlyEnabled ? l10n.turnOff : l10n.turnOn),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(holidaysViewModelProvider);
    final vm = ref.watch(holidaysViewModelProvider.notifier);
    final l10n = AppLocalizations.of(context);

    if (viewState is ViewStateLoading && !viewState.isRefreshing) {
      return const Center(child: AppLoadingSpinner(size: 34, strokeWidth: 3.2));
    }
    if (viewState is ViewStateError) return buildErrorWidget(viewState);
    if (vm.holidays.isEmpty) {
      return buildEmptyWidget(ViewStateEmpty(l10n.noHolidaysForYear));
    }

    return Column(
      children: [
        _ControlsBar(
          viewMode: vm.viewMode,
          isSyncing: vm.isSyncing,
          onSync: () => vm.syncHolidays(l10n),
          onToggleView: () => vm.toggleViewMode(),
          l10n: l10n,
        ),
        Expanded(
          child: vm.viewMode == HolidaysViewMode.gazetteType
              ? _GazetteTypeView(grouped: vm.groupedByGazetteType)
              : _MonthWiseView(
                  grouped: vm.groupedByMonth,
                  year: vm.selectedYear,
                ),
        ),
        const HolidayTypeLegendWidget(),
      ],
    );
  }
}

// ── Year navigator bar ────────────────────────────────────────

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
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
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
                foregroundColor: theme.colorScheme.primary),
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
                foregroundColor: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

// ── Controls bar ──────────────────────────────────────────────

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
    final isMonthWise = viewMode == HolidaysViewMode.monthWise;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
            bottom: BorderSide(color: colorScheme.outlineVariant, width: 1)),
      ),
      child: Row(
        children: [
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
                        strokeWidth: 2, color: colorScheme.primary),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sync_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(l10n.sync, style: theme.textTheme.labelMedium),
                    ],
                  ),
          ),
          const Spacer(),
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
                  isMonthWise ? l10n.byHolidayTypes : l10n.byMonth,
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

// ── Gazette type view — native ad between 2nd and 3rd section ─

class _GazetteTypeView extends StatelessWidget {
  final Map<GazetteType, List<Holiday>> grouped;
  const _GazetteTypeView({required this.grouped});

  @override
  Widget build(BuildContext context) {
    final entries = grouped.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Column(
          children: [
            HolidayGazetteSectionWidget(
              gazetteType: entry.key,
              holidays: entry.value,
            ),
            // Native ad as section separator after the 3rd gazette section.
            if (index == 2) const NativeAdWidget(style: NativeAdStyle.section),
          ],
        );
      },
    );
  }
}

// ── Month wise view — native ad after 3rd month section ───────

class _MonthWiseView extends StatefulWidget {
  final Map<int, List<Holiday>> grouped;
  final int year;
  const _MonthWiseView({required this.grouped, required this.year});

  @override
  State<_MonthWiseView> createState() => _MonthWiseViewState();
}

class _MonthWiseViewState extends State<_MonthWiseView> {
  int? _expandedMonth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncDefaultExpandedMonth();
  }

  @override
  void didUpdateWidget(covariant _MonthWiseView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.year != widget.year ||
        oldWidget.grouped.length != widget.grouped.length) {
      _syncDefaultExpandedMonth();
    }
  }

  void _syncDefaultExpandedMonth() {
    if (_expandedMonth != null && widget.grouped.containsKey(_expandedMonth)) {
      return;
    }
    final now = DateTime.now();
    final currentMonthInSelectedYear =
        widget.year == now.year ? now.month : widget.grouped.keys.first;
    _expandedMonth = widget.grouped.containsKey(currentMonthInSelectedYear)
        ? currentMonthInSelectedYear
        : widget.grouped.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.grouped.entries.toList();
    final expandedIndex =
        entries.indexWhere((entry) => entry.key == _expandedMonth);
    final adAfterIndex = expandedIndex >= 0 ? expandedIndex : 2;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final month = entry.key;
        return Column(
          children: [
            HolidayMonthSectionWidget(
              month: month,
              year: widget.year,
              holidays: entry.value,
              initiallyExpanded: month == _expandedMonth,
              onExpansionChanged: (isExpanded) {
                if (isExpanded) {
                  setState(() => _expandedMonth = month);
                } else if (_expandedMonth == month) {
                  setState(() => _expandedMonth = null);
                }
              },
            ),
            // Dynamic native ad after the currently expanded month section.
            if (index == adAfterIndex && index < entries.length - 1)
              const NativeAdWidget(style: NativeAdStyle.section),
          ],
        );
      },
    );
  }
}
