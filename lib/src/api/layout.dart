/// Layout API — layout primitives and structural widgets.
///
/// ```dart
/// col([label('A'), label('B')]).gap(16)
/// row([btn('Cancel'), btn('OK')]).between
/// scaffold(safe(col([header, body.expand])), bg: _kBg)
/// card(content, color: _kSurface, radius: 16, pad: 16)
/// list(items, (item, i) => _tile(item), padH: 16, padBottom: 90)
/// hscroll([chip1, chip2, chip3], padH: 16)
/// ```
library;

import 'package:flutter/material.dart';

import '../core/drawer/drawer_engine.dart';
import '../core/ui/layout.dart' as core;

export '../core/ui/layout.dart' show VoxColumn, VoxRow;

// ---------------------------------------------------------------------------
// Internal — padding resolver (developers never see EdgeInsets)
// ---------------------------------------------------------------------------

EdgeInsets? _edge({
  double? pad,
  double? padH,
  double? padV,
  double? padTop,
  double? padBottom,
  double? padLeft,
  double? padRight,
}) {
  if (pad == null && padH == null && padV == null &&
      padTop == null && padBottom == null &&
      padLeft == null && padRight == null) { return null; }
  return EdgeInsets.only(
    top:    padTop    ?? padV ?? pad ?? 0,
    bottom: padBottom ?? padV ?? pad ?? 0,
    left:   padLeft   ?? padH ?? pad ?? 0,
    right:  padRight  ?? padH ?? pad ?? 0,
  );
}

// ---------------------------------------------------------------------------
// Core layouts
// ---------------------------------------------------------------------------

/// Vertical layout (column).
core.VoxColumn col(List<Widget> children) => core.VoxColumn(children);

/// Horizontal layout (row).
core.VoxRow row(List<Widget> children) => core.VoxRow(children);

/// Fill all remaining space in a row or column. Reads like intent.
///
/// ```dart
/// row([label('Title').expand, icon(Icons.close)])
/// col([header, content.expand, footer])
/// ```
Widget get spacer => const Spacer();

/// Screen with AppBar + body. Use [scaffold] for full layout control.
Widget screen(
  String title,
  Widget body, {
  List<Widget>? actions,
  VoxDrawer? drawer,
  Widget? floatingActionButton,
}) =>
    core.screenLayout(
      title,
      body,
      actions: actions,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
    );

/// Bare scaffold — no AppBar, full layout control.
///
/// ```dart
/// scaffold(
///   safe(col([_header, content.expand])),
///   bg: _kBg,
///   fab: fab(Icons.add, () => go(NewScreen())),
///   nav: _bottomNav,
/// )
/// ```
Widget scaffold(
  Widget body, {
  Color? bg,
  Widget? fab,
  Widget? nav,
  Widget? drawer,
}) =>
    core.voxScaffold(body, bg: bg, fab: fab, nav: nav, drawer: drawer);

/// Wrap in a SafeArea (avoids notch, status bar, home indicator).
///
/// ```dart
/// safe(content)
/// safe(bottomNav, top: false)
/// ```
Widget safe(
  Widget child, {
  bool top = true,
  bool bottom = true,
  bool left = true,
  bool right = true,
}) =>
    core.voxSafe(child, top: top, bottom: bottom, left: left, right: right);

/// Vertical spacing box.
/// ```dart
/// gap(16)
/// ```
Widget gap(double size) => core.voxGap(size);

/// Horizontal spacing box.
/// ```dart
/// hgap(12)
/// ```
Widget hgap(double size) => core.voxHGap(size);

// ---------------------------------------------------------------------------
// card() — styled container. No EdgeInsets, just numbers.
// ---------------------------------------------------------------------------

