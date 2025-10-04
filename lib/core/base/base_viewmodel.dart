import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/view_state.dart';

/// Base ViewModel class using Riverpod's Notifier pattern
/// All ViewModels should extend this class
/// Provides automatic state management and lifecycle handling
abstract class BaseViewModel<T> extends Notifier<ViewState> {
  @override
  ViewState build() {
    // Call onInit when the notifier is first created
    ref.onDispose(() {
      onDispose();
    });

    // Defer onInit to avoid modifying state during build
    Future.microtask(() => onInit());

    return const ViewStateInitial();
  }

  /// Current view state (convenience getter)
  ViewState get viewState => state;

  /// Check if currently loading
  bool get isLoading => state is ViewStateLoading;

  /// Check if there's an error
  bool get hasError => state is ViewStateError;

  /// Check if state is initial
  bool get isInitial => state is ViewStateInitial;

  /// Check if state is success
  bool get isSuccess => state is ViewStateSuccess;

  /// Check if state is empty
  bool get isEmpty => state is ViewStateEmpty;

  /// Update the current state
  void setState(ViewState newState) {
    state = newState;
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
      message,
      error: error,
      stackTrace: stackTrace,
      message: '',
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
  void handleError(
    dynamic error,
    StackTrace stackTrace, {
    String? customMessage,
  }) {
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
}
