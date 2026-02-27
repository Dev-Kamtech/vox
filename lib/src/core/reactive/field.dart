/// Validation rule for form fields.
///
/// Returns an error message string if the value fails the rule, or null if valid.
///
/// ```dart
/// VoxRule nonEmpty = (v) => v.isEmpty ? 'Required' : null;
/// ```
typedef VoxRule = String? Function(String value);

/// Built-in validation rules.
///
/// ```dart
/// final email = field(rules: [Rules.required, Rules.email]);
/// final pass  = field(rules: [Rules.required, Rules.minLength(8)]);
/// ```
abstract final class Rules {
  /// Value must not be empty (trims whitespace before checking).
  static VoxRule get required =>
      (v) => v.trim().isEmpty ? 'This field is required' : null;

  /// Value must be a valid email address.
  static VoxRule get email => (v) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)
          ? null
          : 'Enter a valid email address';

  /// Value length must be at least [n] characters.
  static VoxRule minLength(int n) =>
      (v) => v.length < n ? 'Minimum $n characters' : null;

  /// Value length must not exceed [n] characters.
  static VoxRule maxLength(int n) =>
      (v) => v.length > n ? 'Maximum $n characters' : null;

  /// Value must match [pattern]. [message] is shown on failure.
  static VoxRule pattern(RegExp pattern, String message) =>
      (v) => pattern.hasMatch(v) ? null : message;

  /// Value must be a valid number.
  static VoxRule get numeric =>
      (v) => double.tryParse(v) == null ? 'Must be a number' : null;
}
