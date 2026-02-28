import 'package:flutter/material.dart';

import '../nav/router.dart';
import '../screen/vox_screen.dart';
import '../theme/theme_engine.dart';

/// The internal app runner. Called by [voxApp] in the API layer.
///
/// Wraps [runApp] + [MaterialApp] with sensible defaults, reactive theming,
/// and optional async initialization.
void voxAppRunner({
  required VoxScreen home,
  String title = '',
  VoxTheme? voxTheme,
  bool debugBanner = false,
  Future<void> Function()? init,
}) {
  WidgetsFlutterBinding.ensureInitialized();

  if (voxTheme != null) {
    VoxThemeController.instance.configure(voxTheme);
  }

  runApp(ListenableBuilder(
    listenable: VoxThemeController.instance,
    builder: (_, __) {
      final ctrl = VoxThemeController.instance;
      return MaterialApp(
        navigatorKey: VoxRouter.key,
        title: title,
        theme: ctrl.lightTheme,
        darkTheme: ctrl.darkTheme,
        themeMode: ctrl.mode,
        debugShowCheckedModeBanner: debugBanner,
        home: home.toWidget(),
      );
    },
  ));

  // Run async init after the first frame so the app is visible while loading.
  if (init != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }
}
