/// vox_lint rule: avoid_direct_snackbar
///
/// Using ScaffoldMessenger.of(context).showSnackBar() in a vox app
/// couples code to BuildContext. Use vox's context-free toast() instead.
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

// ---------------------------------------------------------------------------
// Rule
// ---------------------------------------------------------------------------

/// Discourages `ScaffoldMessenger.of(context).showSnackBar()` in favour of
/// vox's context-free `toast()`.
///
/// **Bad:**
/// ```dart
/// ScaffoldMessenger.of(context).showSnackBar(
///   SnackBar(content: Text('Saved!')),
/// );
/// ```
///
/// **Good:**
/// ```dart
/// toast('Saved!', type: VoxToastType.success);
/// ```
class AvoidDirectSnackbar extends DartLintRule {
  const AvoidDirectSnackbar() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_direct_snackbar',
    problemMessage:
        "Avoid 'ScaffoldMessenger.of(context)' — use vox 'toast()' instead.",
    correctionMessage:
        "Replace with 'toast(message)' or "
        "'toast(message, type: VoxToastType.success)'.",
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      // Match: ScaffoldMessenger.of(...)
      final target = node.realTarget;
      if (target is! Identifier) return;
      if (target.name != 'ScaffoldMessenger') return;
      if (node.methodName.name != 'of') return;

      reporter.reportErrorForNode(_code, node);
    });
  }
}
