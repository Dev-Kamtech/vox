import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

/// Leveled console logger. Use the global [log] singleton.
///
/// ```dart
/// log.d('fetching user');          // debug (debug builds only)
/// log.i('user loaded: ${user.id}'); // info
/// log.w('token expiring soon');     // warning
/// log.e('login failed', error);     // error
/// ```
class VoxLog {
  const VoxLog._();

  /// Debug — only printed in debug builds.
  void d(String message) {
    if (kDebugMode) debugPrint('\x1B[37m[vox:debug] $message\x1B[0m');
  }

  /// Info.
  void i(String message) {
    debugPrint('\x1B[36m[vox:info]  $message\x1B[0m');
  }

  /// Warning.
  void w(String message) {
    debugPrint('\x1B[33m[vox:warn]  $message\x1B[0m');
  }

  /// Error. Pass the caught [error] object for additional context.
  void e(String message, [Object? error]) {
    final suffix = error != null ? ' — $error' : '';
    debugPrint('\x1B[31m[vox:error] $message$suffix\x1B[0m');
  }
}

/// Global logger instance.
const log = VoxLog._();
