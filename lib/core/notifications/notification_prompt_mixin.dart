// lib/core/notifications/notification_prompt_mixin.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_dialog.dart';
import 'package:ekush_ponji/core/notifications/notification_permission_service.dart';

mixin NotificationPromptMixin on ConsumerState {
  Timer? _promptTimer;

  // ── Static session guard ───────────────────────────────────
  // Ensures the prompt fires at most once per app session,
  // regardless of how many screens use this mixin.
  static bool _promptShownThisSession = false;

  int get promptDelaySeconds => 15;

  @override
  void initState() {
    super.initState();
    _schedulePrompt();
  }

  @override
  void dispose() {
    _promptTimer?.cancel();
    super.dispose();
  }

  void _schedulePrompt() {
    // Already shown this session — skip
    if (_promptShownThisSession) return;

    _promptTimer = Timer(Duration(seconds: promptDelaySeconds), () async {
      // Skip if permission already granted
      final already = await NotificationPermissionService.isGranted();
      if (already) return;

      if (!mounted) return;

      // Mark before showing to prevent race condition if
      // two screens somehow reach this point simultaneously
      _promptShownThisSession = true;

      await NotificationPermissionDialog.show(context, ref);
    });
  }
}
