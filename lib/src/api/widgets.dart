/// Widgets API — widget shortcuts.
///
/// ```dart
/// label('Hello').bold.size(24)
/// btn('Save').onTap(() => save())
/// icon(Icons.star)
/// ```
library;

import 'package:flutter/material.dart';

import '../core/ui/widgets.dart' as core;

export '../core/ui/widgets.dart' show VoxLabel, VoxButton;

/// Text label.
core.VoxLabel label(String text) => core.VoxLabel(text);

/// Button.
core.VoxButton btn(String text) => core.VoxButton(text);

/// Spacing box.
Widget space(double size) => core.voxSpace(size);

/// Icon.
Widget icon(IconData data, {double? size, Color? color}) =>
    core.voxIcon(data, size: size, color: color);

/// Image (auto-detects network vs asset).
Widget img(String source, {double? width, double? height, BoxFit? fit}) =>
    core.voxImg(source, width: width, height: height, fit: fit);

/// Loading spinner.
Widget loader({double? size, Color? color}) =>
    core.voxLoader(size: size, color: color);

/// Horizontal divider.
Widget get divider => core.voxDivider;

/// Show [child] only when [condition] is true.
Widget when(bool condition, Widget child) => core.voxWhen(condition, child);

/// Show [child] only when [condition] is false.
Widget whenNot(bool condition, Widget child) =>
    core.voxWhenNot(condition, child);

/// Toggle between two widgets.
Widget toggle(bool condition, Widget onTrue, Widget onFalse) =>
    core.voxToggle(condition, onTrue, onFalse);
