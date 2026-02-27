/// Dialogs and bottom sheets — no BuildContext required.
///
/// ```dart
/// await alert('No internet', message: 'Check your connection.');
///
/// final ok = await confirm('Delete account?', message: 'This cannot be undone.');
/// if (ok) deleteAccount();
///
/// await sheet(builder: () => MySheetContent());
/// ```
library;

export '../core/overlay/overlay_engine.dart' show VoxOverlay;

import 'package:flutter/material.dart' show Widget;

import '../core/overlay/overlay_engine.dart';

/// Show an informational alert dialog.
///
/// Returns when the user dismisses it.
Future<void> alert(
  String title, {
  String? message,
  String ok = 'OK',
}) =>
    VoxOverlay.alert(title, message: message, ok: ok);

/// Show a confirm dialog. Returns `true` if confirmed, `false` if cancelled.
Future<bool> confirm(
  String title, {
  String? message,
  String yes = 'Yes',
  String no = 'Cancel',
}) =>
    VoxOverlay.confirm(title, message: message, yes: yes, no: no);

/// Show a modal bottom sheet. [builder] returns the sheet's content widget.
///
/// ```dart
/// final result = await sheet<String>(builder: () => PickerSheet());
/// ```
Future<T?> sheet<T>({
  required Widget Function() builder,
  bool isDismissible = true,
  bool useRootNavigator = true,
}) =>
    VoxOverlay.sheet<T>(
      builder: builder,
      isDismissible: isDismissible,
      useRootNavigator: useRootNavigator,
    );
