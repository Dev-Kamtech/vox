import 'signal.dart';

/// Derived/computed state. Read-only, auto-updates when source signals change.
///
/// Fully implemented in a later phase. Stub for now.
class VoxComputed<T> extends VoxSignal<T> {
  /// The computation function. Will be used for re-computation
  /// when source signals change (implemented in a later phase).
  final T Function() compute;

  VoxComputed(this.compute) : super(compute());
}
