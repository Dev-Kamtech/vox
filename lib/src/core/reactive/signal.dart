import 'dart:ui';

import 'package:flutter/foundation.dart' show protected;

/// Global build-time tracker.
///
/// During a VoxScreen/VoxWidget build, [startTracking] is called with
/// that screen's setState callback. Any [VoxSignal.val] read during
/// the build registers the callback as a listener. After the build,
/// [stopTracking] clears the tracker.
///
/// Supports nesting: save/restore via [currentListener] before/after.
class VoxTracker {
  static VoidCallback? _currentListener;
  static void Function(VoxSignal)? _onSubscribe;

  /// Begin tracking. Called by _VoxScreenState.build().
  static void startTracking(
    VoidCallback listener, {
    void Function(VoxSignal)? onSubscribe,
  }) {
    _currentListener = listener;
    _onSubscribe = onSubscribe;
  }

  /// Stop tracking. Called after build completes.
  static void stopTracking() {
    _currentListener = null;
    _onSubscribe = null;
  }

  /// The current listener (if any). Exposed for save/restore in nested builds.
  static VoidCallback? get currentListener => _currentListener;

  /// The current subscribe callback (if any). Exposed for save/restore.
  static void Function(VoxSignal)? get onSubscribe => _onSubscribe;
}

/// The base reactive observable. Stores a value, notifies listeners on change.
///
/// This is the heart of vox's reactivity. When [val] is read during a
/// tracked build, the reading screen is registered as a listener. When
/// [set] is called with a different value, all registered listeners are
/// notified (triggering rebuilds for exactly those screens).
class VoxSignal<T> {
  T _value;
  final Set<VoidCallback> _listeners = {};

  VoxSignal(this._value);

  /// Read the current value.
  ///
  /// If called during a tracked build (inside a [VoxScreen.view] getter),
  /// the current screen's rebuild callback is registered as a listener.
  T get val {
    final listener = VoxTracker._currentListener;
    if (listener != null) {
      _listeners.add(listener);
      VoxTracker._onSubscribe?.call(this);
    }
    return _value;
  }

  /// Set a new value. If different from current, notifies all listeners.
  void set(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notify();
  }

  /// Directly assign without equality check. Used by list mutations
  /// that modify in-place and always need to notify.
  @protected
  void forceSet(T newValue) {
    _value = newValue;
    notify();
  }

  /// Read without tracking. Used internally where registration
  /// would be incorrect (e.g., inside update()).
  T get peek => _value;

  /// Remove a specific listener. Called during screen unsubscribe.
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Remove all listeners. Called on dispose.
  void dispose() {
    _listeners.clear();
  }

  /// Notify all registered listeners that the value changed.
  /// Protected so subclasses in other files can trigger notifications.
  @protected
  void notify() {
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }
}
