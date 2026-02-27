/// Vox Lite — State + UI only. No native dependencies.
///
/// ```dart
/// import 'package:vox/lite.dart';
/// ```
///
/// Use this for minimal apps that only need state management
/// and UI primitives without native platform dependencies.
library;

// ── Re-export Flutter ──
export 'package:flutter/material.dart' hide State, Theme;

// ── Core UI + State only ──
export 'src/api/state.dart';
export 'src/api/screen.dart';
export 'src/api/widget.dart';
export 'src/api/layout.dart';
export 'src/api/widgets.dart';
export 'src/api/extensions.dart';
export 'src/api/theme.dart';
export 'src/api/di.dart';
export 'src/api/log.dart';
export 'src/api/timer.dart';
export 'src/api/model.dart';
