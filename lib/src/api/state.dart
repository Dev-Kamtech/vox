/// State API — reactive state management.
///
/// ```dart
/// final count  = state(0);             // screen-local, any type
/// final todos  = state(<String>[]);    // list state
/// final global = shared('key', 0);    // app-wide shared state
/// final full   = computed(() => '${first.val} ${last.val}'); // derived
/// final theme  = stored('theme', 'light'); // persisted
/// ```
library;

export '../core/reactive/signal.dart' show VoxSignal;
export '../core/reactive/state.dart' show VoxState, VoxListState;
export '../core/reactive/shared.dart' show VoxShared;
export '../core/reactive/computed.dart' show VoxComputed;
export '../core/reactive/stored.dart' show VoxStored;

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' show VoidCallback;

import '../core/reactive/state.dart';
import '../core/reactive/shared.dart';
import '../core/reactive/registry.dart';
import '../core/reactive/computed.dart';
import '../core/reactive/signal.dart';
import '../core/reactive/watcher.dart' as watcher_lib;
import '../core/reactive/stored.dart';
import '../core/reactive/rx_widget.dart';

// ---------------------------------------------------------------------------
// Factories
// ---------------------------------------------------------------------------

/// Create a reactive state with an [initial] value.
///
/// For lists, use a typed literal: `state(<String>[])` or `state<List<Todo>>([])`.
/// The type is inferred automatically for scalar values: `state(0)`, `state(false)`.
VoxState<T> state<T>(T initial) => VoxState<T>(initial);

/// Create or retrieve app-global shared state by [key].
///
/// The same key returns the same signal instance from any screen.
/// The [initial] value is only used when the key is created for the first time.
///
/// ```dart
/// // ScreenA
/// final counter = shared('counter', 0);
///
/// // ScreenB — same instance
/// final counter = shared('counter', 0);
/// ```
VoxShared<T> shared<T>(Object key, T initial) =>
    VoxRegistry.getOrCreate<T>(key, initial);

/// Create a computed (derived) signal.
///
/// Every [VoxSignal.val] read inside [fn] becomes a dependency.
/// When any dependency changes, [fn] re-runs and screens reading
/// the computed signal rebuild.
///
/// ```dart
/// final fullName = computed(() => '${first.val} ${last.val}');
/// ```
VoxComputed<T> computed<T>(T Function() fn) => VoxComputed<T>(fn);

/// Watch [signal] and run [callback] whenever it changes.
///
/// Returns a dispose function — call it to stop watching.
/// Register in [VoxLifecycle.ready], dispose in [onDispose]:
///
/// ```dart
/// VoidCallback? _stop;
///
/// @override
/// void ready() => _stop = watch(counter, (v) => log('$v'));
///
/// @override
/// void onDispose() => _stop?.call();
/// ```
VoidCallback watch<T>(VoxSignal<T> signal, void Function(T value) callback) =>
    watcher_lib.watch(signal, callback);

/// Create reactive state that is also persisted to local storage.
///
/// The value survives app restarts. On first launch the [defaultValue] is used;
/// on subsequent launches the last saved value is restored.
///
/// Supported types: [String], [int], [double], [bool], [List<String>].
///
/// ```dart
/// final theme = stored('theme', 'light');
/// theme.set('dark');  // updates UI + saves to disk
/// ```
VoxStored<T> stored<T>(String key, T defaultValue) =>
    VoxStored<T>(key, defaultValue);

/// Granular reactive sub-widget. Only rebuilds when signals read inside
/// [builder] change — the parent [VoxScreen] is NOT rebuilt.
///
/// Use inside a screen's [view] to scope hot rebuilds to a specific subtree:
///
/// ```dart
/// get view => col([
///   label('Static header'),           // never rebuilds
///   rx(() => label('${count.val}')),  // rebuilds ONLY when count changes
///   label('Static footer'),           // never rebuilds
/// ]);
/// ```
///
/// Unlike reading `count.val` directly in [VoxScreen.view] (which rebuilds
/// the entire screen), `rx()` isolates the rebuild to just this widget.
Widget rx(Widget Function() builder) => RxWidget(builder);
