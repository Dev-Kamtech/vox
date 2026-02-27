/// Snackbar / toast notifications.
///
/// ```dart
/// toast('Saved!');
/// toast('Upload failed', type: VoxToastType.error);
/// toast('Check your inbox', type: VoxToastType.warning, duration: Duration(seconds: 5));
/// ```
library;

export '../core/toast/toast_engine.dart' show VoxToast, VoxToastType;

import '../core/toast/toast_engine.dart';

/// Show a toast notification.
///
/// [type] controls the background color:
/// - [VoxToastType.info] — default (theme color)
/// - [VoxToastType.success] — green
/// - [VoxToastType.warning] — orange
/// - [VoxToastType.error] — red
///
/// ```dart
/// toast('Profile updated', type: VoxToastType.success);
/// ```
void toast(
  String message, {
  VoxToastType type = VoxToastType.info,
  Duration duration = const Duration(seconds: 3),
}) =>
    VoxToast.show(message, type: type, duration: duration);
