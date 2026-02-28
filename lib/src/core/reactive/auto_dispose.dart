import 'dart:ui' show VoidCallback;

/// Auto-dispose scope for reactive subscriptions.
///
/// When a [VoxScreen] calls [ready()], the scope opens automatically.
/// Any [watch()] call inside that [ready()] registers its dispose function
/// here. The screen collects the disposers via [end()] and runs them on
/// [dispose()] — so developers never have to manually cancel a watch.
///
/// Developers who need to stop watching early can still call the returned
/// [VoidCallback] directly. The auto-dispose is idempotent — calling
/// [removeListener] twice is safe.
class VoxAutoDispose {
  static List<VoidCallback>? _current;

  /// Open a new scope. Called by _VoxScreenState / _VoxWidgetState
  /// immediately before invoking [VoxLifecycle.ready()].
  static void begin() => _current = <VoidCallback>[];

  /// Register a dispose function. Called automatically by [watch()].
  /// No-op if no scope is open (watch called outside ready()).
  static void register(VoidCallback disposer) => _current?.add(disposer);

  /// Close the scope and return the collected disposers.
  /// Called by the screen/widget immediately after [ready()] returns.
  static List<VoidCallback> end() {
    final collected = List<VoidCallback>.unmodifiable(_current ?? const []);
    _current = null;
    return collected;
  }
}
