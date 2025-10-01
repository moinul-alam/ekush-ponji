import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base screen widget that all screens can extend
/// Provides common UI patterns and state handling for Riverpod 3.x
abstract class BaseScreen extends ConsumerWidget {
  const BaseScreen({super.key});

  /// Build the main body of the screen
  Widget buildBody(BuildContext context, WidgetRef ref);

  /// Optional: Custom AppBar
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return null;
  }

  /// Optional: Floating Action Button
  Widget? buildFloatingActionButton(BuildContext context, WidgetRef ref) {
    return null;
  }

  /// Optional: Bottom Navigation Bar
  Widget? buildBottomNavigationBar(BuildContext context, WidgetRef ref) {
    return null;
  }

  /// Optional: Drawer
  Widget? buildDrawer(BuildContext context, WidgetRef ref) {
    return null;
  }

  /// Whether to wrap body in SafeArea
  bool get useSafeArea => true;

  /// Whether to resize to avoid bottom inset (keyboard)
  bool get resizeToAvoidBottomInset => true;

  /// Background color
  Color? get backgroundColor => null;

  /// Called when state changes to error
  void onError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Called when state changes to success with a message
  void onSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: buildAppBar(context, ref),
      body: useSafeArea
          ? SafeArea(
              child: buildBody(context, ref),
            )
          : buildBody(context, ref),
      floatingActionButton: buildFloatingActionButton(context, ref),
      bottomNavigationBar: buildBottomNavigationBar(context, ref),
      drawer: buildDrawer(context, ref),
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

/// Base screen with loading state support
/// Use this for screens that need to show loading overlays
abstract class BaseScreenWithLoading extends ConsumerWidget {
  const BaseScreenWithLoading({super.key});

  /// Build the main body of the screen
  Widget buildBody(BuildContext context, WidgetRef ref);

  /// Get the loading state - override this to watch your specific provider
  bool isLoading(WidgetRef ref);

  /// Optional: Custom AppBar
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return null;
  }

  /// Optional: Floating Action Button
  Widget? buildFloatingActionButton(BuildContext context, WidgetRef ref) {
    return null;
  }

  /// Optional: Bottom Navigation Bar
  Widget? buildBottomNavigationBar(BuildContext context, WidgetRef ref) {
    return null;
  }

  /// Optional: Drawer
  Widget? buildDrawer(BuildContext context, WidgetRef ref) {
    return null;
  }

  /// Whether to show loading overlay when state is loading
  bool get showLoadingOverlay => true;

  /// Whether to wrap body in SafeArea
  bool get useSafeArea => true;

  /// Whether to resize to avoid bottom inset (keyboard)
  bool get resizeToAvoidBottomInset => true;

  /// Background color
  Color? get backgroundColor => null;

  /// Custom loading widget
  Widget buildLoadingWidget() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = isLoading(ref);

    return Scaffold(
      appBar: buildAppBar(context, ref),
      body: Stack(
        children: [
          // Main body
          useSafeArea
              ? SafeArea(
                  child: buildBody(context, ref),
                )
              : buildBody(context, ref),

          // Loading overlay
          if (showLoadingOverlay && loading) buildLoadingWidget(),
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