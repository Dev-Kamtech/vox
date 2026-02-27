import 'package:flutter/material.dart';

import '../nav/router.dart';

/// Dialogs and bottom sheets. Uses the global navigator key — no BuildContext.
abstract final class VoxOverlay {
  static BuildContext? get _ctx => VoxRouter.key.currentContext;

  /// Show an informational alert dialog.
  ///
  /// Returns when the user dismisses it.
  static Future<void> alert(
    String title, {
    String? message,
    String ok = 'OK',
  }) async {
    final ctx = _ctx;
    if (ctx == null) return;
    await showDialog<void>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: message != null ? Text(message) : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(ok),
          ),
        ],
      ),
    );
  }

  /// Show a confirm dialog. Returns `true` if confirmed, `false` if cancelled.
  static Future<bool> confirm(
    String title, {
    String? message,
    String yes = 'Yes',
    String no = 'Cancel',
  }) async {
    final ctx = _ctx;
    if (ctx == null) return false;
    return await showDialog<bool>(
          context: ctx,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: message != null ? Text(message) : null,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(no),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(yes),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Show a modal bottom sheet. [builder] returns the sheet's content.
  static Future<T?> sheet<T>({
    required Widget Function() builder,
    bool isDismissible = true,
    bool useRootNavigator = true,
  }) async {
    final ctx = _ctx;
    if (ctx == null) return null;
    return showModalBottomSheet<T>(
      context: ctx,
      isDismissible: isDismissible,
      useRootNavigator: useRootNavigator,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => builder(),
    );
  }
}
