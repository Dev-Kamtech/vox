/// Form fields, validation, and multi-field form containers.
///
/// ```dart
/// final email = field(hint: 'Email', rules: [Rules.required, Rules.email]);
/// final pass  = field(hint: 'Password', obscure: true, rules: [Rules.required]);
///
/// // Render in view:
/// email.input   // TextField widget
/// pass.input
///
/// // Validate on submit:
/// if (email.validate() && pass.validate()) login();
///
/// // Or use VoxForm for batch validation:
/// final form = voxForm({
///   'email': field(rules: [Rules.required, Rules.email]),
///   'pass':  field(rules: [Rules.required, Rules.minLength(8)]),
/// });
/// form.submit(() => login(form.values));
/// ```
library;

export '../core/forms/form.dart' show VoxField, VoxForm;
export '../core/reactive/field.dart' show VoxRule, Rules;

import 'package:flutter/material.dart' show TextInputType, TextInputAction;

import '../core/forms/form.dart';
import '../core/reactive/field.dart';

/// Create a reactive form field controller.
///
/// [hint] and [label] configure the rendered [TextField].
/// [rules] run when [VoxField.validate] is called.
/// [obscure] hides text (for passwords).
///
/// ```dart
/// final email = field(hint: 'Email', rules: [Rules.required, Rules.email]);
/// final pass  = field(hint: 'Password', obscure: true, rules: [Rules.required]);
/// ```
VoxField field({
  String initial = '',
  List<VoxRule> rules = const [],
  String? hint,
  String? label,
  bool obscure = false,
  TextInputType? keyboard,
  TextInputAction? action,
  int? maxLines = 1,
  void Function(String)? onChange,
  void Function(String)? onSubmitted,
}) =>
    VoxField(
      initial: initial,
      rules: rules,
      hint: hint,
      label: label,
      obscure: obscure,
      keyboard: keyboard,
      action: action,
      maxLines: maxLines,
      onChange: onChange,
      onSubmitted: onSubmitted,
    );

/// Create a [VoxForm] — a container that validates and submits multiple fields.
///
/// ```dart
/// final form = voxForm({
///   'email': field(rules: [Rules.required, Rules.email]),
///   'pass':  field(rules: [Rules.required, Rules.minLength(8)]),
/// });
///
/// // In submit handler:
/// form.submit(() {
///   final values = form.values; // Map<String, String>
/// });
/// ```
VoxForm voxForm(Map<String, VoxField> fields) => VoxForm(fields);
