/// vox_lint rule: prefer_vox_log
///
/// print() and debugPrint() produce unstructured output with no log levels,
/// no coloring, and no filtering. vox's log singleton provides ANSI-colored
/// leveled logging that can be silenced or filtered in production.
library;

import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

// ---------------------------------------------------------------------------
// Rule
// ---------------------------------------------------------------------------

/// Discourages `print()` and `debugPrint()` in favour of vox's `log`
/// singleton with leveled, colored output.
///
/// **Bad:**
/// ```dart
/// print('User logged in');           // ❌ no level, no color
/// debugPrint('Error: $e');           // ❌ Flutter-only, no levels
/// ```
///
/// **Good:**
/// ```dart
/// log.info('User logged in');        // ✅ colored + filterable
/// log.error('Error: $e');            // ✅ shows in red
/// log.debug('payload: $response');   // ✅ hidden in production
/// ```
class PreferVoxLog extends DartLintRule {
  const PreferVoxLog() : super(code: _code);

  static const _code = LintCode(
    name: 'prefer_vox_log',
    problemMessage:
        "Avoid '{0}()' — use 'log.info()', 'log.debug()', or 'log.error()' instead.",
    correctionMessage:
        'Replace with the appropriate vox log level: '
        "'log.info(msg)', 'log.warn(msg)', 'log.error(msg)', 'log.debug(msg)'.",
    errorSeverity: ErrorSeverity.INFO,
  );

  static const _discouragedFunctions = {'print', 'debugPrint'};

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      // Only bare function calls (no target), e.g. print('x')
      if (node.realTarget != null) return;

      final name = node.methodName.name;
      if (!_discouragedFunctions.contains(name)) return;

      reporter.reportErrorForNode(_code, node.methodName, [name]);
    });
  }
}
