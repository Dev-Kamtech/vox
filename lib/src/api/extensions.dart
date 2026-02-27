/// Widget extensions — chainable modifiers for any Widget.
///
/// ```dart
/// label('Hello')
///   .bold.size(24)       // text-specific (VoxLabel methods)
///   .pad(all: 16)        // padding (extension)
///   .bg(Colors.blue)     // background (extension)
///   .round(8)            // corner radius (extension)
///   .center              // centering (extension)
///   .expand              // fill available space (extension)
/// ```
library;

import 'package:flutter/material.dart';

import '../core/animation/animator.dart';
import '../core/ui/layout.dart';

// ---------------------------------------------------------------------------
// List<Widget> extensions — convert widget lists into layout primitives
// ---------------------------------------------------------------------------

/// Convenience extensions for converting a [List<Widget>] into a layout.
///
/// Used primarily with [VoxListState.each]:
/// ```dart
/// todos.each((t) => label(t.title)).col        // Column
/// todos.each((t) => label(t.title)).col.gap(8) // Column with spacing
/// todos.each((t) => chip(t)).row               // Row
/// todos.each((t) => card(t)).stack             // Stack
/// ```
extension VoxListWidgetExtensions on List<Widget> {
  /// Wrap this list in a [VoxColumn].
  VoxColumn get col => VoxColumn(this);

  /// Wrap this list in a [VoxRow].
  VoxRow get row => VoxRow(this);

  /// Wrap this list in a [Stack].
  Widget get stack => Stack(children: this);
}

/// Chainable modifiers on any [Widget].
extension VoxWidgetExtensions on Widget {
  // ---------------------------------------------------------------------------
  // Padding
  // ---------------------------------------------------------------------------

