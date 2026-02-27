import 'signal.dart';

/// Owns a set of signals and disposes them together.
///
/// Each VoxScreen/VoxWidget creates a scope. When the screen disposes,
/// the scope disposes all its signals, preventing memory leaks.
class VoxScope {
  final Set<VoxSignal> _signals = {};

  /// Register a signal with this scope.
  void track(VoxSignal signal) {
    _signals.add(signal);
  }

  /// Dispose all tracked signals and clear the set.
  void dispose() {
    for (final signal in _signals) {
      signal.dispose();
    }
    _signals.clear();
  }
}
