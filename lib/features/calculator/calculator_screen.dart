import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/base_screen.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/features/calculator/calculator_viewmodel.dart';
import 'package:ekush_ponji/features/calculator/widgets/date_input_field.dart';
import 'package:ekush_ponji/features/calculator/widgets/result_card.dart';
import 'package:ekush_ponji/core/widgets/navigation/app_bottom_nav.dart';
import 'package:go_router/go_router.dart';
import 'package:ekush_ponji/app/router/route_names.dart';

/// Date Duration Calculator Screen
/// Calculates duration between two dates
class CalculatorScreen extends BaseScreen {
  const CalculatorScreen({super.key});

  @override
  BaseScreenState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends BaseScreenState<CalculatorScreen> {
  @override
  NotifierProvider<dynamic, ViewState>? get viewModelProvider =>
      calculatorViewModelProvider;

  @override
  bool get showLoadingOverlay => false;

  @override
  bool get autoHandleError => false; // Handle errors manually for validation

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(calculatorViewModelProvider.notifier);
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Watch for changes
    ref.watch(calculatorViewModelProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructions
          Container(
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
          ),

          const SizedBox(height: 24),

          // From Date Input
          DateInputField(
            label: 'From Date',
            selectedDate: viewModel.fromDate,
            onTap: () => _showDatePicker(context, ref, isFromDate: true),
            onClear: () => viewModel.clearFromDate(),
            hasError: viewModel.validationError != null,
          ),

          const SizedBox(height: 20),

          // To Date Input with Today chip
          DateInputField(
            label: 'To Date',
            selectedDate: viewModel.toDate,
            onTap: () => _showDatePicker(context, ref, isFromDate: false),
            onClear: () => viewModel.clearToDate(),
            hasError: viewModel.validationError != null,
            errorText: viewModel.validationError,
          ),

          // Today chip for To Date
          const SizedBox(height: 12),
          Align(
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
              onPressed: () {
                viewModel.setToDateAsToday();
              },
              backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
              side: BorderSide(
                color: colorScheme.primary.withOpacity(0.3),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Results Section
          if (viewModel.hasValidDates &&
              viewModel.calculationResult != null) ...[
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

            // Years, Months, Days Result
            ResultCard(
              title: 'Years Months Days',
              value: viewModel.calculationResult!.formatYearsMonthsDays(),
              icon: Icons.calendar_month_rounded,
              onCopy: () => _copyToClipboard(
                context,
                viewModel.calculationResult!.formatYearsMonthsDays(),
              ),
            ),

            // Total Days Result
            ResultCard(
              title: 'Total Days',
              value: viewModel.calculationResult!.formatTotalDays(),
              icon: Icons.event_rounded,
              onCopy: () => _copyToClipboard(
                context,
                viewModel.calculationResult!.formatTotalDays(),
              ),
            ),

            // Weeks and Days Result
            ResultCard(
              title: 'Weeks and Days',
              value: viewModel.calculationResult!.formatWeeksAndDays(),
              icon: Icons.date_range_rounded,
              onCopy: () => _copyToClipboard(
                context,
                viewModel.calculationResult!.formatWeeksAndDays(),
              ),
            ),

            const SizedBox(height: 16),

            // Reset button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => viewModel.resetDates(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],

          // Empty state
          if (!viewModel.hasValidDates &&
              viewModel.validationError == null) ...[
            const SizedBox(height: 32),
            Center(
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
          ],
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
      ),
    );
  }

  // ✅ ADD THIS METHOD
  @override
  Widget? buildBottomNavigationBar(BuildContext context, WidgetRef ref) {
    return const AppBottomNav(
      currentIndex: 2, // Calculator is at index 2
    );
  }

  /// Show Material date picker (Option A)
  Future<void> _showDatePicker(
    BuildContext context,
    WidgetRef ref, {
    required bool isFromDate,
  }) async {
    final viewModel = ref.read(calculatorViewModelProvider.notifier);

    // OPTION A: Material Date Picker (ACTIVE)
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

    // OPTION B: Inline Calendar Widget (COMMENTED OUT)
    // Uncomment this and comment out Option A to use inline calendar
    /*
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InlineDatePicker(
        initialDate: isFromDate
            ? (viewModel.fromDate ?? DateTime.now())
            : (viewModel.toDate ?? DateTime.now()),
        onDateSelected: (date) {
          if (isFromDate) {
            viewModel.setFromDate(date);
          } else {
            viewModel.setToDate(date);
          }
          Navigator.pop(context);
        },
      ),
    );
    */
  }

  /// Copy text to clipboard
  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Copied: $text'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void onError(ViewStateError state) {
    // Show validation error as snackbar
    if (mounted) {
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
  }
}
