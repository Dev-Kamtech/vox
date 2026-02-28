/// Vox testing utilities.
///
/// Import **in test files only**:
/// ```dart
/// import 'package:vox/testing.dart';
/// ```
///
/// Provides [voxTest], [VoxTester], [VoxFinder], and vox-aware matchers
/// ([isVisible], [isHidden], [findsCount]).
///
/// Example:
/// ```dart
/// import 'package:flutter_test/flutter_test.dart';
/// import 'package:vox/testing.dart';
///
/// void main() {
///   voxTest('counter increments on tap', (tester) async {
///     await tester.render(CounterScreen());
///
///     tester.expect(label('Tapped: 0 times'), isVisible);
///     await tester.tap(btn('+'));
///     tester.expect(label('Tapped: 1 times'), isVisible);
///   });
/// }
/// ```
library;

export 'src/core/testing/vox_tester.dart'
    show
        VoxTester,
        VoxFinder,
        voxTest,
        isVisible,
        isHidden,
        findsCount;
