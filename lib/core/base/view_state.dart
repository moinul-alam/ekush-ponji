import 'package:flutter/foundation.dart';

/// Base class for view states in MVVM architecture
@immutable
abstract class ViewState {
  const ViewState();
}

/// Initial state when screen is first loaded
class ViewStateInitial extends ViewState {
  const ViewStateInitial();
}

/// State when data is being loaded
class ViewStateLoading extends ViewState {
  final String? message;

  const ViewStateLoading([this.message]);
}

/// State when data is successfully loaded
class ViewStateSuccess<T> extends ViewState {
  final T? data;
  final String? message;

  const ViewStateSuccess({this.data, this.message});
}

/// State when an error occurs
class ViewStateError extends ViewState {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  const ViewStateError({
    required this.message,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() => 'ViewStateError(message: $message, error: $error)';
}

/// State when no data is available (empty state)
class ViewStateEmpty extends ViewState {
  final String? message;

  const ViewStateEmpty([this.message]);
}