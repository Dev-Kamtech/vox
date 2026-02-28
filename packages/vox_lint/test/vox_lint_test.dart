// ignore_for_file: prefer_const_constructors

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:test/test.dart';
import 'package:vox_lint/vox_lint.dart';

void main() {
  group('vox_lint plugin', () {
    test('createPlugin() returns a PluginBase', () {
      final plugin = createPlugin();
      expect(plugin, isA<PluginBase>());
    });

    test('getLintRules() returns all 5 rules', () {
      final plugin = createPlugin() as dynamic;
      // ignore: avoid_dynamic_calls
      final rules = plugin.getLintRules(CustomLintConfigs.empty) as List;
      expect(rules, hasLength(5));
    });
  });

  // ------------------------------------------------------------------
  // Rule instantiation — verifies each rule has the correct code name
  // ------------------------------------------------------------------

  group('PreferFinalState', () {
    test('has correct lint code name', () {
      const rule = PreferFinalState();
      expect(rule.code.name, 'prefer_final_state');
    });
  });

  group('AvoidDirectNavigator', () {
    test('has correct lint code name', () {
      const rule = AvoidDirectNavigator();
      expect(rule.code.name, 'avoid_direct_navigator');
    });
  });

  group('AvoidDirectSnackbar', () {
    test('has correct lint code name', () {
      const rule = AvoidDirectSnackbar();
      expect(rule.code.name, 'avoid_direct_snackbar');
    });
  });

  group('PreferVoxLog', () {
    test('has correct lint code name', () {
      const rule = PreferVoxLog();
      expect(rule.code.name, 'prefer_vox_log');
    });
  });

  group('AvoidDirectTheme', () {
    test('has correct lint code name', () {
      const rule = AvoidDirectTheme();
      expect(rule.code.name, 'avoid_direct_theme');
    });
  });
}
