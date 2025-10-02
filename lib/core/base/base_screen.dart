import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/view_state.dart';

/// A reusable base screen for all app screens.
/// Provides:
/// - Automatic ViewState handling (loading, error, success)
/// - Common Scaffold structure
/// - Hooks for AppBar, FAB, Drawer, BottomNav
/// - SafeArea and inset controls
/// - Automatic snackbar notifications
abstract class BaseScreen extends ConsumerStatefulWidget {
  const BaseScreen({super.key});

  @override
  BaseScreenState createState();
}

abstract class BaseScreenState<T extends BaseScreen> extends ConsumerState<T> {
  /// Get the ViewState provider for this screen
  /// Override this to connect to your specific ViewModel
  NotifierProvider<dynamic, ViewState>? get viewModelProvider => null;

  /// Build the main body of the screen
  Widget buildBody(BuildContext context, WidgetRef ref);

  /// --- Optional UI slots ---
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) => null;
  Widget? buildFloatingActionButton(BuildContext context, WidgetRef ref) =>
      null;
  Widget? buildBottomNavigationBar(BuildContext context, WidgetRef ref) => null;
  Widget? buildDrawer(BuildContext context, WidgetRef ref) => null;

  /// --- Configurations ---
  bool get useSafeArea => true;
  bool get resizeToAvoidBottomInset => true;
  Color? get backgroundColor => null;
  bool get showLoadingOverlay => true;
  bool get autoHandleSuccess => true;
  bool get autoHandleError => true;

  /// --- Custom UI Builders ---
  Widget buildLoadingWidget() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// --- Helpers ---
  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Called when ViewState changes to Success
  /// Override to add custom behavior
  void onSuccess(ViewStateSuccess state) {
    if (autoHandleSuccess && state.message != null) {
      showSuccess(state.message!);
    }
  }

  /// Called when ViewState changes to Error
  /// Override to add custom behavior
  void onError(ViewStateError state) {
    if (autoHandleError) {
      showError(state.message);
    }
  }

  /// Called when ViewState changes to Empty
  /// Override to add custom behavior
  void onEmpty(ViewStateEmpty state) {}

  ViewState? _previousState;

  @override
  Widget build(BuildContext context) {
    // Listen to ViewState changes if provider is set
    final viewState = viewModelProvider != null
        ? ref.watch(viewModelProvider!)
        : const ViewStateInitial();

    // Handle state changes automatically
    if (viewModelProvider != null) {
      ref.listen<ViewState>(
        viewModelProvider!,
        (previous, next) {
          // Avoid duplicate notifications
          if (_previousState.runtimeType == next.runtimeType &&
              _previousState == next) {
            return;
          }

          _previousState = next;

          // Handle different states
          if (next is ViewStateSuccess) {
            onSuccess(next);
          } else if (next is ViewStateError) {
            onError(next);
          } else if (next is ViewStateEmpty) {
            onEmpty(next);
          }
        },
      );
    }

    final isLoading = viewState is ViewStateLoading;

    return Scaffold(
      appBar: buildAppBar(context, ref),
      body: Stack(
        children: [
          useSafeArea
              ? SafeArea(child: buildBody(context, ref))
              : buildBody(context, ref),
          if (showLoadingOverlay && isLoading) buildLoadingWidget(),
        ],
      ),
      floatingActionButton: buildFloatingActionButton(context, ref),
      bottomNavigationBar: buildBottomNavigationBar(context, ref),
      drawer: buildDrawer(context, ref),
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}
