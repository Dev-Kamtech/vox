import 'state.dart';

/// App-global reactive state. Lives for the app's lifetime,
/// accessible from any screen by the same key.
///
/// Created via `shared(key, initial)`. Returns the same instance
/// for the same key regardless of which screen calls it.
///
/// ```dart
/// final counter = shared('counter', 0);
/// counter.val;              // read (tracked)
/// counter.set(5);           // write (notifies all screens reading it)
/// counter.update((v) => v + 1);
/// ```
class VoxShared<T> extends VoxState<T> {
  VoxShared(super.initial);
}
