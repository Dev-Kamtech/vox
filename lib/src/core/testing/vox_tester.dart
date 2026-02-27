/// vox core: testing engine — VoxTester and VoxFinder.
///
/// Import via `package:vox/testing.dart` in test files only.
/// Do NOT import this from production code.
library;

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart' as ft;

import '../nav/router.dart';
import '../reactive/signal.dart';
import '../screen/vox_screen.dart';
import '../ui/widgets.dart';

// ---------------------------------------------------------------------------
// voxTest — wraps testWidgets
// ---------------------------------------------------------------------------

/// Test a vox screen. Replaces [testWidgets] with a vox-aware callback.
///
/// ```dart
/// voxTest('counter increments', (tester) async {
///   await tester.render(CounterScreen());
///   await tester.tap(btn('+'));
///   tester.expect(count, equals(1));
/// });
/// ```
void voxTest(
  String description,
  Future<void> Function(VoxTester tester) test, {
  bool skip = false,
  ft.Timeout? timeout,
}) {
  ft.testWidgets(
    description,
    (ft.WidgetTester tester) async {
      await test(VoxTester._(tester));
    },
    skip: skip,
    timeout: timeout,
  );
}

// ---------------------------------------------------------------------------
// Matchers
// ---------------------------------------------------------------------------

/// Asserts a widget or finder is present in the tree.
const ft.Matcher isVisible = ft.findsOneWidget;

/// Asserts a widget or finder is absent from the tree.
const ft.Matcher isHidden = ft.findsNothing;

/// Asserts exactly [n] matching widgets are found.
ft.Matcher findsCount(int n) => ft.findsNWidgets(n);

// ---------------------------------------------------------------------------
// VoxTester
// ---------------------------------------------------------------------------

/// The vox test driver. Wraps [WidgetTester] with vox-aware helpers.
///
/// Access the raw [WidgetTester] via [raw] for operations not covered here.
class VoxTester {
  /// The underlying Flutter [WidgetTester] — escape hatch for advanced use.
  final ft.WidgetTester raw;

  VoxTester._(this.raw);

  // -- Rendering ------------------------------------------------------------

  /// Render [screen] in a minimal [MaterialApp] and settle all frames.
  ///
  /// ```dart
  /// await tester.render(CounterScreen());
  /// ```
  Future<void> render(VoxScreen screen) async {
    await raw.pumpWidget(
      MaterialApp(
        navigatorKey: VoxRouter.key,
        home: screen.toWidget(),
      ),
    );
    await raw.pumpAndSettle();
  }

  // -- Finding --------------------------------------------------------------

  /// Find a widget in the tree by various targets:
  ///
  /// - [String] → finds by text content
  /// - [VoxLabel] → finds by label text
  /// - [VoxButton] → finds by button text
  /// - [Icon] → finds by icon data
  /// - [Widget] → finds by runtime type
  VoxFinder find(Object target) => VoxFinder._(raw, target);

  // -- Actions (shorthand) --------------------------------------------------

  /// Find [target] and tap it, then settle.
  Future<void> tap(Object target) => find(target).tap();

  /// Find [target] and type [text] into it, then settle.
  Future<void> type(Object target, String text) => find(target).type(text);

  /// Find [target] and long-press it, then settle.
  Future<void> longPress(Object target) => find(target).longPress();

  // -- Assertions -----------------------------------------------------------

  /// Smart assertion that understands vox types.
  ///
  /// - [VoxSignal] / [VoxState] → asserts on `.peek` (the current raw value)
  /// - [VoxFinder] → asserts on the underlying Flutter finder
  /// - [Widget] → finds the widget first, then asserts
  /// - anything else → standard [ft.expect]
  ///
  /// ```dart
  /// tester.expect(count, equals(3));
  /// tester.expect(label("Hi"), isVisible);
  /// tester.expect(todos, hasLength(2));
  /// ```
  // ignore: avoid_shadowing_type_parameters
  void expect<T>(Object actual, ft.Matcher matcher) {
    if (actual is VoxSignal) {
      ft.expect(actual.peek, matcher);
    } else if (actual is VoxFinder) {
      ft.expect(actual._finder, matcher);
    } else if (actual is Widget) {
      ft.expect(find(actual)._finder, matcher);
    } else {
      ft.expect(actual, matcher);
    }
  }

  // -- Frame control --------------------------------------------------------

  /// Pump [duration] worth of frames (default: one frame).
  Future<void> pump([Duration? duration]) => raw.pump(duration);

  /// Pump until no frames are scheduled (settle).
  Future<void> settle() => raw.pumpAndSettle();

  /// Pump a specific [duration] in steps (useful for animations).
  Future<void> pumpDuration(Duration duration) =>
      raw.pump(duration);
}

// ---------------------------------------------------------------------------
// VoxFinder
// ---------------------------------------------------------------------------

/// A lazy widget finder that understands vox widget types.
///
/// Created via [VoxTester.find]. Chain with [tap], [type], [exists].
class VoxFinder {
  final ft.WidgetTester _tester;
  final Object _target;

  VoxFinder._(this._tester, this._target);

  /// The underlying Flutter [Finder].
  ft.Finder get _finder {
    final target = _target;
    if (target is String) return ft.find.text(target);
    if (target is VoxLabel) return ft.find.text(target.text);
    if (target is VoxButton) return ft.find.text(target.text);
    if (target is Icon && target.icon != null) {
      return ft.find.byIcon(target.icon!);
    }
    if (target is Widget) return ft.find.byType(target.runtimeType);
    return ft.find.text(target.toString());
  }

  // -- Actions --------------------------------------------------------------

  /// Tap this widget and settle all frames.
  Future<void> tap() async {
    await _tester.tap(_finder);
    await _tester.pumpAndSettle();
  }

  /// Enter [text] into this widget (TextField / input) and settle.
  Future<void> type(String text) async {
    await _tester.enterText(_finder, text);
    await _tester.pumpAndSettle();
  }

  /// Long-press this widget and settle.
  Future<void> longPress() async {
    await _tester.longPress(_finder);
    await _tester.pumpAndSettle();
  }

  /// Drag this widget by [offset] and settle.
  Future<void> drag(Offset offset) async {
    await _tester.drag(_finder, offset);
    await _tester.pumpAndSettle();
  }

  // -- State ----------------------------------------------------------------

  /// Whether this widget exists in the tree.
  bool get exists => _finder.evaluate().isNotEmpty;

  /// Whether exactly one matching widget exists.
  bool get isUnique => _finder.evaluate().length == 1;

  /// Number of matching widgets.
  int get count => _finder.evaluate().length;
}
