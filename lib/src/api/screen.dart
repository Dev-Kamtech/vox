/// Screen API — VoxScreen base class and voxApp entry point.
library;

export '../core/screen/vox_screen.dart' show VoxScreen;

import '../core/app/vox_app.dart' as core;
import '../core/screen/vox_screen.dart';
import '../core/theme/theme_engine.dart';

/// The app entry point. Replaces `void main() => runApp(...)`.
///
/// Handles MaterialApp, binding, reactive theming, and navigation — all silent.
///
/// ```dart
/// void main() => voxApp(
///   title: 'My App',
///   home: HomeScreen(),
///   theme: VoxTheme(
///     primary:    Color(0xFF6C63FF),
///     background: Color(0xFFF5F5F5),
///     surface:    Colors.white,
///     text:       Color(0xFF1A1A2E),
///     radius:     12,
///     dark: VoxTheme.dark(),
///   ),
///   init: () async {
///     await VoxDeviceInfo.init();
///   },
/// );
/// ```
void voxApp({
  required VoxScreen home,
  String title = '',
  VoxTheme? theme,
  bool debugBanner = false,
  Future<void> Function()? init,
}) {
  core.voxAppRunner(
    home: home,
    title: title,
    voxTheme: theme,
    debugBanner: debugBanner,
    init: init,
  );
}
