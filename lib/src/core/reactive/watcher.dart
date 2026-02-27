import 'dart:ui';

import 'signal.dart';

/// Run [callback] whenever [signal] changes. Returns a dispose function.
///
/// Fully implemented in a later phase. Stub for now.
VoidCallback watch<T>(VoxSignal<T> signal, void Function(T value) callback) {
  void listener() => callback(signal.peek);
  signal.val; // subscribe (if in tracking context)
  return () => signal.removeListener(listener);
}
