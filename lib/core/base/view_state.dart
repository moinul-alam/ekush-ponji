// lib/core/base/view_state.dart

import 'package:flutter/foundation.dart';

/// Base class for all view states
@immutable
sealed class ViewState {
  const ViewState();
}

/// Initial state when screen is first loaded
final class ViewStateInitial extends ViewState {
  const ViewStateInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewStateInitial && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Loading state with optional message and progress
final class ViewStateLoading extends ViewState {
  final String? message;
  final double? progress;
  final bool isRefreshing;

  const ViewStateLoading([
    this.message,
    this.progress,
    this.isRefreshing = false,
  ]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewStateLoading &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          progress == other.progress &&
          isRefreshing == other.isRefreshing;

  @override
  int get hashCode => Object.hash(runtimeType, message, progress, isRefreshing);
}

/// Success state with optional data and message.
/// Uses [timestamp] in equality so every new ViewStateSuccess()
/// is always unequal to the previous one — Riverpod will always
/// notify listeners and trigger rebuilds.
final class ViewStateSuccess<T> extends ViewState {
  final T? data;
  final String? message;
  final DateTime timestamp;

  ViewStateSuccess({
    this.data,
    this.message,
  }) : timestamp = DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewStateSuccess &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          message == other.message &&
          // Include timestamp — guarantees every new instance is distinct
          // so Riverpod always fires a rebuild when state is set to success.
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(runtimeType, data, message, timestamp);
}

/// Error state with detailed error information
final class ViewStateError extends ViewState {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;
  final ErrorSeverity severity;
  final bool isRetryable;

  const ViewStateError(
    this.message, {
    this.error,
    this.stackTrace,
    this.severity = ErrorSeverity.error,
    this.isRetryable = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewStateError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          error == other.error &&
          severity == other.severity;

  @override
  int get hashCode => Object.hash(runtimeType, message, error, severity);
}

/// Empty state when data exists but is empty (e.g., empty list)
final class ViewStateEmpty extends ViewState {
  final String? message;
  final String? actionLabel;

  const ViewStateEmpty([this.message, this.actionLabel]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewStateEmpty &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          actionLabel == other.actionLabel;

  @override
  int get hashCode => Object.hash(runtimeType, message, actionLabel);
}

/// Enum for error severity levels
enum ErrorSeverity {
  warning,
  error,
  critical,
}