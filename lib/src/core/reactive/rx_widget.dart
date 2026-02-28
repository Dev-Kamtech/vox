import 'package:flutter/widgets.dart';

import 'signal.dart';

/// Granular reactive sub-widget.
///
/// Wraps [builder] in an isolated rebuild scope. Only this widget rebuilds
/// when the signals read inside [builder] change — the parent [VoxScreen]
/// is not involved.
///
/// Use `rx()` (the public factory in api/state.dart) to create one.
///
/// Internally uses the same VoxTracker subscribe/unsubscribe pattern as
/// VoxScreen, but scoped to a single StatefulWidget build cycle.
class RxWidget extends StatefulWidget {
  final Widget Function() builder;

  const RxWidget(this.builder, {super.key});

  @override
  State<RxWidget> createState() => _RxWidgetState();
}

class _RxWidgetState extends State<RxWidget> {
  final Set<VoxSignal> _subscribed = {};
  late final VoidCallback _rebuild;

  @override
  void initState() {
    super.initState();
    _rebuild = _scheduleRebuild;
  }

  void _scheduleRebuild() {
    if (mounted) setState(() {});
  }

  void _unsubscribeAll() {
    for (final s in _subscribed) {
      s.removeListener(_rebuild);
    }
    _subscribed.clear();
  }

  @override
  void dispose() {
    _unsubscribeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Clean slate — unsubscribe stale signals from previous build.
    _unsubscribeAll();

    // Save/restore parent tracker state (supports rx() nested inside
    // another rx() or inside a VoxScreen build, however unlikely).
    final prevListener  = VoxTracker.currentListener;
    final prevSubscribe = VoxTracker.onSubscribe;

    VoxTracker.startTracking(
      _rebuild,
      onSubscribe: (s) => _subscribed.add(s),
    );

    final result = widget.builder();

    if (prevListener != null) {
      VoxTracker.startTracking(prevListener, onSubscribe: prevSubscribe);
    } else {
      VoxTracker.stopTracking();
    }

    return result;
  }
}
