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

  // ---------------------------------------------------------------------------
  // Iteration / projection (all tracked — reading screens rebuild on change)
  // ---------------------------------------------------------------------------

  /// Map each item to [R] and return the results as a [List<R>].
  ///
  /// ```dart
  /// todos.each((t) => label(t.title))  // List<Widget>
  ///   .col                              // wrap in a Column
  /// ```
  List<R> each<R>(R Function(T item) fn) => val.map(fn).toList();

  /// Return items matching [test]. Tracked.
  List<T> where(bool Function(T item) test) => val.where(test).toList();

  /// Case-insensitive substring search.
  ///
  /// [by] extracts the searchable string from each item.
  /// Returns all items when [query] is empty.
  List<T> search({
    required String Function(T item) by,
    required String query,
  }) {
    if (query.isEmpty) return val; // tracked
    final q = query.toLowerCase();
    return val.where((item) => by(item).toLowerCase().contains(q)).toList();
  }

  /// Sort the list in-place by [by] comparator (or natural order if omitted).
  /// Notifies all listening screens.
  void sort([Comparator<T>? by]) {
    peek.sort(by);
    notify();
  }

  /// Return a page of [size] items starting at [offset]. Tracked.
  List<T> paginate(int size, {int offset = 0}) {
    final list = val; // tracked
    if (offset >= list.length) return [];
    return list.skip(offset).take(size).toList();
  }
}
