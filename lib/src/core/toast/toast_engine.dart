import 'package:flutter/material.dart';

import '../nav/router.dart';

/// Toast/snackbar variants.
enum VoxToastType { info, success, warning, error }

/// Shows snackbar notifications via ScaffoldMessenger.
/// Uses the global navigator key — no BuildContext required.
abstract final class VoxToast {
  static void show(
    String message, {
    VoxToastType type = VoxToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final context = VoxRouter.key.currentContext;
    if (context == null) return;

    final color = switch (type) {
      VoxToastType.success => const Color(0xFF2E7D32),
      VoxToastType.warning => const Color(0xFFE65100),
      VoxToastType.error => const Color(0xFFC62828),
      VoxToastType.info => null, // uses theme default
    };

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          duration: duration,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
  }
}
