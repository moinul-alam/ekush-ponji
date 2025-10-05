// lib/features/calculator/calculator_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/features/calculator/calculator_viewmodel.dart';
import 'package:ekush_ponji/features/calculator/widgets/date_input_field.dart';
import 'package:ekush_ponji/features/calculator/widgets/result_card.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';

/// Date Duration Calculator Screen
/// Calculates duration between two dates with multiple format outputs
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
          _buildInstructionsCard(colorScheme, theme),
          const SizedBox(height: 24),

          // From Date Input
          DateInputField(
            label: 'From Date',
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
            label: 'To Date',
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
          _buildTodayChip(viewModel, colorScheme, theme),

          const SizedBox(height: 32),

          // Results Section or Empty State
          if (viewModel.calculationResult != null && viewModel.hasValidDates)
            _buildResultsSection(context, viewModel, colorScheme, theme)
          else if (viewModel.validationError == null)
            _buildEmptyState(colorScheme, theme),
        ],
      ),
    );
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text('Date Calculator'),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go(RouteNames.home),
        tooltip: 'Back to Home',
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

  // ==================== UI Builder Methods ====================

  /// Build instructions card at the top
  Widget _buildInstructionsCard(ColorScheme colorScheme, ThemeData theme) {
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
              'Select two dates to calculate the duration between them',
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
          'Today',
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
              'Calculation Results',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Years, Months, Days
        ResultCard(
          title: 'Years Months Days',
          value: result.formatYearsMonthsDays(),
          icon: Icons.calendar_month_rounded,
          onCopy: () => _copyToClipboard(
            context,
            result.formatYearsMonthsDays(),
          ),
        ),

        // Total Days
        ResultCard(
          title: 'Total Days',
          value: result.formatTotalDays(),
          icon: Icons.event_rounded,
          onCopy: () => _copyToClipboard(
            context,
            result.formatTotalDays(),
          ),
        ),

        // Weeks and Days
        ResultCard(
          title: 'Weeks and Days',
          value: result.formatWeeksAndDays(),
          icon: Icons.date_range_rounded,
          onCopy: () => _copyToClipboard(
            context,
            result.formatWeeksAndDays(),
          ),
        ),

        const SizedBox(height: 16),

        // Reset Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: viewModel.resetDates,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// Build empty state when no valid dates are selected
  Widget _buildEmptyState(ColorScheme colorScheme, ThemeData theme) {
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
              'Select dates to see results',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Action Methods ====================

  /// Show Material date picker dialog
  Future<void> _showDatePicker(
    BuildContext context,
    WidgetRef ref, {
    required bool isFromDate,
  }) async {
    final viewModel = ref.read(calculatorViewModelProvider.notifier);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (viewModel.fromDate ?? DateTime.now())
          : (viewModel.toDate ?? DateTime.now()),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: isFromDate ? 'Select From Date' : 'Select To Date',
    );

    if (selectedDate != null && context.mounted) {
      if (isFromDate) {
        viewModel.setFromDate(selectedDate);
      } else {
        viewModel.setToDate(selectedDate);
      }
    }
  }

  /// Copy text to clipboard and show confirmation
  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Flexible(child: Text('Copied: $text')),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}