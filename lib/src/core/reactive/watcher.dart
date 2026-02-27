import 'dart:ui';

import 'signal.dart';

/// Run [callback] whenever [signal] changes. Returns a dispose function.
///
/// The callback fires every time [signal] notifies, receiving the new value.
/// Call the returned function to stop watching.
///
/// Typical usage — register in [VoxLifecycle.ready], dispose in [onDispose]:
/// ```dart
/// VoidCallback? _stop;
///
/// @override
/// void ready() {
///   _stop = watch(counter, (v) => print('counter: $v'));
/// }
///
/// @override
/// void onDispose() => _stop?.call();
/// ```
VoidCallback watch<T>(VoxSignal<T> signal, void Function(T value) callback) {
  void listener() => callback(signal.peek);
  // Direct subscription — not through VoxTracker. This means the screen
  // that calls watch() does NOT need to re-run view to keep the watcher alive.
  signal.addListener(listener);
  return () => signal.removeListener(listener);
}
