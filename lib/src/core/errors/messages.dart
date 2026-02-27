/// All error message templates for vox.
///
/// Every message speaks vox language — references vox functions and patterns,
/// never Flutter or Dart internals. Static constants for fixed messages,
/// static methods for parameterized messages.
abstract final class VoxMessages {
  // -- State --
  static const stateOutsideBuild =
      'state.val was read outside a VoxScreen or VoxWidget build — '
      'make sure you read .val inside a view getter';

  static String stateWrongType(String expected, String got) =>
      'state expected type $expected but received $got';

  static const stateAlreadyDisposed =
      'state was accessed after its screen was disposed — '
      'do not hold references to state outside its screen';

  // -- Layout --
  static const colEmptyChildren =
      'col() received an empty list — pass at least one child widget';

  static const rowEmptyChildren =
      'row() received an empty list — pass at least one child widget';

  static const screenMissingTitle =
      'screen() requires a title — screen("My Title", body)';

  static const gridInvalidCols =
      'grid() requires cols > 0 — grid(2, [...])';

  // -- Widgets --
  static const btnNoCallback =
      'btn() was tapped but has no onTap — add .onTap(() { ... })';

  // -- App --
  static const voxAppNoHome =
      'voxApp() requires a home screen — voxApp(home: MyScreen())';

  // -- Extensions --
  static String negativeValue(String method, double value) =>
      '$method received a negative value ($value) — use a positive number';

  static String invalidGap(double value) =>
      'gap() received $value — use a positive number';
}
