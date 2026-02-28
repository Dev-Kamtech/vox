/// vox core: env configuration — runtime environment variables.
library;

import '../errors/vox_error.dart';

// ---------------------------------------------------------------------------
// VoxEnv — in-memory environment variable registry
// ---------------------------------------------------------------------------

/// Stores runtime environment variables set at app startup.
///
/// Populate via [configure] in your `voxApp(init: ...)` or `main()`:
///
/// ```dart
/// VoxEnv.configure({
///   'API_URL': const String.fromEnvironment('API_URL',
///       defaultValue: 'https://api.example.com'),
///   'APP_KEY': const String.fromEnvironment('APP_KEY'),
/// });
/// ```
///
/// Then anywhere in the app:
/// ```dart
/// final url = env('API_URL');
/// ```
abstract final class VoxEnv {
  static final Map<String, String> _vars = {};

  /// Populate the environment registry with [vars].
  ///
  /// Can be called multiple times — later values overwrite earlier ones.
  static void configure(Map<String, String> vars) => _vars.addAll(vars);

  /// Returns the value for [key], or `null` if not set.
  static String? nullable(String key) => _vars[key];

  /// Returns the value for [key].
  ///
  /// If [key] is not set, returns [fallback] when provided.
  /// Throws a [VoxError] if neither the key nor a fallback is available.
  static String call(String key, {String? fallback}) {
    final value = _vars[key] ?? fallback;
    if (value == null) {
      throw VoxError(
        'env("$key") is not set.',
        hint: 'Call VoxEnv.configure({"$key": value}) at app startup '
            'or pass a fallback: env("$key", fallback: "default").',
      );
    }
    return value;
  }

  /// Clears all registered variables. Useful in tests.
  static void clear() => _vars.clear();
}

// ---------------------------------------------------------------------------
// env() — top-level convenience function
// ---------------------------------------------------------------------------

/// Retrieve a runtime environment variable by [key].
///
/// ```dart
/// final apiUrl = env('API_URL');
/// final debug  = env('DEBUG', fallback: 'false');
/// ```
///
/// Throws a [VoxError] if [key] is not set and no [fallback] is provided.
String env(String key, {String? fallback}) =>
    VoxEnv.call(key, fallback: fallback);
