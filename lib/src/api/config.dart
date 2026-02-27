/// vox api: config — runtime environment variables.
///
/// ```dart
/// // At startup (in main or voxApp init:):
/// VoxEnv.configure({
///   'API_URL': const String.fromEnvironment('API_URL',
///       defaultValue: 'https://api.example.com'),
///   'FEATURE_FLAGS': const String.fromEnvironment('FEATURE_FLAGS'),
/// });
///
/// // Anywhere in the app:
/// final url = env('API_URL');
/// final debug = env('DEBUG', fallback: 'false');
/// ```
library;

export '../core/config/env.dart' show VoxEnv, env;
