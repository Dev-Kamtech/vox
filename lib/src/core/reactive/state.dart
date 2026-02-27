import 'signal.dart';

/// Reactive state for a single value. The developer-facing state container.
///
/// Created via `state(initial)`. Extends [VoxSignal] with [update] for
/// transform-in-place mutations.
///
/// ```dart
/// final count = state(0);
/// count.val;              // read (tracked)
/// count.set(5);           // write (notifies)
/// count.update((v) => v + 1); // transform (notifies)
/// ```
class VoxState<T> extends VoxSignal<T> {
  VoxState(super.initial);

  /// Transform the current value. Reads via [peek] (not [val]) to avoid
  /// accidentally registering a listener when the intent is to write.
  void update(T Function(T current) updater) {
    set(updater(peek));
  }
}

/// Reactive state for a list. Adds list-specific operations.
///
/// Created via `state(<Type>[])`. The `<<` operator appends, and
/// mutations notify all listening screens.
///
/// ```dart
/// final todos = state(<String>[]);
/// todos << 'Buy milk';     // append
/// todos.remove('Buy milk'); // remove
/// todos.clear();            // clear all
/// ```
class VoxListState<T> extends VoxSignal<List<T>> {
  VoxListState(super.initial);

  /// Append an item to the list. Always notifies (lists are mutable).
  void operator <<(T item) {
    peek.add(item);
    notify();
  }

  /// Remove the first occurrence of [item]. Notifies if found.
  void remove(T item) {
    if (peek.remove(item)) {
      notify();
    }
  }

  /// Remove all items. Notifies if list was non-empty.
  void clear() {
    if (peek.isNotEmpty) {
      peek.clear();
      notify();
    }
  }

  /// Transform the list. Receives a copy, replaces with result.
  void update(List<T> Function(List<T> current) updater) {
    forceSet(updater(List<T>.from(peek)));
  }

  /// Number of items. Tracked — widgets reading this rebuild on change.
  int get length => val.length;

  /// Whether the list is empty. Tracked.
  bool get isEmpty => val.isEmpty;

  /// Whether the list has items. Tracked.
  bool get isNotEmpty => val.isNotEmpty;

  /// First item, or null if empty. Tracked.
  T? get first => val.isEmpty ? null : val.first;
}
