// lib/core/notifications/notification_permission_provider.dart
//
// Reactive Riverpod provider that exposes real OS notification permission status.
//
// Every screen with a notification toggle watches this provider so the toggle
// always reflects the true OS state — not just the stored user preference.
//
// Usage:
//   final isGranted = ref.watch(notificationPermissionProvider).valueOrNull ?? false;
//
// After the user returns from OS Settings, call:
//   ref.read(notificationPermissionProvider.notifier).refresh();

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_service.dart';

class NotificationPermissionNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return NotificationPermissionService.isGranted();
  }

  /// Re-checks OS permission — call when returning from app Settings.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => NotificationPermissionService.isGranted(),
    );
  }
}

final notificationPermissionProvider =
    AsyncNotifierProvider<NotificationPermissionNotifier, bool>(
  NotificationPermissionNotifier.new,
);
