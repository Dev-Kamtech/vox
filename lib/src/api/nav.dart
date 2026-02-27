/// Navigation API — push screens, go back, no BuildContext required.
///
/// ```dart
/// go(DetailScreen(id: item.id));          // push
/// go(LoginScreen(), replace: true);       // replace current screen
/// back();                                 // pop
/// back(result: 'saved');                  // pop with a return value
/// if (canBack) back();                    // conditional pop
/// ```
library;

import 'package:flutter/widgets.dart' show Widget;

import '../core/nav/router.dart';
import '../core/screen/vox_screen.dart';

/// Navigate to [screen] by pushing it onto the navigation stack.
///
/// [screen] can be a [VoxScreen] or any Flutter [Widget].
/// Pass `replace: true` to replace the current route instead of pushing.
///
/// ```dart
/// go(ProfileScreen());
/// go(LoginScreen(), replace: true);
/// go(DetailScreen(id: item.id));
/// ```
void go(Object screen, {bool replace = false}) {
  final widget =
      screen is VoxScreen ? screen.toWidget() : screen as Widget;
  VoxRouter.go(widget, replace: replace);
}

/// Pop the current screen off the navigation stack.
///
/// Pass [result] to return a value to the calling screen.
///
/// ```dart
/// back();
/// back(result: 'saved');
/// ```
void back<T extends Object?>({T? result}) => VoxRouter.back<T>(result: result);

/// Whether there is a screen to pop back to.
///
/// ```dart
/// if (canBack) back();
/// ```
bool get canBack => VoxRouter.canBack;
