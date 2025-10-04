import 'package:flutter/foundation.dart';

@immutable
abstract class ViewState {
  const ViewState();
}

class ViewStateInitial extends ViewState {
  const ViewStateInitial();
}

class ViewStateLoading extends ViewState {
  final String? message;
  const ViewStateLoading([this.message]);
}

class ViewStateSuccess extends ViewState {
  final dynamic data;
  final String? message;
  const ViewStateSuccess({this.data, this.message});
}

class ViewStateError extends ViewState {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;
  
  const ViewStateError(String s, {
    required this.message,
    this.error,
    this.stackTrace,
  });
}

class ViewStateEmpty extends ViewState {
  final String? message;
  const ViewStateEmpty([this.message]);
}