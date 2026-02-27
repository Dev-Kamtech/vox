/// vox_lint rule: prefer_final_state
///
/// vox reactive values (state, shared, computed, stored) must be assigned
/// to `final` fields. Reassigning them would replace the reactive object,
/// silently breaking all listeners.
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

// ---------------------------------------------------------------------------
// Rule
// ---------------------------------------------------------------------------

/// Reactive vox values (`state()`, `shared()`, `computed()`, `stored()`)
/// must be assigned to `final` fields.
///
/// **Bad:**
/// ```dart
/// var count = state(0);    // ❌ count could be reassigned
/// int count = state(0);    // ❌ loses reactivity type
/// ```
///
/// **Good:**
/// ```dart
/// final count = state(0);  // ✅ reactive and safe
/// ```
class PreferFinalState extends DartLintRule {
  const PreferFinalState() : super(code: _code);

  static const _code = LintCode(
    name: 'prefer_final_state',
    problemMessage:
        "vox reactive value '{0}' must be declared as 'final'.",
    correctionMessage:
        "Change 'var {0} = {1}(...)' to 'final {0} = {1}(...)'.",
    errorSeverity: ErrorSeverity.WARNING,
  );

  /// The vox factory functions that produce reactive objects.
  static const _reactiveFactories = {
    'state',
    'shared',
    'computed',
    'stored',
  };

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addVariableDeclaration((node) {
      // The parent VariableDeclarationList holds isFinal / isConst.
      final parent = node.parent;
      if (parent is! VariableDeclarationList) return;
      if (parent.isFinal || parent.isConst) return;

      final initializer = node.initializer;
      if (initializer is! MethodInvocation) return;

      final methodName = initializer.methodName.name;
      if (!_reactiveFactories.contains(methodName)) return;

      reporter.reportErrorForToken(
        _code,
        node.name,
        [node.name.lexeme, methodName],
      );
    });
  }
}
