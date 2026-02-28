import '../errors/vox_error.dart';

/// Type-based service locator.
///
/// Register services with [provide] and retrieve them with [use].
/// All lookups are by Dart type — no string keys, no magic.
///
/// ```dart
/// // Register
/// provide<AuthService>(AuthService());
/// provide<ApiClient>(ApiClient(baseUrl: 'https://api.example.com'));
///
/// // Retrieve (from any screen, widget, or function)
/// final auth = use<AuthService>();
/// final api  = use<ApiClient>();
///
/// // Test overrides
/// override<AuthService>(MockAuthService());
/// ```
abstract final class VoxContainer {
  static final Map<Type, Object> _registry = {};

  /// Register a service instance by its type [T].
  ///
  /// Calling again with the same type replaces the previous registration.
  static void provide<T extends Object>(T instance) {
    _registry[T] = instance;
  }

  /// Retrieve the registered service of type [T].
  ///
  /// Throws [VoxError] if [T] has not been registered via [provide].
  static T use<T extends Object>() {
    final instance = _registry[T];
    if (instance == null) {
      throw VoxError(
        'No service registered for $T.',
        hint: 'Call provide<$T>(instance) before use<$T>().',
      );
    }
    return instance as T;
  }

  /// Returns `true` if a service of type [T] has been registered.
  static bool has<T extends Object>() => _registry.containsKey(T);

  /// Override a registered service — useful in tests.
  ///
  /// ```dart
  /// override<AuthService>(MockAuthService());
  /// ```
  static void override<T extends Object>(T instance) => provide<T>(instance);

  /// Remove the registered service of type [T].
  static void remove<T extends Object>() => _registry.remove(T);

  /// Clear all registered services.
  static void clear() => _registry.clear();
}
