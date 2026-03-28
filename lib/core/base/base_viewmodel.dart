// lib/core/base/base_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/view_state.dart';

/// Base ViewModel class using Riverpod's Notifier pattern
/// All ViewModels should extend this class
/// Provides automatic state management and lifecycle handling
abstract class BaseViewModel<T> extends Notifier<ViewState> {
  @override
  ViewState build() {
    // Setup lifecycle hooks
    ref.onDispose(() {
      _cancelPendingOperations();
      onDispose();
    });

    // Assign `late` refs / listeners synchronously so post-frame callbacks
    // (e.g. deep links, notification routes) never run async loads first.
    onSyncSetup();

    // Defer onInit to avoid modifying state during build
    Future.microtask(() => onInit());

    return const ViewStateInitial();
  }

  // Track pending operations for cancellation
  final List<Future<void> Function()> _pendingOperations = [];

  /// Current view state (convenience getter)
  ViewState get viewState => state;

  /// Check if currently loading
  bool get isLoading => state is ViewStateLoading;

  /// Check if currently refreshing
  bool get isRefreshing =>
      state is ViewStateLoading && (state as ViewStateLoading).isRefreshing;

  /// Check if there's an error
  bool get hasError => state is ViewStateError;

  /// Check if state is initial
  bool get isInitial => state is ViewStateInitial;

  /// Check if state is success
  bool get isSuccess => state is ViewStateSuccess;

  /// Check if state is empty
  bool get isEmpty => state is ViewStateEmpty;

  /// Get success data if available
  T? get successData =>
      state is ViewStateSuccess<T> ? (state as ViewStateSuccess<T>).data : null;

  /// Update the current state
  void setState(ViewState newState) {
    state = newState;
  }

  /// Set loading state
  void setLoading({
    String? message,
    double? progress,
    bool isRefreshing = false,
  }) {
    setState(ViewStateLoading(message, progress, isRefreshing));
  }

  /// Set success state
  void setSuccess({T? data, String? message}) {
    setState(ViewStateSuccess<T>(data: data, message: message));
  }

  /// Set error state
  void setError(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    ErrorSeverity severity = ErrorSeverity.error,
    bool isRetryable = true,
  }) {
    setState(ViewStateError(
      message,
      error: error,
      stackTrace: stackTrace,
      severity: severity,
      isRetryable: isRetryable,
    ));
  }

  /// Set empty state
  void setEmpty({String? message, String? actionLabel}) {
    setState(ViewStateEmpty(message, actionLabel));
  }

  /// Reset to initial state
  void resetState() {
    setState(const ViewStateInitial());
  }

  /// Execute an async operation with automatic loading/error handling
  /// Returns true if successful, false if error occurred
  Future<bool> executeAsync<R>({
    required Future<R> Function() operation,
    void Function(R result)? onSuccess,
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
    bool showLoading = true,
    bool setSuccessState = true,
    bool handleError = true,
  }) async {
    try {
      if (showLoading) {
        setLoading(message: loadingMessage);
      }

      final result = await operation();

      if (onSuccess != null) {
        onSuccess(result);
      }

      if (setSuccessState) {
        setSuccess(message: successMessage);
      }

      return true;
    } catch (error, stackTrace) {
      if (handleError) {
        this.handleError(
          error,
          stackTrace,
          customMessage: errorMessage,
        );
      }
      return false;
    }
  }

  /// Execute operation with retry capability
  Future<R?> executeWithRetry<R>({
    required Future<R> Function() operation,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;
    dynamic lastError;
    StackTrace? lastStackTrace;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
        attempts++;

        // Check if we should retry this error
        if (shouldRetry != null && !shouldRetry(error)) {
          break;
        }

        if (attempts < maxRetries) {
          debugPrint('Retry attempt $attempts/$maxRetries after error: $error');
          await Future.delayed(retryDelay);
        }
      }
    }

    // All retries failed
    handleError(lastError, lastStackTrace!,
        customMessage: 'Operation failed after $attempts attempts');
    return null;
  }

  /// Execute multiple operations in parallel
  Future<bool> executeParallel({
    required List<Future<void> Function()> operations,
    String? loadingMessage,
    String? successMessage,
    bool stopOnError = false,
  }) async {
    try {
      setLoading(message: loadingMessage);

      if (stopOnError) {
        // Execute sequentially, stop on first error
        for (final operation in operations) {
          await operation();
        }
      } else {
        // Execute all in parallel
        await Future.wait(operations.map((op) => op()));
      }

      setSuccess(message: successMessage);
      return true;
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return false;
    }
  }

  /// Handle errors in a standardized way
  void handleError(
    dynamic error,
    StackTrace stackTrace, {
    String? customMessage,
    ErrorSeverity severity = ErrorSeverity.error,
  }) {
    debugPrint('Error in $runtimeType: $error');
    debugPrint('StackTrace: $stackTrace');

    final errorMessage = customMessage ?? _getErrorMessage(error);
    setError(
      errorMessage,
      error: error,
      stackTrace: stackTrace,
      severity: severity,
    );
  }

  /// Extract user-friendly error message from exception
  String _getErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';

    // Add custom error message extraction logic here
    // For example: Firebase errors, Dio errors, Network errors, etc.
    
    // Example patterns:
    if (error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException')) {
      return 'Network connection error. Please check your internet.';
    }
    
    if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }
    
    if (error.toString().contains('FormatException')) {
      return 'Invalid data format received.';
    }

    // Default to error's message
    return error.toString();
  }

  /// Debounce function execution (useful for search, etc.)
  Future<void> debounce(
    Future<void> Function() operation, {
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    await Future.delayed(delay);
    await operation();
  }

  /// Throttle function execution
  DateTime? _lastThrottleTime;
  Future<void> throttle(
    Future<void> Function() operation, {
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    final now = DateTime.now();
    if (_lastThrottleTime == null ||
        now.difference(_lastThrottleTime!) >= duration) {
      _lastThrottleTime = now;
      await operation();
    }
  }

  /// Cancel all pending operations
  void _cancelPendingOperations() {
    _pendingOperations.clear();
  }

  /// Synchronous hook from [build] — runs before the [onInit] microtask.
  /// Override to read [ref] into `late` fields and register [ref.listen].
  void onSyncSetup() {}

  /// Called when ViewModel is initialized
  /// Override this to perform initialization tasks
  void onInit() {}

  /// Called when ViewModel is disposed
  /// Override this to perform cleanup tasks
  void onDispose() {}

  /// Refresh data - override this in child classes
  /// Returns true if refresh was successful
  Future<bool> refresh() async {
    return true;
  }

  /// Load more data for pagination - override in child classes
  Future<bool> loadMore() async {
    return true;
  }
}