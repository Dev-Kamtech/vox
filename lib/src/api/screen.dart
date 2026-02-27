/// Screen API — VoxScreen base class and voxApp entry point.
library;

export '../core/screen/vox_screen.dart' show VoxScreen;

import 'package:flutter/material.dart';

import '../core/app/vox_app.dart' as core;
import '../core/screen/vox_screen.dart';

/// The app entry point. Replaces `void main() => runApp(...)`.
///
/// Handles MaterialApp, binding, theme, and navigation — all silent.
///
/// ```dart
/// void main() => voxApp(
///   title: 'My App',
///   home: HomeScreen(),
/// );
/// ```
void voxApp({
  required VoxScreen home,
  String title = '',
  ThemeData? theme,
  ThemeData? darkTheme,
  ThemeMode? themeMode,
  Map<String, Widget Function()>? routes,
  bool debugBanner = false,
}) {
  core.voxAppRunner(
    home: home,
    title: title,
    theme: theme,
    darkTheme: darkTheme,
    themeMode: themeMode,
    routes: routes,
    debugBanner: debugBanner,
  );
}
