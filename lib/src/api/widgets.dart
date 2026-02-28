/// Widgets API — widget shortcuts.
///
/// ```dart
/// label('Hello').bold.size(24)
/// btn('Save').onTap(() => save())
/// icon(Icons.star)
/// progress(0.75, color: _kPrimary, height: 6)
/// ring(null, size: 32)
/// fab(Icons.add, () => go(NewScreen()))
/// tile('Profile', leading: icon(Icons.person), padH: 16, onTap: () => go(ProfileScreen()))
/// switchTile('Dark mode', isDark, (_) => vox.theme.toggle(), padH: 16)
/// ```
library;

import 'package:flutter/material.dart';

import '../core/ui/widgets.dart' as core;

export '../core/ui/widgets.dart' show VoxLabel, VoxButton;

// ---------------------------------------------------------------------------
// Internal — padding resolver (same helper as api/layout.dart)
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
// Text / labels
// ---------------------------------------------------------------------------

/// Text label.
core.VoxLabel label(String text) => core.VoxLabel(text);

/// Button.
core.VoxButton btn(String text) => core.VoxButton(text);

// ---------------------------------------------------------------------------
// Basic widgets
// ---------------------------------------------------------------------------

/// Square spacing box (equal width + height).
Widget space(double size) => core.voxSpace(size);

/// Icon.
Widget icon(IconData data, {double? size, Color? color}) =>
    core.voxIcon(data, size: size, color: color);

/// Image — auto-detects network URL vs asset path.
///
/// ```dart
/// img('https://...', height: 200, fit: BoxFit.cover)
/// img('assets/hero.png', width: double.infinity)
/// ```
Widget img(String source, {double? width, double? height, BoxFit? fit}) =>
    core.voxImg(source, width: width, height: height, fit: fit);

/// Loading spinner.
Widget loader({double? size, Color? color}) =>
    core.voxLoader(size: size, color: color);

/// Horizontal divider line.
Widget get divider => core.voxDivider;

// ---------------------------------------------------------------------------
// Conditional rendering
// ---------------------------------------------------------------------------

/// Show [child] only when [condition] is true.
Widget when(bool condition, Widget child) => core.voxWhen(condition, child);

/// Show [child] only when [condition] is false.
Widget whenNot(bool condition, Widget child) =>
    core.voxWhenNot(condition, child);

/// Toggle between two widgets.
Widget toggle(bool condition, Widget onTrue, Widget onFalse) =>
    core.voxToggle(condition, onTrue, onFalse);

// ---------------------------------------------------------------------------
// widget() — inline builder
// ---------------------------------------------------------------------------

/// Create a widget from a function — no class, no BuildContext.
///
/// ```dart
/// widget(() => label('Hello').bg(_kSurface).round(8))
/// ```
Widget widget(Widget Function() build) => core.voxWidget(build);

// ---------------------------------------------------------------------------
// Progress / loading
// ---------------------------------------------------------------------------

/// Horizontal progress bar (0.0–1.0). Null = indeterminate.
///
/// ```dart
/// progress(0.75, color: _kPrimary, bg: _kSurface, height: 6).round(4)
/// progress(null, color: _kPrimary)
/// ```
Widget progress(
  double? value, {
  Color? color,
  Color? bg,
  double height = 4,
}) =>
    core.voxProgress(value, color: color, bg: bg, height: height);

/// Circular progress indicator. Null = spinning indefinitely.
///
/// ```dart
/// ring(0.6, size: 48, color: _kPrimary, width: 5)
/// ring(null, size: 24)
/// ```
Widget ring(
  double? value, {
  double? size,
  Color? color,
  Color? bg,
  double width = 4,
}) =>
    core.voxRing(value, size: size, color: color, bg: bg, width: width);

// ---------------------------------------------------------------------------
// fab() — Floating action button
// ---------------------------------------------------------------------------

/// Floating action button. Pass [label] for extended FAB.
///
/// ```dart
/// fab(Icons.add, () => go(NewScreen()), color: _kPrimary)
/// fab(Icons.add, () => submit(), label: 'New Post')
/// ```
Widget fab(
  IconData ico,
  VoidCallback onTap, {
  Color? color,
  Color? iconColor,
  String? label,
}) =>
    core.voxFab(ico, onTap, color: color, iconColor: iconColor, label: label);

// ---------------------------------------------------------------------------
// switchTile() — toggle list tile. No EdgeInsets, just numbers.
// ---------------------------------------------------------------------------

/// A list tile with a toggle switch.
///
/// Padding accepts plain numbers — no EdgeInsets needed.
///
/// ```dart
/// switchTile('Dark mode', isDark, (_) => vox.theme.toggle())
/// switchTile('Notifications', on, (v) => setNotifs(v),
///   subtitle: 'Receive push notifications',
///   padH: 16)
/// ```
Widget switchTile(
  String label,
  bool value,
  void Function(bool) onChange, {
  String? subtitle,
  Color? activeColor,
  double? pad,
  double? padH,
  double? padV,
  double? padTop,
  double? padBottom,
  double? padLeft,
  double? padRight,
}) =>
    core.voxSwitchTile(
      label,
      value,
      onChange,
      subtitle: subtitle,
      activeColor: activeColor,
      padding: _edge(
        pad: pad, padH: padH, padV: padV,
        padTop: padTop, padBottom: padBottom,
        padLeft: padLeft, padRight: padRight,
      ),
    );

// ---------------------------------------------------------------------------
// tile() — list tile. No EdgeInsets, just numbers.
// ---------------------------------------------------------------------------

/// A single-row list item.
///
/// Padding accepts plain numbers — no EdgeInsets needed.
///
/// ```dart
/// tile('Profile', leading: icon(Icons.person), onTap: () => go(ProfileScreen()))
/// tile('Logout', titleColor: _kDanger, padH: 16, onTap: logout)
/// tile(user.name, subtitle: user.email, trailing: icon(Icons.chevron_right))
/// ```
Widget tile(
  String title, {
  Widget? leading,
  String? subtitle,
  Widget? trailing,
  VoidCallback? onTap,
  Color? titleColor,
  FontWeight? titleWeight,
  TextDecoration? titleDecoration,
  Color? subtitleColor,
  double? pad,
  double? padH,
  double? padV,
  double? padTop,
  double? padBottom,
  double? padLeft,
  double? padRight,
}) =>
    core.voxTile(
      title,
      leading: leading,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      titleColor: titleColor,
      titleWeight: titleWeight,
      titleDecoration: titleDecoration,
      subtitleColor: subtitleColor,
      padding: _edge(
        pad: pad, padH: padH, padV: padV,
        padTop: padTop, padBottom: padBottom,
        padLeft: padLeft, padRight: padRight,
      ),
    );
