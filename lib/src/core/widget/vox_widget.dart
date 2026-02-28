import 'package:flutter/material.dart' hide State;
import 'package:flutter/material.dart' as flutter show State;

import '../reactive/signal.dart';
import '../reactive/auto_dispose.dart';
import '../screen/lifecycle.dart';

/// A reusable sub-component with its own local state.
///
/// Same pattern as [VoxScreen] but without Scaffold/AppBar assumptions.
/// Use for reusable pieces that can be embedded in any screen or widget.
///
/// ```dart
/// class Counter extends VoxWidget {
///   final count = state(0);
///
///   @override
///   get view => row([
///     btn('-').onTap(() => count.update((v) => v - 1)),
///     label('${count.val}'),
///     btn('+').onTap(() => count.update((v) => v + 1)),
///   ]);
/// }
/// ```
abstract class VoxWidget with VoxLifecycle {
  /// The view getter — returns the widget tree for this component.
  Widget get view;

  /// Converts this widget to a Flutter widget. Used internally.
  Widget toWidget() => _VoxWidgetWrapper(this);
}

/// Internal StatefulWidget wrapper for VoxWidget.
class _VoxWidgetWrapper extends StatefulWidget {
  final VoxWidget voxWidget;

  const _VoxWidgetWrapper(this.voxWidget);

  @override
  flutter.State<_VoxWidgetWrapper> createState() => _VoxWidgetState();
}

/// Internal State for VoxWidget. Same tracking pattern as VoxScreen.
class _VoxWidgetState extends flutter.State<_VoxWidgetWrapper> {
  late final VoidCallback _rebuildCallback;
  final Set<VoxSignal> _subscribedSignals = {};
  List<VoidCallback> _watchDisposers = const [];

  @override
  void initState() {
    super.initState();
    _rebuildCallback = _scheduleRebuild;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VoxAutoDispose.begin();
      widget.voxWidget.ready();
      _watchDisposers = VoxAutoDispose.end();
    });
  }

  void _scheduleRebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _unsubscribeAll();

    final prevListener = VoxTracker.currentListener;
    final prevOnSubscribe = VoxTracker.onSubscribe;

    VoxTracker.startTracking(
      _rebuildCallback,
      onSubscribe: (signal) => _subscribedSignals.add(signal),
    );

    final result = widget.voxWidget.view;

    if (prevListener != null) {
      VoxTracker.startTracking(prevListener, onSubscribe: prevOnSubscribe);
    } else {
      VoxTracker.stopTracking();
    }

    return result;
  }

  @override
  void dispose() {
    _unsubscribeAll();
    for (final d in _watchDisposers) {
      d();
    }
    widget.voxWidget.onDispose();
    super.dispose();
  }

  void _unsubscribeAll() {
    for (final signal in _subscribedSignals) {
      signal.removeListener(_rebuildCallback);
    }
    _subscribedSignals.clear();
  }
}
