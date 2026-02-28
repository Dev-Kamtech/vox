import 'dart:ui';

import 'signal.dart';
import 'auto_dispose.dart';

/// Run [callback] whenever [signal] changes. Returns a dispose function.
///
/// The callback fires every time [signal] notifies, receiving the new value.
/// Call the returned function to stop watching early.
///
/// **Auto-dispose**: when called inside [VoxLifecycle.ready()], the watcher
/// is disposed automatically when the screen/widget is removed from the tree.
/// No manual cleanup needed:
///
/// ```dart
/// @override
/// void ready() {
///   watch(counter, (v) => print('counter: $v')); // auto-disposed on screen exit
/// }
/// ```
///
/// If you need to stop early, use the returned callback:
/// ```dart
/// final stop = watch(ticker, (_) => step());
/// btn('Stop').onTap(stop);
/// ```
VoidCallback watch<T>(VoxSignal<T> signal, void Function(T value) callback) {
  void listener() => callback(signal.peek);
  signal.addListener(listener);
  void disposer() => signal.removeListener(listener);
  // If called inside a VoxScreen/VoxWidget ready() scope, register for
  // automatic cleanup on screen dispose — no manual onDispose() needed.
  VoxAutoDispose.register(disposer);
  return disposer;
}