/// A styled box with color, border, and radius.
///
/// Padding accepts plain numbers — no EdgeInsets needed.
///
/// ```dart
/// card(content)                                    // defaults
/// card(content, color: _kSurface, radius: 16)      // style
/// card(content, pad: 16)                           // all sides
/// card(content, padH: 20, padV: 12)                // h/v
/// card(content, padLeft: 16, padTop: 12, padBottom: 90) // individual
/// card(content, borderColor: _kBorder, borderWidth: 1.5)
/// ```
Widget card(
  Widget child, {
  Color? color,
  double radius = 12,
  Color? borderColor,
  double borderWidth = 1,
  double? pad,
  double? padH,
  double? padV,
  double? padTop,
  double? padBottom,
  double? padLeft,
  double? padRight,
}) =>
    core.voxCard(
      child,
      color: color,
      radius: radius,
      borderColor: borderColor,
      borderWidth: borderWidth,
      padding: _edge(
        pad: pad, padH: padH, padV: padV,
        padTop: padTop, padBottom: padBottom,
        padLeft: padLeft, padRight: padRight,
      ),
    );

// ---------------------------------------------------------------------------
// list() — lazily-built scrollable list. No EdgeInsets, just numbers.
// ---------------------------------------------------------------------------

/// A scrollable, lazily-built list from data items.
///
/// ```dart
/// list(users, (user, i) => _tile(user))
/// list(posts, (post, i) => _card(post), padH: 16, padBottom: 90)
/// list(items, (item, i) => _row(item), pad: 16, shrink: true)
/// ```
Widget list<T>(
  List<T> items,
  Widget Function(T item, int index) builder, {
  double? pad,
  double? padH,
  double? padV,
  double? padTop,
  double? padBottom,
  double? padLeft,
  double? padRight,
  bool shrink = false,
  bool reverse = false,
}) =>
    core.voxList<T>(
      items,
      builder,
      padding: _edge(
        pad: pad, padH: padH, padV: padV,
        padTop: padTop, padBottom: padBottom,
        padLeft: padLeft, padRight: padRight,
      ),
      shrink: shrink,
      reverse: reverse,
    );

// ---------------------------------------------------------------------------
// hscroll() — horizontal scrollable row. No EdgeInsets, just numbers.
// ---------------------------------------------------------------------------

/// A horizontally scrollable row of children.
///
/// ```dart
/// hscroll([chip1, chip2, chip3], padH: 16)
/// hscroll(categories.map(_chip).toList(), padLeft: 16, padBottom: 8)
/// ```
Widget hscroll(
  List<Widget> children, {
  double? pad,
  double? padH,
  double? padV,
  double? padTop,
  double? padBottom,
  double? padLeft,
  double? padRight,
}) =>
    SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: _edge(
        pad: pad, padH: padH, padV: padV,
        padTop: padTop, padBottom: padBottom,
        padLeft: padLeft, padRight: padRight,
      ),
      child: core.VoxRow(children),
    );

// ---------------------------------------------------------------------------
// Remaining layout primitives
// ---------------------------------------------------------------------------

/// Show one widget at a time, preserving all others' state.
///
/// ```dart
/// indexed(_tab.val, [HomeTab(), SearchTab(), ProfileTab()])
/// ```
Widget indexed(int current, List<Widget> children) =>
    core.voxIndexed(current, children);

/// Wrap in Expanded (fills remaining space inside col/row).
Widget expanded(Widget child, {int flex = 1}) =>
    core.voxExpanded(child, flex: flex);

/// Swipe-to-dismiss (right → left). Calls [onSwipe] when dismissed.
///
/// ```dart
/// swipeable(item.id, _tile(item), () => remove(item.id),
///   bg: card(icon(Icons.delete, color: _kDanger).bottomRight.padRight(20),
///            color: Color(0x26FF0000), radius: 12))
/// ```
Widget swipeable(
  String id,
  Widget child,
  VoidCallback onSwipe, {
  Widget? bg,
}) =>
    core.voxSwipeable(id, child, onSwipe, bg: bg);

/// Layered layout (stack).
Widget stack(List<Widget> children, {AlignmentGeometry? alignment}) =>
    core.voxStack(children, alignment: alignment);

/// Scrollable vertical layout.
Widget scroll(List<Widget> children) => core.voxScroll(children);

/// Grid layout with [cols] columns.
Widget grid(int cols, List<Widget> children, {double spacing = 0}) =>
    core.voxGrid(cols, children, spacing: spacing);
