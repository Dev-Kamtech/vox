/// vox_lint rule: avoid_direct_navigator
///
/// Using Navigator.of(context) in a vox app couples code to BuildContext
/// and bypasses VoxRouter. Use vox's context-free navigation instead.
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

// ---------------------------------------------------------------------------
// Rule
// ---------------------------------------------------------------------------

/// Discourages direct `Navigator.of(context)` calls in favour of vox
/// context-free navigation: `go()`, `back()`, `canBack`.
///
/// **Bad:**
/// ```dart
/// Navigator.of(context).push(MaterialPageRoute(builder: (_) => Detail()));
/// Navigator.of(context).pop();
/// ```
///
/// **Good:**
/// ```dart
/// go(Detail());   // context-free push
/// back();         // context-free pop
/// ```
class AvoidDirectNavigator extends DartLintRule {
  const AvoidDirectNavigator() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_direct_navigator',
    problemMessage:
        "Avoid 'Navigator.of(context)' — use vox navigation instead.",
    correctionMessage:
        "Replace with 'go(screen)' to push, or 'back()' to pop.",
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      // Match: Navigator.of(...)
      final target = node.realTarget;
      if (target is! Identifier) return;
      if (target.name != 'Navigator') return;
      if (node.methodName.name != 'of') return;

      reporter.reportErrorForNode(_code, node);
    });
  }
}
