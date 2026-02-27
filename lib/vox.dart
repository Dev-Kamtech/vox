/// Vox — One import. Full power. Write logic, not Flutter.
///
/// ```dart
/// import 'package:vox/vox.dart';
/// ```
///
/// That's it. State, UI, networking, navigation, storage, forms,
/// animations, permissions, theming — all included.
library;

// ── Re-export Flutter so devs never need to import it separately ──
export 'package:flutter/material.dart' hide State, Theme;

// ── API Layer (what developers write) ──
export 'src/api/state.dart';
export 'src/api/screen.dart';
export 'src/api/widget.dart';
export 'src/api/layout.dart';
export 'src/api/widgets.dart';
export 'src/api/extensions.dart';
export 'src/api/net.dart';
export 'src/api/nav.dart';
export 'src/api/storage.dart';
export 'src/api/forms.dart';
export 'src/api/animation.dart';
export 'src/api/permissions.dart';
export 'src/api/theme.dart';
export 'src/api/device.dart';
export 'src/api/overlay.dart';
export 'src/api/toast.dart';
export 'src/api/tabs.dart';
export 'src/api/drawer.dart';
export 'src/api/di.dart';
export 'src/api/config.dart';
export 'src/api/locale.dart';
export 'src/api/realtime.dart';
export 'src/api/log.dart';
export 'src/api/timer.dart';
export 'src/api/picker.dart';
export 'src/api/clipboard.dart';
export 'src/api/share.dart';
export 'src/api/model.dart';
