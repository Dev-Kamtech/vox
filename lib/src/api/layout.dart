/// Layout API — layout primitives.
///
/// ```dart
/// col([label('A'), label('B')]).gap(16)
/// row([btn('Cancel'), btn('OK')]).between
/// screen('Title', content)
/// ```
library;

import 'package:flutter/material.dart';

import '../core/ui/layout.dart' as core;

export '../core/ui/layout.dart' show VoxColumn, VoxRow;

/// Vertical layout (column).
core.VoxColumn col(List<Widget> children) => core.VoxColumn(children);

/// Horizontal layout (row).
core.VoxRow row(List<Widget> children) => core.VoxRow(children);

/// Screen layout with AppBar + body.
Widget screen(String title, Widget body, {List<Widget>? actions}) =>
    core.screenLayout(title, body, actions: actions);

/// Layered layout (stack).
Widget stack(List<Widget> children, {AlignmentGeometry? alignment}) =>
    core.voxStack(children, alignment: alignment);

/// Scrollable vertical layout.
Widget scroll(List<Widget> children) => core.voxScroll(children);

/// Grid layout with [cols] columns.
Widget grid(int cols, List<Widget> children, {double spacing = 0}) =>
    core.voxGrid(cols, children, spacing: spacing);
