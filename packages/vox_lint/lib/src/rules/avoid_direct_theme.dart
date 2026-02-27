/// vox_lint rule: avoid_direct_theme
///
/// Theme.of(context) couples code to BuildContext and doesn't react to
/// VoxThemeController changes. Use vox.theme.* token access instead.
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

// ---------------------------------------------------------------------------
// Rule
// ---------------------------------------------------------------------------

/// Discourages `Theme.of(context)` in favour of `vox.theme.*` token access.
///
/// **Bad:**
/// ```dart
/// final color = Theme.of(context).colorScheme.primary;
/// final text  = Theme.of(context).textTheme.bodyMedium;
/// ```
///
/// **Good:**
/// ```dart
/// final color = vox.theme.primary;
/// final isDark = vox.theme.dark;
/// ```
class AvoidDirectTheme extends DartLintRule {
  const AvoidDirectTheme() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_direct_theme',
    problemMessage:
        "Avoid 'Theme.of(context)' — use 'vox.theme.*' token access instead.",
    correctionMessage:
        "Replace with 'vox.theme.primary', 'vox.theme.surface', "
        "'vox.theme.dark', etc.",
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      // Match: Theme.of(...)
      final target = node.realTarget;
      if (target is! Identifier) return;
      if (target.name != 'Theme') return;
      if (node.methodName.name != 'of') return;

      reporter.reportErrorForNode(_code, node);
    });
  }
}
