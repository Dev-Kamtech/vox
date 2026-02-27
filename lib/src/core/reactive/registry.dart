import 'shared.dart';

/// Global singleton registry for shared() state.
///
/// Shared state lives for the app's lifetime, accessible from any screen.
/// Keyed by an Object — same key from any screen returns the same instance.
abstract final class VoxRegistry {
  static final Map<Object, VoxShared> _shared = {};

  /// Get or create a [VoxShared] for [key]. Creates with [initial] on first call;
  /// subsequent calls with the same key return the existing instance.
  static VoxShared<T> getOrCreate<T>(Object key, T initial) {
    return _shared.putIfAbsent(key, () => VoxShared<T>(initial))
        as VoxShared<T>;
  }

  /// Clear all shared state. Used in testing.
  static void clear() => _shared.clear();
}
