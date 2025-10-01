import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'view_state.dart';

/// Base ViewModel class that all ViewModels should extend
/// Provides common functionality for state management and lifecycle
abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = const ViewStateInitial();

  /// Current view state
  ViewState get state => _state;

  /// Check if currently loading
  bool get isLoading => _state is ViewStateLoading;

  /// Check if there's an error
  bool get hasError => _state is ViewStateError;

  /// Check if state is initial
  bool get isInitial => _state is ViewStateInitial;

  /// Update the current state and notify listeners
  void setState(ViewState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Set loading state
  void setLoading([String? message]) {
    setState(ViewStateLoading(message));
  }

  /// Set success state
  void setSuccess({dynamic data, String? message}) {
    setState(ViewStateSuccess(data: data, message: message));
  }

  /// Set error state
  void setError(String message, {dynamic error, StackTrace? stackTrace}) {
    setState(ViewStateError(
      message: message,
      error: error,
      stackTrace: stackTrace,
    ));
  }

  /// Set empty state
  void setEmpty([String? message]) {
    setState(ViewStateEmpty(message));
  }

  /// Reset to initial state
  void resetState() {
    setState(const ViewStateInitial());
  }

  /// Handle errors in a standardized way
  void handleError(dynamic error, StackTrace stackTrace, {String? customMessage}) {
    debugPrint('Error in ${runtimeType}: $error');
    debugPrint('StackTrace: $stackTrace');
    
    final errorMessage = customMessage ?? _getErrorMessage(error);
    setError(errorMessage, error: error, stackTrace: stackTrace);
  }

  /// Extract user-friendly error message from exception
  String _getErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';
    
    // Add custom error message extraction logic here
    // For example: Firebase errors, Dio errors, etc.
    return error.toString();
  }

  /// Called when ViewModel is initialized
  /// Override this to perform initialization tasks
  void onInit() {}

  /// Called when ViewModel is disposed
  /// Override this to perform cleanup tasks
  void onDispose() {}

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }
}