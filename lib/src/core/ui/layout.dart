import 'package:flutter/material.dart';

import '../drawer/drawer_engine.dart';

// ---------------------------------------------------------------------------
// col() → VoxColumn
// ---------------------------------------------------------------------------

/// A vertical layout. Wraps [Column] with chainable layout options.
///
/// Returns a [StatelessWidget] so `.gap()`, `.align()`, `.cross()` etc.
/// can be called before widget extensions like `.pad()`.
class VoxColumn extends StatelessWidget {
  final List<Widget> children;
  final double? _gap;
  final MainAxisAlignment _mainAxis;
  final CrossAxisAlignment _crossAxis;
  final MainAxisSize _mainSize;

  const VoxColumn(
    this.children, {
    super.key,
    double? gap,
    MainAxisAlignment mainAxis = MainAxisAlignment.start,
    CrossAxisAlignment crossAxis = CrossAxisAlignment.center,
    MainAxisSize mainSize = MainAxisSize.min,
  })  : _gap = gap,
        _mainAxis = mainAxis,
        _crossAxis = crossAxis,
        _mainSize = mainSize;

  /// Add spacing between children.
  VoxColumn gap(double value) => VoxColumn(children,
      gap: value, mainAxis: _mainAxis, crossAxis: _crossAxis, mainSize: _mainSize);

  /// Set main axis alignment.
  VoxColumn align(MainAxisAlignment a) => VoxColumn(children,
      gap: _gap, mainAxis: a, crossAxis: _crossAxis, mainSize: _mainSize);

  /// Set cross axis alignment.
  VoxColumn cross(CrossAxisAlignment a) => VoxColumn(children,
      gap: _gap, mainAxis: _mainAxis, crossAxis: a, mainSize: _mainSize);

  /// Space children evenly along the main axis.
  VoxColumn get between => align(MainAxisAlignment.spaceBetween);

  /// Space children with equal space around each.
  VoxColumn get evenly => align(MainAxisAlignment.spaceEvenly);

  /// Make column take all available vertical space.
  VoxColumn get stretched => VoxColumn(children,
      gap: _gap, mainAxis: _mainAxis, crossAxis: _crossAxis, mainSize: MainAxisSize.max);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: _mainAxis,
      crossAxisAlignment: _crossAxis,
      mainAxisSize: _mainSize,
      children: _gap != null && _gap > 0
          ? _insertGaps(children, _gap, vertical: true)
          : children,
    );
  }
}

// ---------------------------------------------------------------------------
// row() → VoxRow
// ---------------------------------------------------------------------------

/// A horizontal layout. Wraps [Row] with chainable layout options.
class VoxRow extends StatelessWidget {
  final List<Widget> children;
  final double? _gap;
  final MainAxisAlignment _mainAxis;
  final CrossAxisAlignment _crossAxis;
  final MainAxisSize _mainSize;

  const VoxRow(
    this.children, {
    super.key,
    double? gap,
    MainAxisAlignment mainAxis = MainAxisAlignment.start,
    CrossAxisAlignment crossAxis = CrossAxisAlignment.center,
    MainAxisSize mainSize = MainAxisSize.min,
  })  : _gap = gap,
        _mainAxis = mainAxis,
        _crossAxis = crossAxis,
        _mainSize = mainSize;

  VoxRow gap(double value) => VoxRow(children,
      gap: value, mainAxis: _mainAxis, crossAxis: _crossAxis, mainSize: _mainSize);

  VoxRow align(MainAxisAlignment a) => VoxRow(children,
      gap: _gap, mainAxis: a, crossAxis: _crossAxis, mainSize: _mainSize);

  VoxRow cross(CrossAxisAlignment a) => VoxRow(children,
      gap: _gap, mainAxis: _mainAxis, crossAxis: a, mainSize: _mainSize);

  VoxRow get between => align(MainAxisAlignment.spaceBetween);
  VoxRow get evenly => align(MainAxisAlignment.spaceEvenly);

  VoxRow get stretched => VoxRow(children,
      gap: _gap, mainAxis: _mainAxis, crossAxis: _crossAxis, mainSize: MainAxisSize.max);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: _mainAxis,
      crossAxisAlignment: _crossAxis,
      mainAxisSize: _mainSize,
      children: _gap != null && _gap > 0
          ? _insertGaps(children, _gap, vertical: false)
          : children,
    );
  }
}

// ---------------------------------------------------------------------------
// screen() → Scaffold + AppBar
// ---------------------------------------------------------------------------

/// Creates a screen layout with an AppBar and body.
///
/// Pass [drawer] (created via `drawer([...])`) to add a side navigation drawer.
/// When a drawer is present, the Scaffold is registered with
/// [VoxDrawerController] so `openDrawer()` / `closeDrawer()` work globally.
Widget screenLayout(
  String title,
  Widget body, {
  List<Widget>? actions,
  VoxDrawer? drawer,
  Widget? floatingActionButton,
}) {
  return Scaffold(
    key: drawer != null ? VoxDrawerController.scaffoldKey : null,
    appBar: AppBar(
      title: Text(title),
      actions: actions,
    ),
    drawer: drawer,
    floatingActionButton: floatingActionButton,
    body: SafeArea(child: body),
  );
}

// ---------------------------------------------------------------------------
// stack() → Stack
// ---------------------------------------------------------------------------

/// Layers children on top of each other.
Widget voxStack(List<Widget> children, {AlignmentGeometry? alignment}) {
  return Stack(
    alignment: alignment ?? AlignmentDirectional.topStart,
    children: children,
  );
}

// ---------------------------------------------------------------------------
// scroll() → SingleChildScrollView + Column
// ---------------------------------------------------------------------------

/// A scrollable vertical list of children.
Widget voxScroll(List<Widget> children) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}

// ---------------------------------------------------------------------------
// grid() → GridView
// ---------------------------------------------------------------------------

/// A grid layout with [cols] columns.
Widget voxGrid(int cols, List<Widget> children, {double spacing = 0}) {
  return GridView.count(
    crossAxisCount: cols,
    mainAxisSpacing: spacing,
    crossAxisSpacing: spacing,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    children: children,
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<Widget> _insertGaps(List<Widget> children, double gap,
    {required bool vertical}) {
  if (children.isEmpty) return children;
  final result = <Widget>[];
  for (var i = 0; i < children.length; i++) {
    result.add(children[i]);
    if (i < children.length - 1) {
      result.add(vertical
          ? SizedBox(height: gap)
          : SizedBox(width: gap));
    }
  }
  return result;
}
