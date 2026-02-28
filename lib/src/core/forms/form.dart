import 'package:flutter/material.dart' hide State;
import 'package:flutter/material.dart' as flutter show State;

import '../reactive/field.dart';
import '../reactive/state.dart';

// ---------------------------------------------------------------------------
// VoxField — reactive form field. State container + renders as TextField.
// ---------------------------------------------------------------------------

/// Reactive form field. Stores text value and validation state as independent
/// reactive signals. Renders as a [TextField] via the [input] property.
///
/// Store as a `final` field on your [VoxScreen]. Use [input] in the view tree
/// to render it. Access [val], [error], [validate()] directly.
///
/// ```dart
/// class LoginScreen extends VoxScreen {
///   final email = field(hint: 'Email', rules: [Rules.required, Rules.email]);
///   final pass  = field(hint: 'Password', obscure: true, rules: [Rules.required]);
///
///   @override
///   get view => col([
///     email.input,          // renders as TextField
///     pass.input,
///     btn('Login').onTap(() {
///       if (email.validate() && pass.validate()) login();
///     }),
///   ]);
/// }
/// ```
class VoxField {
  final String _initial;
  final List<VoxRule> _rules;
  final String? _hint;
  final String? _label;
  final bool _obscure;
  final TextInputType? _inputType;
  final TextInputAction? _inputAction;
  final int? _maxLines;
  final void Function(String)? _onChanged;
  final void Function(String)? _onSubmitted;

  // Reactive signals — live on the VoxField instance so they're accessible
  // whether the widget is mounted or not.
  late final VoxState<String> _value = VoxState(_initial);
  late final VoxState<String?> _error = VoxState(null);

  // Weak reference to the mounted widget's FocusNode. Set/cleared by State.
  FocusNode? _registeredFocus;

  VoxField({
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
  })  : _initial = initial,
        _rules = rules,
        _hint = hint,
        _label = label,
        _obscure = obscure,
        _inputType = keyboard,
        _inputAction = action,
        _maxLines = maxLines,
        _onChanged = onChange,
        _onSubmitted = onSubmitted;

  // --------------------------------------------------------------------------
  // Reactive state API
  // --------------------------------------------------------------------------

  /// Current text value. Tracked — screens reading this rebuild on change.
  String get val => _value.val;

  /// Current text value (untracked).
  String get peek => _value.peek;

  /// Set the text programmatically.
  void set(String v) => _value.set(v);

  /// Get the current value and clear the field.
  String take() {
    final v = _value.peek;
    _value.set('');
    return v;
  }

  /// Clear the text.
  void clear() => _value.set('');

  /// Clear the text and any validation error.
  void reset() {
    _value.set('');
    _error.set(null);
  }

  /// Current validation error, or null if valid. Tracked.
  String? get error => _error.val;

  /// Run all validation rules. Sets [error] to the first failure message.
  /// Returns true if all rules pass.
  bool validate() {
    for (final rule in _rules) {
      final err = rule(_value.peek);
      if (err != null) {
        _error.set(err);
        return false;
      }
    }
    _error.set(null);
    return true;
  }

  // --------------------------------------------------------------------------
  // Focus
  // --------------------------------------------------------------------------

  /// Request keyboard focus on this field.
  void focus() => _registeredFocus?.requestFocus();

  /// Remove keyboard focus from this field.
  void unfocus() => _registeredFocus?.unfocus();

  /// Whether this field currently has keyboard focus.
  bool get hasFocus => _registeredFocus?.hasFocus ?? false;

  // --------------------------------------------------------------------------
  // Widget
  // --------------------------------------------------------------------------

  /// Render this field as a [TextField] widget.
  ///
  /// Use in the view tree wherever a Widget is expected:
  /// ```dart
  /// col([
  ///   email.input,
  ///   pass.input,
  /// ])
  /// ```
  Widget get input => _VoxInputWidget(this);
}

// ---------------------------------------------------------------------------
// _VoxInputWidget — internal StatefulWidget for rendering VoxField
// ---------------------------------------------------------------------------

class _VoxInputWidget extends StatefulWidget {
  final VoxField field;

  _VoxInputWidget(this.field) : super(key: ObjectKey(field));

  @override
  flutter.State<_VoxInputWidget> createState() => _VoxInputWidgetState();
}

class _VoxInputWidgetState extends flutter.State<_VoxInputWidget> {
  late final TextEditingController _ctrl;
  late final FocusNode _focusNode;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.field._initial);
    _focusNode = FocusNode();
    widget.field._registeredFocus = _focusNode;

    // User typing → update reactive signal
    _ctrl.addListener(_onControllerChanged);

    // Programmatic set() → update controller text
    widget.field._value.addListener(_onSignalChanged);

    // Error change → rebuild to show/hide error decoration
    widget.field._error.addListener(_onErrorChanged);
  }

  void _onControllerChanged() {
    if (_syncing) return;
    widget.field._value.set(_ctrl.text);
    widget.field._onChanged?.call(_ctrl.text);
  }

  void _onSignalChanged() {
    final newText = widget.field._value.peek;
    if (_ctrl.text == newText) return;
    _syncing = true;
    // Use a fresh TextEditingValue so the cursor resets to the end of the
    // new text. copyWith() would keep the old cursor offset, which causes
    // a Flutter assertion when clearing a field (offset > new text length).
    _ctrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
    _syncing = false;
  }

  void _onErrorChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.field._registeredFocus = null;
    widget.field._value.removeListener(_onSignalChanged);
    widget.field._error.removeListener(_onErrorChanged);
    _ctrl.removeListener(_onControllerChanged);
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      focusNode: _focusNode,
      obscureText: widget.field._obscure,
      keyboardType: widget.field._inputType,
      textInputAction: widget.field._inputAction,
      maxLines: widget.field._obscure ? 1 : widget.field._maxLines,
      decoration: InputDecoration(
        hintText: widget.field._hint,
        labelText: widget.field._label,
        errorText: widget.field._error.peek,
        border: const OutlineInputBorder(),
      ),
      onSubmitted: widget.field._onSubmitted,
    );
  }
}

// ---------------------------------------------------------------------------
// VoxForm — validates and submits multiple fields together
// ---------------------------------------------------------------------------

/// A container for multiple form fields.
///
/// ```dart
/// final form = voxForm({
///   'email': field(rules: [Rules.required, Rules.email]),
///   'pass':  field(rules: [Rules.required, Rules.minLength(8)]),
/// });
///
/// form.submit(() {
///   post('/login', body: form.values) >> user;
/// });
/// ```
class VoxForm {
  final Map<String, VoxField> _fields;

  VoxForm(this._fields);

  /// Access a field by key.
  VoxField? operator [](String key) => _fields[key];

  /// Current values of all fields as a map.
  Map<String, String> get values => {
        for (final e in _fields.entries) e.key: e.value.peek,
      };

  /// Validate all fields. Returns true only if every field passes.
  bool validate() {
    var allValid = true;
    for (final f in _fields.values) {
      if (!f.validate()) allValid = false;
    }
    return allValid;
  }

  /// Validate all fields and call [onValid] if all pass.
  void submit(void Function() onValid) {
    if (validate()) onValid();
  }

  /// Reset all fields and their errors.
  void reset() {
    for (final f in _fields.values) {
      f.reset();
    }
  }
}
