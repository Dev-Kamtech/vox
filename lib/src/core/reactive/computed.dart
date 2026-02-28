import 'signal.dart';
import '../errors/vox_error.dart';

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

  // Stack of actively computing instances — used to detect circular deps.
  static final Set<VoxComputed> _computing = {};

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
    // Circular dependency guard: if this computed is already on the stack,
    // a cycle exists (e.g. a → b → a). Throw a clear developer error.
    if (_computing.contains(this)) {
      throw const VoxError(
        'Circular computed() dependency detected.',
        hint: 'A computed() signal depends on itself through a cycle. '
            'Check your computed() functions for mutual references.',
      );
    }
    _computing.add(this);

    // Save any in-progress tracker state (e.g. if constructed during a build).
    final prevListener   = VoxTracker.currentListener;
    final prevOnSubscribe = VoxTracker.onSubscribe;

    VoxTracker.startTracking(
      _recompute,
      onSubscribe: (s) => _sources.add(s),
    );

    try {
      final newValue = compute();
      // Only notify if the computed value actually changed.
      set(newValue);
    } finally {
      if (prevListener != null) {
        VoxTracker.startTracking(prevListener, onSubscribe: prevOnSubscribe);
      } else {
        VoxTracker.stopTracking();
      }
      _computing.remove(this);
    }
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
