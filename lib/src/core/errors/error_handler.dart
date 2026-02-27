import 'package:flutter/foundation.dart';

import 'vox_error.dart';

/// Three-tier error handling for vox.
///
/// - [throwVox]: Developer misuse → always throws VoxError (both modes).
/// - [guard]: Internal assertion → assert in debug, no-op in production.
/// - [safeRun]: Core operation wrapper → catches failures, degrades in production.
abstract final class VoxErrorHandler {
  /// Throws a [VoxError]. Used at the api/ boundary when the developer
  /// passes invalid input. Always throws — this is the developer's fault.
  static Never throwVox(String message, {String? hint}) {
    throw VoxError(message, hint: hint);
  }

  /// Debug-only assertion. If [condition] is false, fails with a
  /// `vox [internal]` message. Silent no-op in production.
  static void guard(bool condition, String message) {
    assert(condition, 'vox [internal]: $message');
  }

  /// Wraps a core/ operation defensively. If it throws:
  /// - Debug mode: rethrows so the developer sees it.
  /// - Production: returns [fallback] silently.
  static T? safeRun<T>(T Function() fn, {T? fallback}) {
    try {
      return fn();
    } catch (e) {
      if (kDebugMode) rethrow;
      return fallback;
    }
  }
}
