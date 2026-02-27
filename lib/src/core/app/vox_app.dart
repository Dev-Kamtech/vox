import 'package:flutter/material.dart';

import '../screen/vox_screen.dart';

/// The internal app runner. Called by [voxApp] in the API layer.
///
/// Wraps [runApp] + [MaterialApp] with sensible defaults.
/// Handles binding initialization, theme, and navigation setup.
void voxAppRunner({
  required VoxScreen home,
  String title = '',
  ThemeData? theme,
  ThemeData? darkTheme,
  ThemeMode? themeMode,
  Map<String, Widget Function()>? routes,
  bool debugBanner = false,
}) {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    title: title,
    theme: theme ?? ThemeData.light(useMaterial3: true),
    darkTheme: darkTheme,
    themeMode: themeMode ?? ThemeMode.system,
    debugShowCheckedModeBanner: debugBanner,
    home: home.toWidget(),
  ));
}
