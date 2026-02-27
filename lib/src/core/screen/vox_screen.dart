import 'package:flutter/material.dart' hide State;
import 'package:flutter/material.dart' as flutter show State;

import '../reactive/signal.dart';
import 'lifecycle.dart';

/// The base class developers extend to create screens.
///
/// Hides StatefulWidget, State, setState, build, BuildContext.
/// Developer writes [view] to return a widget tree — that's it.
///
/// ```dart
/// class MyScreen extends VoxScreen {
///   final count = state(0);
///
///   @override
///   get view => screen('Title', col([
///     label('Count: ${count.val}'),
///     btn('+').onTap(() => count.update((v) => v + 1)),
///   ]));
/// }
/// ```
abstract class VoxScreen with VoxLifecycle {
  /// The view getter — the developer's build method.
  /// Returns the widget tree. No BuildContext parameter needed.
  Widget get view;

  /// Converts this screen to a Flutter widget. Used internally by
  /// voxApp and navigation. Not part of the public API.
  Widget toWidget() => _VoxScreenWidget(this);
}

/// Internal StatefulWidget — developers never see this.
class _VoxScreenWidget extends StatefulWidget {
  final VoxScreen screen;

  const _VoxScreenWidget(this.screen);

  @override
  flutter.State<_VoxScreenWidget> createState() => _VoxScreenState();
}

/// Internal State — developers never see this.
///
/// Manages:
/// - Signal tracking during build (via VoxTracker)
/// - Clean subscribe/unsubscribe on each rebuild
/// - Lifecycle hooks (ready, background, foreground, dispose)
class _VoxScreenState extends flutter.State<_VoxScreenWidget>
    with WidgetsBindingObserver {
  late final VoidCallback _rebuildCallback;
  final Set<VoxSignal> _subscribedSignals = {};

  @override
  void initState() {
    super.initState();
    _rebuildCallback = _scheduleRebuild;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.screen.ready();
    });
  }

  void _scheduleRebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Unsubscribe from all signals from previous build (clean slate).
    _unsubscribeAll();

    // Save previous tracker state (supports nesting: VoxWidget inside VoxScreen).
    final prevListener = VoxTracker.currentListener;
    final prevOnSubscribe = VoxTracker.onSubscribe;

    // Start tracking: any signal.val read during view will register us.
    VoxTracker.startTracking(
      _rebuildCallback,
      onSubscribe: (signal) => _subscribedSignals.add(signal),
    );

    final result = widget.screen.view;

    // Restore previous tracker state.
    if (prevListener != null) {
      VoxTracker.startTracking(prevListener, onSubscribe: prevOnSubscribe);
    } else {
      VoxTracker.stopTracking();
    }

    return result;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        widget.screen.foreground();
      case AppLifecycleState.paused:
        widget.screen.background();
      case AppLifecycleState.inactive:
        widget.screen.pause();
      default:
        break;
    }
  }

  @override
  void dispose() {
    _unsubscribeAll();
    widget.screen.onDispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _unsubscribeAll() {
    for (final signal in _subscribedSignals) {
      signal.removeListener(_rebuildCallback);
    }
    _subscribedSignals.clear();
  }
}
