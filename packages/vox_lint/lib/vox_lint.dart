/// vox_lint — custom lint rules for the vox Flutter framework.
///
/// Add to your project's `dev_dependencies`:
/// ```yaml
/// dev_dependencies:
///   custom_lint: ^0.6.0
///   vox_lint: ^0.1.0
/// ```
///
/// Then enable in `analysis_options.yaml`:
/// ```yaml
/// analyzer:
///   plugins:
///     - custom_lint
/// ```
///
/// Rules included:
/// | Rule | Severity | What it catches |
/// |------|----------|----------------|
/// | [prefer_final_state] | warning | `state()` / `shared()` / `computed()` / `stored()` not `final` |
/// | [avoid_direct_navigator] | warning | `Navigator.of(context)` instead of `go()` / `back()` |
/// | [avoid_direct_snackbar] | warning | `ScaffoldMessenger.of(context)` instead of `toast()` |
/// | [prefer_vox_log] | info | `print()` / `debugPrint()` instead of `log.*` |
/// | [avoid_direct_theme] | info | `Theme.of(context)` instead of `vox.theme.*` |
library vox_lint;

import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/rules/avoid_direct_navigator.dart';
import 'src/rules/avoid_direct_snackbar.dart';
import 'src/rules/avoid_direct_theme.dart';
import 'src/rules/prefer_final_state.dart';
import 'src/rules/prefer_vox_log.dart';

export 'src/rules/avoid_direct_navigator.dart';
export 'src/rules/avoid_direct_snackbar.dart';
export 'src/rules/avoid_direct_theme.dart';
export 'src/rules/prefer_final_state.dart';
export 'src/rules/prefer_vox_log.dart';

// ---------------------------------------------------------------------------
// Plugin entry point — custom_lint discovers this via createPlugin()
// ---------------------------------------------------------------------------

/// The vox_lint plugin entry point.
///
/// custom_lint discovers this function automatically when the package is
/// listed under `analyzer.plugins` in `analysis_options.yaml`.
PluginBase createPlugin() => _VoxLintPlugin();

class _VoxLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => const [
        // Reactive state
        PreferFinalState(),

        // Navigation
        AvoidDirectNavigator(),

        // Feedback
        AvoidDirectSnackbar(),

        // Logging
        PreferVoxLog(),

        // Theming
        AvoidDirectTheme(),
      ];
}
