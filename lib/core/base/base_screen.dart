// lib/core/base/base_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/base/view_state.dart';
import 'package:ekush_ponji/core/localization/app_localizations.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_dialog.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_service.dart';

abstract class BaseScreen extends ConsumerStatefulWidget {
  const BaseScreen({super.key});

  @override
  BaseScreenState createState();
}

abstract class BaseScreenState<T extends BaseScreen> extends ConsumerState<T> {
  /// Get the ViewState provider for this screen
  NotifierProvider<dynamic, ViewState>? get viewModelProvider => null;

  /// Build the main body of the screen
  Widget buildBody(BuildContext context, WidgetRef ref);

  /// --- Optional UI slots ---
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) => null;
  Widget? buildFloatingActionButton(BuildContext context, WidgetRef ref) =>
      null;
  Widget? buildBottomNavigationBar(BuildContext context, WidgetRef ref) => null;
  Widget? buildDrawer(BuildContext context, WidgetRef ref) => null;
  Widget? buildEndDrawer(BuildContext context, WidgetRef ref) => null;
  Widget? buildBottomSheet(BuildContext context, WidgetRef ref) => null;

  /// --- Configurations ---
  bool get useSafeArea => true;
  bool get resizeToAvoidBottomInset => true;
  Color? get backgroundColor => null;
  bool get showLoadingOverlay => true;
  bool get autoHandleSuccess => true;
  bool get autoHandleError => true;
  bool get enablePullToRefresh => false;
  bool get extendBody => false;
  bool get extendBodyBehindAppBar => false;

  // ── Notification prompt ────────────────────────────────────
  // Static flag — survives screen pushes/pops within same session.
  // Once the dialog has been shown (or skipped because permission
  // is already granted), no further screens will trigger it.
  static bool _promptShownThisSession = false;
  Timer? _notifPromptTimer;

  // ── Loading widgets ────────────────────────────────────────

  Widget buildLoadingWidget() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buildRefreshLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  // ── Empty & error widgets ──────────────────────────────────

  Widget buildEmptyWidget(ViewStateEmpty state) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            state.message ?? l10n.noDataAvailable,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          if (state.actionLabel != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onEmptyAction,
              child: Text(state.actionLabel!),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildErrorWidget(ViewStateError state) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIcon(state.severity),
              size: 64,
              color: _getErrorColor(state.severity),
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (state.isRetryable) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.warning:
        return Icons.warning_amber_rounded;
      case ErrorSeverity.error:
        return Icons.error_outline_rounded;
      case ErrorSeverity.critical:
        return Icons.cancel_rounded;
    }
  }

  Color _getErrorColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red[900]!;
    }
  }

  // ── Snackbar helpers ───────────────────────────────────────

  void showError(String message, {ErrorSeverity? severity}) {
    if (!mounted) return;
    final backgroundColor =
        severity != null ? _getErrorColor(severity) : Colors.red;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              severity != null ? _getErrorIcon(severity) : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void showWarning(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Dialog helpers ─────────────────────────────────────────

  void showLoadingDialog({String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void hideLoadingDialog() {
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── State change callbacks ─────────────────────────────────

  void onSuccess(ViewStateSuccess state) {
    if (autoHandleSuccess && state.message != null) {
      showSuccess(state.message!);
    }
  }

  void onError(ViewStateError state) {
    if (autoHandleError) {
      showError(state.message, severity: state.severity);
    }
  }

  void onEmpty(ViewStateEmpty state) {}
  void onLoading(ViewStateLoading state) {}
  void onRetry() {}
  void onEmptyAction() {}
  Future<void> onRefresh() async {}

  // ── Lifecycle ──────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    onScreenInit();
    _scheduleNotificationPrompt();
  }

  @override
  void dispose() {
    _notifPromptTimer?.cancel();
    onScreenDispose();
    super.dispose();
  }

  void _scheduleNotificationPrompt() {
    // Already shown once this session — skip immediately
    if (_promptShownThisSession) return;

    _notifPromptTimer = Timer(const Duration(seconds: 3), () async {
      // Permission already granted — nothing to ask
      final already = await NotificationPermissionService.isGranted();
      if (already) return;

      // Screen may have been disposed during the 3s wait
      if (!mounted) return;

      // Mark before showing — prevents a second screen from
      // racing through while the dialog is still open
      _promptShownThisSession = true;

      await NotificationPermissionDialog.show(context, ref);
    });
  }

  /// Called when screen is initialized — override in child classes
  void onScreenInit() {}

  /// Called when screen is disposed — override in child classes
  void onScreenDispose() {}

  // ── State management ───────────────────────────────────────

  ViewState? _previousState;

  @override
  Widget build(BuildContext context) {
    final viewState = viewModelProvider != null
        ? ref.watch(viewModelProvider!)
        : const ViewStateInitial();

    if (viewModelProvider != null) {
      ref.listen<ViewState>(
        viewModelProvider!,
        (previous, next) {
          if (_previousState != null &&
              _previousState.runtimeType == next.runtimeType &&
              _previousState == next) {
            return;
          }

          _previousState = next;

          if (next is ViewStateLoading) {
            onLoading(next);
          } else if (next is ViewStateSuccess) {
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
    final isRefreshing =
        viewState is ViewStateLoading && viewState.isRefreshing;

    Widget body = buildBody(context, ref);

    if (enablePullToRefresh) {
      body = RefreshIndicator(
        onRefresh: onRefresh,
        child: body,
      );
    }

    if (useSafeArea) {
      body = SafeArea(child: body);
    }

    return Scaffold(
      appBar: buildAppBar(context, ref),
      body: Stack(
        children: [
          body,
          if (showLoadingOverlay && isLoading && !isRefreshing)
            buildLoadingWidget(),
        ],
      ),
      floatingActionButton: buildFloatingActionButton(context, ref),
      bottomNavigationBar: buildBottomNavigationBar(context, ref),
      drawer: buildDrawer(context, ref),
      endDrawer: buildEndDrawer(context, ref),
      bottomSheet: buildBottomSheet(context, ref),
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}
