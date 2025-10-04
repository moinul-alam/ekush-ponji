import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/features/calculator/models/date_calculation_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ViewModel for Date Duration Calculator
/// Handles date selection, validation, and calculation
class CalculatorViewModel extends BaseViewModel<ViewState> {
  // State variables
  DateTime? _fromDate;
  DateTime? _toDate;
  DateCalculationResult? _calculationResult;
  String? _validationError;

  // Getters
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  DateCalculationResult? get calculationResult => _calculationResult;
  String? get validationError => _validationError;
  bool get hasValidDates =>
      _fromDate != null && _toDate != null && _validationError == null;

  @override
  void onInit() {
    super.onInit();
    // Initialize with no dates selected
    setSuccess();
  }

  /// Set from date and recalculate
  void setFromDate(DateTime date) {
    _fromDate = date;
    _validateAndCalculate();
  }

  /// Set to date and recalculate
  void setToDate(DateTime date) {
    _toDate = date;
    _validateAndCalculate();
  }

  /// Set to date as today
  void setToDateAsToday() {
    _toDate = DateTime.now();
    _validateAndCalculate();
  }

  /// Clear from date
  void clearFromDate() {
    _fromDate = null;
    _calculationResult = null;
    _validationError = null;
    state = ViewStateSuccess();
  }

  /// Clear to date
  void clearToDate() {
    _toDate = null;
    _calculationResult = null;
    _validationError = null;
    state = ViewStateSuccess();
  }

  /// Reset all dates
  void resetDates() {
    _fromDate = null;
    _toDate = null;
    _calculationResult = null;
    _validationError = null;
    state = ViewStateSuccess();
  }

  /// Validate dates and calculate if valid
  void _validateAndCalculate() {
    // Clear previous error
    _validationError = null;

    // Check if both dates are selected
    if (_fromDate == null || _toDate == null) {
      _calculationResult = null;
      state = ViewStateSuccess();
      return;
    }

    // Validate: From date cannot be after To date
    if (_fromDate!.isAfter(_toDate!)) {
      _validationError = 'From date cannot be after To date';
      _calculationResult = null;
      state = ViewStateError(_validationError!, message: '');
      return;
    }

    // Calculate duration
    _calculateDuration();
    state = ViewStateSuccess();
  }

  /// Calculate duration between dates
  void _calculateDuration() {
    if (_fromDate == null || _toDate == null) return;

    // Normalize dates to midnight for accurate calculation
    final from = DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);
    final to = DateTime(_toDate!.year, _toDate!.month, _toDate!.day);

    // Calculate years, months, and days
    int years = to.year - from.year;
    int months = to.month - from.month;
    int days = to.day - from.day;

    // Adjust for negative days
    if (days < 0) {
      months--;
      final previousMonth = DateTime(to.year, to.month, 0);
      days += previousMonth.day;
    }

    // Adjust for negative months
    if (months < 0) {
      years--;
      months += 12;
    }

    // Calculate total days
    final totalDays = to.difference(from).inDays;

    // Calculate weeks and remaining days
    final weeks = totalDays ~/ 7;
    final remainingDays = totalDays % 7;

    _calculationResult = DateCalculationResult(
      years: years,
      months: months,
      days: days,
      totalDays: totalDays,
      weeks: weeks,
      remainingDays: remainingDays,
    );
  }

  /// Format date for display
  String formatDate(DateTime date) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }
}

/// Provider for CalculatorViewModel
final calculatorViewModelProvider =
    NotifierProvider<CalculatorViewModel, ViewState>(
  () => CalculatorViewModel(),
);
