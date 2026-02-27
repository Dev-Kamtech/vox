import 'dart:async';
import 'dart:ui' show VoidCallback;

/// Timer utilities. See [delay] and [every].
abstract final class VoxTimer {
  /// Execute [fn] once after [duration].
  ///
  /// If [fn] is omitted, returns a [Future] that completes after [duration].
  static Future<void> delay(Duration duration, [VoidCallback? fn]) async {
    await Future<void>.delayed(duration);
    fn?.call();
  }

  /// Execute [fn] every [interval]. Returns a cancel function.
  ///
  /// ```dart
  /// final stop = every(const Duration(seconds: 1), () => tick());
  /// // later:
  /// stop();
  /// ```
  static VoidCallback every(Duration interval, VoidCallback fn) {
    final timer = Timer.periodic(interval, (_) => fn());
    return timer.cancel;
  }
}
