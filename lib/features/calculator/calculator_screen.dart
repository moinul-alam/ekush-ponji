// lib/features/calculator/calculator_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/calculator/calculator_viewmodel.dart';
import 'package:ekush_ponji/features/calculator/widgets/date_input_field.dart';
import 'package:ekush_ponji/features/calculator/widgets/result_card.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';

/// Date Duration Calculator Screen
/// Calculates duration between two dates with multiple format outputs
/// Now fully localized with Bengali and English support
class CalculatorScreen extends BaseScreen {
  const CalculatorScreen({super.key});

  @override
  BaseScreenState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends BaseScreenState<CalculatorScreen> {
  // GlobalKey to access To Date widget's state for focus control
  final GlobalKey<DateInputFieldState> _toDateKey = GlobalKey<DateInputFieldState>();

  @override
  NotifierProvider<dynamic, ViewState>? get viewModelProvider =>
      calculatorViewModelProvider;

  @override
  bool get showLoadingOverlay => false;

  @override
  bool get autoHandleError => false; // Manual error handling for validation

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final viewModel = ref.read(calculatorViewModelProvider.notifier);
    // ignore: unused_local_variable
    final state = ref.watch(calculatorViewModelProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructions Card
          _buildInstructionsCard(l10n, colorScheme, theme),
          const SizedBox(height: 24),

          // From Date Input
          DateInputField(
            label: l10n.fromDate, // "শুরুর তারিখ" or "From Date"
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

          // To Date Input (with GlobalKey attached)
          DateInputField(
            key: _toDateKey,
            label: l10n.toDate, // "শেষ তারিখ" or "To Date"
            selectedDate: viewModel.toDate,
            onTap: () => _showDatePicker(context, ref, isFromDate: false),
            onClear: viewModel.clearToDate,
            hasError: viewModel.validationError != null,
            errorText: viewModel.validationError,
            onDateChanged: (date) {
              if (date != null) viewModel.setToDate(date);
            },
          ),

          // Today Shortcut Chip
          const SizedBox(height: 12),
          _buildTodayChip(l10n, viewModel, colorScheme, theme),

          const SizedBox(height: 32),

          // Results Section or Empty State
          if (viewModel.calculationResult != null && viewModel.hasValidDates)
            _buildResultsSection(context, l10n, viewModel, colorScheme, theme)
          else if (viewModel.validationError == null)
            _buildEmptyState(l10n, colorScheme, theme),
        ],
      ),
    );
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    
    return AppBar(
      title: Text(l10n.calculatorTitle), // "তারিখ ক্যালকুলেটর" or "Date Calculator"
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go(RouteNames.home),
        tooltip: l10n.back, // "পিছনে" or "Back"
      ),
    );
  }

  @override
  void onError(ViewStateError state) {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);

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

  // ==================== UI Builder Methods ====================

  /// Build instructions card at the top
  Widget _buildInstructionsCard(
    AppLocalizations l10n,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.selectDatesToSeeResults, // "ফলাফল দেখতে তারিখ নির্বাচন করুন"
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build "Today" shortcut chip for To Date
  Widget _buildTodayChip(
    AppLocalizations l10n,
    CalculatorViewModel viewModel,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ActionChip(
        avatar: Icon(
          Icons.today_rounded,
          size: 18,
          color: colorScheme.primary,
        ),
        label: Text(
          l10n.today, // "আজ" or "Today"
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: viewModel.setToDateAsToday,
        backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
        side: BorderSide(
          color: colorScheme.primary.withOpacity(0.3),
        ),
      ),
    );
  }

  /// Build results section with all calculation outputs
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
        // Section Header
        Row(
          children: [
            Icon(
              Icons.calculate_rounded,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.calculationResults, // "গণনার ফলাফল" or "Calculation Results"
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Years, Months, Days
        ResultCard(
          title: l10n.yearsMonthsDays, // "বছর মাস দিন" or "Years Months Days"
          value: _formatYearsMonthsDays(l10n, result),
          icon: Icons.calendar_month_rounded,
          onCopy: () => _copyToClipboard(
            context,
            l10n,
            _formatYearsMonthsDays(l10n, result),
          ),
        ),

        // Total Days
        ResultCard(
          title: l10n.totalDays, // "মোট দিন" or "Total Days"
          value: _formatTotalDays(l10n, result),
          icon: Icons.event_rounded,
          onCopy: () => _copyToClipboard(
            context,
            l10n,
            _formatTotalDays(l10n, result),
          ),
        ),

        // Weeks and Days
        ResultCard(
          title: l10n.weeksAndDays, // "সপ্তাহ এবং দিন" or "Weeks and Days"
          value: _formatWeeksAndDays(l10n, result),
          icon: Icons.date_range_rounded,
          onCopy: () => _copyToClipboard(
            context,
            l10n,
            _formatWeeksAndDays(l10n, result),
          ),
        ),

        const SizedBox(height: 16),

        // Reset Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: viewModel.resetDates,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.reset), // "রিসেট" or "Reset"
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// Build empty state when no valid dates are selected
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
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.selectDatesToSeeResults, // "ফলাফল দেখতে তারিখ নির্বাচন করুন"
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Formatting Methods ====================

  /// Format years, months, days with localized numbers
  /// Example: "২ বছর ৫ মাস ১০ দিন" or "2 Years 5 Months 10 Days"
  String _formatYearsMonthsDays(AppLocalizations l10n, dynamic result) {
    // Assuming result has years, months, days properties
    return l10n.formatDuration(
      years: result.years ?? 0,
      months: result.months ?? 0,
      days: result.days ?? 0,
    );
  }

  /// Format total days with localized numbers
  /// Example: "৮০০" or "800"
  String _formatTotalDays(AppLocalizations l10n, dynamic result) {
    // Assuming result has totalDays property
    final totalDays = result.totalDays ?? 0;
    return l10n.localizeNumber(totalDays);
  }

  /// Format weeks and days with localized numbers
  /// Example: "১১৪ সপ্তাহ, ২ দিন" or "114 Weeks, 2 Days"
  String _formatWeeksAndDays(AppLocalizations l10n, dynamic result) {
    // Assuming result has weeks and remainingDays properties
    final weeks = result.weeks ?? 0;
    final remainingDays = result.remainingDays ?? 0;

    final weeksStr = l10n.localizeNumber(weeks);
    final daysStr = l10n.localizeNumber(remainingDays);
    
    final weeksLabel = weeks == 1 ? l10n.week : l10n.weeks;
    final daysLabel = remainingDays == 1 ? l10n.day : l10n.days;

    return '$weeksStr $weeksLabel, $daysStr $daysLabel';
  }

  // ==================== Action Methods ====================

  /// Show Material date picker dialog with localized labels
  Future<void> _showDatePicker(
    BuildContext context,
    WidgetRef ref, {
    required bool isFromDate,
  }) async {
    final l10n = AppLocalizations.of(context);
    final viewModel = ref.read(calculatorViewModelProvider.notifier);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (viewModel.fromDate ?? DateTime.now())
          : (viewModel.toDate ?? DateTime.now()),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: isFromDate 
          ? l10n.selectFromDate  // "শুরুর তারিখ নির্বাচন করুন"
          : l10n.selectToDate,   // "শেষ তারিখ নির্বাচন করুন"
    );

    if (selectedDate != null && context.mounted) {
      if (isFromDate) {
        viewModel.setFromDate(selectedDate);
      } else {
        viewModel.setToDate(selectedDate);
      }
    }
  }

  /// Copy text to clipboard and show localized confirmation
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
            Expanded(
              child: Text(
                '${l10n.copiedToClipboard}: $text', // "কপি হয়েছে: ..."
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}