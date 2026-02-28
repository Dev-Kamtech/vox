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

  /// Center children along the main axis.
  VoxColumn get centered => align(MainAxisAlignment.center);

  /// Align children to the left (cross axis start).
  VoxColumn get left => cross(CrossAxisAlignment.start);

  /// Align children to the right (cross axis end).
  VoxColumn get right => cross(CrossAxisAlignment.end);

  /// Stretch children to fill full width.
  VoxColumn get fill => cross(CrossAxisAlignment.stretch);

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
  VoxRow get centered => align(MainAxisAlignment.center);

  /// Align children to the top (cross axis start).
  VoxRow get top => cross(CrossAxisAlignment.start);

  /// Align children to the bottom (cross axis end).
  VoxRow get bottom => cross(CrossAxisAlignment.end);

  /// Stretch children to fill full height.
  VoxRow get fill => cross(CrossAxisAlignment.stretch);

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
// gap() / hgap() — spacing boxes
// ---------------------------------------------------------------------------

/// Vertical gap — SizedBox with height only.
Widget voxGap(double size) => SizedBox(height: size);

/// Horizontal gap — SizedBox with width only.
Widget voxHGap(double size) => SizedBox(width: size);

// ---------------------------------------------------------------------------
// safe() — SafeArea
// ---------------------------------------------------------------------------

/// Wrap in a SafeArea. Avoids OS notch / status bar / home indicator.
Widget voxSafe(
  Widget child, {
  bool top = true,
  bool bottom = true,
  bool left = true,
  bool right = true,
}) =>
    SafeArea(
        top: top, bottom: bottom, left: left, right: right, child: child);

// ---------------------------------------------------------------------------
// scaffold() — bare Scaffold
// ---------------------------------------------------------------------------

/// Bare scaffold without an AppBar. Full layout control.
///
/// ```dart
/// scaffold(
///   safe(col([header, content.expand])),
///   bg: _kBg,
///   fab: fab(Icons.add, () => go(AddScreen())),
///   nav: _bottomNav,
/// )
/// ```
Widget voxScaffold(
  Widget body, {
  Color? bg,
  Widget? fab,
  Widget? nav,
  Widget? drawer,
}) =>
    Scaffold(
      backgroundColor: bg,
      body: body,
      floatingActionButton: fab,
      bottomNavigationBar: nav,
      drawer: drawer,
    );

// ---------------------------------------------------------------------------
// expanded() — Expanded wrapper
// ---------------------------------------------------------------------------

/// Wrap in Expanded (fills remaining space inside col/row).
Widget voxExpanded(Widget child, {int flex = 1}) =>
    Expanded(flex: flex, child: child);

// ---------------------------------------------------------------------------
// indexed() — IndexedStack
// ---------------------------------------------------------------------------

/// Show one widget at a time, preserving state of all others.
///
/// ```dart
/// indexed(_tab.val, [HomeTab(), SearchTab(), ProfileTab()])
/// ```
Widget voxIndexed(int current, List<Widget> children) =>
    IndexedStack(index: current, children: children);

// ---------------------------------------------------------------------------
// card() — styled container
// ---------------------------------------------------------------------------

/// A styled box with color, border radius, and optional border.
///
/// ```dart
/// card(label('Hello'), color: _kSurface, radius: 16, borderColor: _kBorder)
/// card(content, color: _kCard, radius: 12, padding: EdgeInsets.all(16))
/// ```
Widget voxCard(
  Widget child, {
  Color? color,
  double radius = 12,
  Color? borderColor,
  double borderWidth = 1,
  EdgeInsetsGeometry? padding,
}) =>
    Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor != null
            ? Border.all(color: borderColor, width: borderWidth)
            : null,
      ),
      child: child,
    );

// ---------------------------------------------------------------------------
// list() — ListView.builder
// ---------------------------------------------------------------------------

/// A scrollable, lazily-built list.
///
/// ```dart
/// list(todos, (todo, i) => _tile(todo, i),
///   padding: EdgeInsets.fromLTRB(16, 12, 16, 90))
/// ```
Widget voxList<T>(
  List<T> items,
  Widget Function(T item, int index) builder, {
  EdgeInsetsGeometry? padding,
  bool shrink = false,
  bool reverse = false,
}) =>
    ListView.builder(
      padding: padding,
      itemCount: items.length,
      shrinkWrap: shrink,
      reverse: reverse,
      itemBuilder: (_, i) => builder(items[i], i),
    );

// ---------------------------------------------------------------------------
// swipeable() — Dismissible wrapper
// ---------------------------------------------------------------------------

/// Swipe-to-dismiss (endToStart). Fires [onSwipe] when dismissed.
///
/// ```dart
/// swipeable(item.id, _tile(item), () => remove(item.id),
///   bg: card(icon(Icons.delete, color: red).bottomRight.pad(right: 20),
///            color: Color(0x26FF0000), radius: 12))
/// ```
Widget voxSwipeable(
  String id,
  Widget child,
  VoidCallback onSwipe, {
  Widget? bg,
}) =>
    Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      background: bg,
      onDismissed: (_) => onSwipe(),
      child: child,
    );

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
      result.add(vertical ? SizedBox(height: gap) : SizedBox(width: gap));
    }
  }
  return result;
}
