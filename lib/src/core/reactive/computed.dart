import 'signal.dart';

/// Derived/computed state. Read-only, auto-updates when source signals change.
///
/// When [compute] is called, every [VoxSignal.val] read inside it is tracked
/// as a dependency. When any dependency changes, [compute] re-runs and
/// screens reading this signal rebuild automatically.
///
/// ```dart
/// final firstName = state('Ada');
/// final lastName  = state('Lovelace');
/// final fullName  = computed(() => '${firstName.val} ${lastName.val}');
///
/// fullName.val;  // 'Ada Lovelace'
/// firstName.set('Grace');
/// fullName.val;  // 'Grace Lovelace' — auto-updated
/// ```
class VoxComputed<T> extends VoxSignal<T> {
  final T Function() compute;
  final Set<VoxSignal> _sources = {};

  VoxComputed(this.compute) : super(compute()) {
    // First call in super() captured the initial value without tracking.
    // Subscribe to sources now so future changes trigger re-computation.
    _subscribe();
  }

  // Called whenever a source signal changes.
  void _recompute() {
    for (final s in _sources) {
      s.removeListener(_recompute);
    }
    _sources.clear();
    _subscribe();
  }

  // Run [compute] in a tracked context, collecting source signals.
  // Then update the stored value if it changed.
  void _subscribe() {
    // Save any in-progress tracker state (e.g. if constructed during a build).
    final prevListener = VoxTracker.currentListener;
    final prevOnSubscribe = VoxTracker.onSubscribe;

    VoxTracker.startTracking(
      _recompute,
      onSubscribe: (s) => _sources.add(s),
    );

    final newValue = compute();

    if (prevListener != null) {
      VoxTracker.startTracking(prevListener, onSubscribe: prevOnSubscribe);
    } else {
      VoxTracker.stopTracking();
    }

    // Only notify if the computed value actually changed.
    set(newValue);
  }

  @override
  void dispose() {
    for (final s in _sources) {
      s.removeListener(_recompute);
    }
    _sources.clear();
    super.dispose();
  }
}
