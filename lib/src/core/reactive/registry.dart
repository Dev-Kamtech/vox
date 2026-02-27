import 'signal.dart';

/// Global singleton registry for shared() state.
///
/// Shared state lives for the app's lifetime, accessible from any screen.
/// Keyed by type — one shared signal per type.
abstract final class VoxRegistry {
  static final Map<Object, VoxSignal> _shared = {};

  /// Get or create a shared signal for type [T] with [key].
  static VoxSignal<T> getOrCreate<T>(Object key, T initial) {
    return _shared.putIfAbsent(key, () => VoxSignal<T>(initial))
        as VoxSignal<T>;
  }

  /// Clear all shared state. Used in testing.
  static void clear() => _shared.clear();
}
