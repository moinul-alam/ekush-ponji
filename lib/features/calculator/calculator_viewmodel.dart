// lib/features/calculator/calculator_viewmodel.dart

import 'package:ekush_ponji/core/base/base_viewmodel.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/features/calculator/models/date_calculation_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ViewModel for Date Duration Calculator
/// Handles date selection, validation, and calculation logic
class CalculatorViewModel extends BaseViewModel<ViewState> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _validationError;

  // Getters
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  String? get validationError => _validationError;
  
  // Get calculation result from state.data
  DateCalculationResult? get calculationResult {
    final currentState = state;
    if (currentState is ViewStateSuccess<DateCalculationResult>) {
      return currentState.data;
    }
    return null;
  }
  
  bool get hasValidDates =>
      _fromDate != null && _toDate != null && _validationError == null;

  @override
  void onInit() {
    super.onInit();
    // Initialize with empty success state
    state = ViewStateSuccess<DateCalculationResult>();
  }

  /// Set from date and trigger recalculation
  void setFromDate(DateTime date) {
    _fromDate = date;
    _validateAndCalculate();
  }

  /// Set to date and trigger recalculation
  void setToDate(DateTime date) {
    _toDate = date;
    _validateAndCalculate();
  }

  /// Quick action: Set to date as today
  void setToDateAsToday() {
    _toDate = DateTime.now();
    _validateAndCalculate();
  }

  /// Clear from date and reset calculation
  void clearFromDate() {
    _fromDate = null;
    _resetCalculation();
  }

  /// Clear to date and reset calculation
  void clearToDate() {
    _toDate = null;
    _resetCalculation();
  }

  /// Reset all dates to initial state
  void resetDates() {
    _fromDate = null;
    _toDate = null;
    _resetCalculation();
  }

  /// Helper to reset calculation state
  void _resetCalculation() {
    _validationError = null;
    state = ViewStateSuccess<DateCalculationResult>();
  }

  /// Validate dates and calculate duration if valid
  void _validateAndCalculate() {
    _validationError = null;

    // Both dates must be selected for calculation
    if (_fromDate == null || _toDate == null) {
      state = ViewStateSuccess<DateCalculationResult>();
      return;
    }

    // Validate: From date must not be after To date
    if (_fromDate!.isAfter(_toDate!)) {
      _validationError = 'From date cannot be after To date';
      state = ViewStateError(_validationError!);
      return;
    }

    // Perform calculation and store in state
    final result = _calculateDuration();
    state = ViewStateSuccess<DateCalculationResult>(data: result);
  }

  /// Calculate duration between two dates
  /// Returns years, months, days, total days, and weeks
  DateCalculationResult _calculateDuration() {
    // Normalize to midnight for accurate day calculation
    final from = _normalizeDate(_fromDate!);
    final to = _normalizeDate(_toDate!);

    // Calculate year-month-day breakdown
    int years = to.year - from.year;
    int months = to.month - from.month;
    int days = to.day - from.day;

    // Adjust for negative days (borrow from previous month)
    if (days < 0) {
      months--;
      final daysInPreviousMonth = DateTime(to.year, to.month, 0).day;
      days += daysInPreviousMonth;
    }

    // Adjust for negative months (borrow from previous year)
    if (months < 0) {
      years--;
      months += 12;
    }

    // Calculate alternative representations
    final totalDays = to.difference(from).inDays;
    final weeks = totalDays ~/ 7;
    final remainingDays = totalDays % 7;

    return DateCalculationResult(
      years: years,
      months: months,
      days: days,
      totalDays: totalDays,
      weeks: weeks,
      remainingDays: remainingDays,
    );
  }

  /// Normalize date to midnight (00:00:00)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

/// Provider for CalculatorViewModel
final calculatorViewModelProvider =
    NotifierProvider<CalculatorViewModel, ViewState>(
  () => CalculatorViewModel(),
);