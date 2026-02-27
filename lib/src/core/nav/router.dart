import 'package:flutter/material.dart';

/// Internal navigation engine. Uses a [GlobalKey<NavigatorState>] so
/// navigation works from anywhere — no BuildContext required.
///
/// The key is registered with the [MaterialApp] in [voxAppRunner].
/// Developers call the top-level [go] and [back] API functions.
abstract final class VoxRouter {
  /// The navigator key. Registered as [MaterialApp.navigatorKey].
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  static NavigatorState get _nav {
    assert(
      key.currentState != null,
      'vox: navigator not ready. '
      'Make sure voxApp() is running before calling go() or back().',
    );
    return key.currentState!;
  }

  /// Push [screen] onto the navigation stack.
  /// Pass [replace] to swap the current route instead of pushing.
  static void go(Widget screen, {bool replace = false}) {
    final route = MaterialPageRoute<void>(builder: (_) => screen);
    if (replace) {
      _nav.pushReplacement(route);
    } else {
      _nav.push(route);
    }
  }

  /// Pop the current screen. Optionally pass a [result] back to the caller.
  static void back<T extends Object?>({T? result}) => _nav.pop<T>(result);

  /// Whether there is a screen to pop back to.
  static bool get canBack => _nav.canPop();
}
