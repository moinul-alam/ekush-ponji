// lib/features/calculator/calculator_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/services/ad_service.dart';
import 'package:ekush_ponji/core/widgets/ads/native_ad_widget.dart';
import 'package:ekush_ponji/core/widgets/pickers/app_date_picker.dart';
import 'package:ekush_ponji/features/calculator/calculator_viewmodel.dart';
import 'package:ekush_ponji/features/calculator/widgets/date_input_field.dart';
import 'package:ekush_ponji/features/calculator/widgets/result_card.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_header.dart';

class CalculatorScreen extends BaseScreen {
  const CalculatorScreen({super.key});

  @override
  BaseScreenState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends BaseScreenState<CalculatorScreen> {
  final GlobalKey<DateInputFieldState> _toDateKey =
      GlobalKey<DateInputFieldState>();

  bool _hadResult = false;

  @override
  NotifierProvider<dynamic, ViewState>? get viewModelProvider =>
      calculatorViewModelProvider;

  @override
  bool get showLoadingOverlay => false;

  @override
  bool get autoHandleError => false;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      title: AppHeader.title(context, l10n.calculatorTitle),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (_hadResult) {
            ref.read(adServiceProvider).showInterstitialIfAvailable(
              onClosed: () {
                if (mounted) context.go(RouteNames.home);
              },
            );
          } else {
            context.go(RouteNames.home);
          }
        },
        tooltip: l10n.back,
      ),
    );
  }

  @override
  void onError(ViewStateError state) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(state.message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isBn = l10n.languageCode == 'bn';
    final viewModel = ref.read(calculatorViewModelProvider.notifier);
    ref.watch(calculatorViewModelProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (viewModel.calculationResult != null && viewModel.hasValidDates) {
      _hadResult = true;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstructionsCard(l10n, colorScheme, theme),
          const SizedBox(height: 24),
          DateInputField(
            label: l10n.fromDate,
            subtitle:
                isBn ? 'উদাহরণ: আপনার জন্মতারিখ' : 'e.g. your date of birth',
            selectedDate: viewModel.fromDate,
            onTap: () => _showDatePicker(context, ref, isFromDate: true),
            onClear: viewModel.clearFromDate,
            hasError: viewModel.validationError != null,
            onDateChanged: (date) {
              if (date != null) viewModel.setFromDate(date);
            },
            nextDateFieldKey: _toDateKey,
          ),
          const SizedBox(height: 20),
          DateInputField(
            key: _toDateKey,
            label: l10n.toDate,
            subtitle: isBn
                ? 'যে তারিখ পর্যন্ত হিসাব করতে চান, অথবা নিচে "আজ" বাটনে ট্যাপ করুন'
                : 'The end date, or tap "Today" below',
            selectedDate: viewModel.toDate,
            onTap: () => _showDatePicker(context, ref, isFromDate: false),
            onClear: viewModel.clearToDate,
            hasError: viewModel.validationError != null,
            errorText: viewModel.validationError,
            onDateChanged: (date) {
              if (date != null) viewModel.setToDate(date);
            },
          ),
          const SizedBox(height: 12),
          _buildTodayChip(l10n, viewModel, colorScheme, theme),
          const SizedBox(height: 32),
          if (viewModel.calculationResult != null && viewModel.hasValidDates)
            _buildResultsSection(context, l10n, viewModel, colorScheme, theme)
          else if (viewModel.validationError == null)
            _buildEmptyState(l10n, colorScheme, theme),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(
    BuildContext context,
    WidgetRef ref, {
    required bool isFromDate,
  }) async {
    final l10n = AppLocalizations.of(context);
    final viewModel = ref.read(calculatorViewModelProvider.notifier);

    final initial = isFromDate
        ? (viewModel.fromDate ?? DateTime.now())
        : (viewModel.toDate ?? DateTime.now());

    final selected = await AppDatePicker.show(
      context: context,
      initial: initial,
      l10n: l10n,
    );

    if (selected != null && context.mounted) {
      if (isFromDate) {
        viewModel.setFromDate(selected);
      } else {
        viewModel.setToDate(selected);
      }
    }
  }

  Widget _buildInstructionsCard(
    AppLocalizations l10n,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.selectDatesToSeeResults,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayChip(
    AppLocalizations l10n,
    CalculatorViewModel viewModel,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ActionChip(
        avatar: Icon(Icons.today_rounded, size: 18, color: colorScheme.primary),
        label: Text(
          l10n.today,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: viewModel.setToDateAsToday,
        backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
    );
  }

  Widget _buildResultsSection(
    BuildContext context,
    AppLocalizations l10n,
    CalculatorViewModel viewModel,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final result = viewModel.calculationResult!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calculate_rounded, color: colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              l10n.calculationResults,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Card 1: Years Months Days ─────────────────────
        ResultCard(
          title: l10n.yearsMonthsDays,
          value: _formatYearsMonthsDays(l10n, result),
          icon: Icons.calendar_month_rounded,
          onCopy: () => _copyToClipboard(
              context, l10n, _formatYearsMonthsDays(l10n, result)),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: NativeAdWidget(style: NativeAdStyle.card),
        ),

        // ── Card 2: ___ Weeks ___ Days ────────────────────
        ResultCard(
          title: l10n.weeksAndDays,
          value: _formatWeeksAndDays(l10n, result),
          icon: Icons.date_range_rounded,
          onCopy: () => _copyToClipboard(
              context, l10n, _formatWeeksAndDays(l10n, result)),
        ),

        // ── Card 3: Total ___ Days ────────────────────────
        ResultCard(
          title: l10n.totalDays,
          value: _formatTotalDays(l10n, result),
          icon: Icons.event_rounded,
          onCopy: () =>
              _copyToClipboard(context, l10n, _formatTotalDays(l10n, result)),
        ),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: viewModel.resetDates,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.reset),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    AppLocalizations l10n,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.selectDatesToSeeResults,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Formatters ────────────────────────────────────────────

  String _formatYearsMonthsDays(AppLocalizations l10n, dynamic result) {
    return l10n.formatDuration(
      years: result.years ?? 0,
      months: result.months ?? 0,
      days: result.days ?? 0,
    );
  }

  /// "___ weeks ___ days" — no comma, both parts always shown
  String _formatWeeksAndDays(AppLocalizations l10n, dynamic result) {
    final weeks = result.weeks ?? 0;
    final remainingDays = result.remainingDays ?? 0;
    final weeksStr = l10n.localizeNumber(weeks);
    final daysStr = l10n.localizeNumber(remainingDays);
    final weeksLabel = weeks == 1 ? l10n.week : l10n.weeks;
    final daysLabel = remainingDays == 1 ? l10n.day : l10n.days;
    return '$weeksStr $weeksLabel $daysStr $daysLabel';
  }

  /// "___ days" — total day count with the days label
  String _formatTotalDays(AppLocalizations l10n, dynamic result) {
    final total = result.totalDays ?? 0;
    final totalStr = l10n.localizeNumber(total);
    final daysLabel = total == 1 ? l10n.day : l10n.days;
    return '$totalStr $daysLabel';
  }

  Future<void> _copyToClipboard(
    BuildContext context,
    AppLocalizations l10n,
    String text,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('${l10n.copiedToClipboard}: $text')),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