  /// Add padding. Use named params: `pad(all: 16)`, `pad(h: 32, v: 8)`.
  Widget pad({
    double? all,
    double? h,
    double? v,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: top ?? v ?? all ?? 0,
        bottom: bottom ?? v ?? all ?? 0,
        left: left ?? h ?? all ?? 0,
        right: right ?? h ?? all ?? 0,
      ),
      child: this,
    );
  }

  /// Padding top only.
  Widget padTop(double v) =>
      Padding(padding: EdgeInsets.only(top: v), child: this);

  /// Padding bottom only.
  Widget padBottom(double v) =>
      Padding(padding: EdgeInsets.only(bottom: v), child: this);

  /// Padding left only.
  Widget padLeft(double v) =>
      Padding(padding: EdgeInsets.only(left: v), child: this);

  /// Padding right only.
  Widget padRight(double v) =>
      Padding(padding: EdgeInsets.only(right: v), child: this);

  // ---------------------------------------------------------------------------
  // Sizing
  // ---------------------------------------------------------------------------

  /// Set width.
  Widget w(double width) => SizedBox(width: width, child: this);

  /// Set height.
  Widget h(double height) => SizedBox(height: height, child: this);

  /// Set both width and height.
  Widget sized(double w, double h) => SizedBox(width: w, height: h, child: this);

  // ---------------------------------------------------------------------------
  // Layout
  // ---------------------------------------------------------------------------

  /// Fill available space in a row/column.
  Widget get expand => Expanded(child: this);

  /// Expand with a specific flex factor.
  Widget flex(int factor) => Expanded(flex: factor, child: this);

  /// Center this widget.
  Widget get center => Center(child: this);

  /// Make scrollable.
  Widget get scrollable => SingleChildScrollView(child: this);

  // ---------------------------------------------------------------------------
  // Visibility
  // ---------------------------------------------------------------------------

  /// Hide when [condition] is true.
  Widget hide(bool condition) =>
      condition ? const SizedBox.shrink() : this;

  /// Show only when [condition] is true.
  Widget show(bool condition) =>
      condition ? this : const SizedBox.shrink();

  /// Animate visibility with opacity.
  Widget opacity(double value) => Opacity(opacity: value, child: this);

  // ---------------------------------------------------------------------------
  // Decoration
  // ---------------------------------------------------------------------------

  /// Set background color.
  Widget bg(Color color) => ColoredBox(color: color, child: this);

  /// Round corners.
  Widget round(double radius) =>
      ClipRRect(borderRadius: BorderRadius.circular(radius), child: this);

  /// Add a shadow.
  Widget shadow({
    Color? color,
    double blur = 4,
    Offset offset = Offset.zero,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color ?? Colors.black26,
            blurRadius: blur,
            offset: offset,
          ),
        ],
      ),
      child: this,
    );
  }

  /// Add a border.
  Widget border(Color color, {double width = 1, double? radius}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: width),
        borderRadius: radius != null ? BorderRadius.circular(radius) : null,
      ),
      child: this,
    );
  }

  // ---------------------------------------------------------------------------
  // Interaction
  // ---------------------------------------------------------------------------

  /// Handle taps.
  Widget tap(VoidCallback callback) =>
      GestureDetector(onTap: callback, child: this);

  /// Handle long press.
  Widget onLong(VoidCallback callback) =>
      GestureDetector(onLongPress: callback, child: this);

  /// Ink splash effect on tap (Material ripple).
  Widget inkTap(VoidCallback callback) =>
      InkWell(onTap: callback, child: this);

  // ---------------------------------------------------------------------------
  // Alignment
  // ---------------------------------------------------------------------------

  /// Align within parent.
  Widget alignTo(AlignmentGeometry alignment) =>
      Align(alignment: alignment, child: this);

  /// Align to top-left.
  Widget get topLeft => Align(alignment: Alignment.topLeft, child: this);

  /// Align to top-right.
  Widget get topRight => Align(alignment: Alignment.topRight, child: this);

  /// Align to bottom-left.
  Widget get bottomLeft =>
      Align(alignment: Alignment.bottomLeft, child: this);

  /// Align to bottom-right.
  Widget get bottomRight =>
      Align(alignment: Alignment.bottomRight, child: this);

  // ---------------------------------------------------------------------------
  // Clipping
  // ---------------------------------------------------------------------------

  /// Clip to a circle.
  Widget get circle => ClipOval(child: this);

  /// Clip to rectangle with optional radius.
  Widget clip({double radius = 0}) => ClipRRect(
      borderRadius: BorderRadius.circular(radius), child: this);

  // ---------------------------------------------------------------------------
  // Constraints
  // ---------------------------------------------------------------------------

  /// Set maximum width.
  Widget maxW(double width) =>
      ConstrainedBox(constraints: BoxConstraints(maxWidth: width), child: this);

  /// Set maximum height.
  Widget maxH(double height) =>
      ConstrainedBox(
          constraints: BoxConstraints(maxHeight: height), child: this);

  /// Set minimum width.
  Widget minW(double width) =>
      ConstrainedBox(constraints: BoxConstraints(minWidth: width), child: this);

  /// Set minimum height.
  Widget minH(double height) =>
      ConstrainedBox(
          constraints: BoxConstraints(minHeight: height), child: this);

  // ---------------------------------------------------------------------------
  // Animation
  // ---------------------------------------------------------------------------

  /// Play a one-shot enter animation on first mount.
  ///
  /// Use the built-in presets: [fade], [scale], [slide.fromBottom], etc.
  ///
  /// ```dart
  /// label("Hello").animate(fade)
  /// label("Hello").animate(slide.fromBottom).duration(200)
  /// card.animate(scale)
  /// ```
  VoxAnimatedWidget animate(VoxAnimPreset preset) =>
      VoxAnimatedWidget(preset: preset, child: this);

  // ---------------------------------------------------------------------------
  // Hero
  // ---------------------------------------------------------------------------

  /// Wrap with a [Hero] for shared-element transitions between routes.
  ///
  /// [tag] must be unique per hero pair. Matching tags animate between screens.
  ///
  /// ```dart
  /// img("avatar.png").hero("user-avatar")
  /// label(product.name).hero("product-title-${product.id}")
  /// ```
  Widget hero(Object tag) => Hero(tag: tag, child: this);
}
