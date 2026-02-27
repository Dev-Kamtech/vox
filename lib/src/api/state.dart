/// State API — reactive state management.
///
/// ```dart
/// final count = state(0);          // screen-local
/// final todos = state(<String>[]); // list state
/// ```
library;

export '../core/reactive/signal.dart' show VoxSignal;
export '../core/reactive/state.dart' show VoxState, VoxListState;
export '../core/reactive/shared.dart' show VoxShared;
export '../core/reactive/computed.dart' show VoxComputed;

import '../core/reactive/state.dart';

/// Create a reactive state with an [initial] value.
///
/// The returned [VoxState] auto-tracks which screens read it and
/// rebuilds only those screens when the value changes.
VoxState<T> state<T>(T initial) => VoxState<T>(initial);
